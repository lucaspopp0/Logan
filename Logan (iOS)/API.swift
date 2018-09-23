//
//  API.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 9/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

enum APIError: Error {
    
    case invalidUrlError(String)
    case invalidJSONError(String)
    case requestError(String)
    case responseError(String)
    
}

class API: NSObject {
    
    static let dateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "M-d-yyyy h:mm a"
        return df
    }()
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "M-d-yyyy"
        return df
    }()
    
    static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }()
    
    // MARK: Types
    
    class Map<T: CKEnabled, A: APIObject> {
        
        var pairs: [(dm: T, api: A)] = []
        
        func clear() {
            pairs.removeAll()
        }
        
        func pairing(_ dm: T) -> A? {
            for pair in pairs {
                if pair.dm.record == dm.record {
                    return pair.api
                }
            }
            
            return nil
        }
        
        func pairing(_ api: A) -> T? {
            for pair in pairs {
                if pair.api.id == api.id {
                    return pair.dm
                }
            }
            
            return nil
        }
        
    }
    
    typealias SingleCallback = ((Error?, [String: Any]?) -> Void)
    typealias ArrayCallback = ((Error?, [[String: Any]]?) -> Void)
    
    // MARK: Variables
    
    var totalSemesters: Int = 0
    var totalCourses: Int = 0
    var totalSections: Int = 0
    var totalAssessments: Int = 0
    var totalTags: Int = 0
    var totalAssignments: Int = 0
    var totalTasks: Int = 0
    
    var semesters: [APISemester] = []
    var tags: [APITag] = []
    var assessments: [APIAssessment] = []
    var assignments: [APIAssignment] = []
    var tasks: [APITask] = []
    
    var tagMap = Map<Extracurricular, APITag>()
    var semesterMap = Map<Semester, APISemester>()
    var courseMap = Map<Course, APICourse>()
    var sectionMap = Map<Class, APISection>()
    var assessmentMap = Map<Exam, APIAssessment>()
    var assignmentMap = Map<Assignment, APIAssignment>()
    var taskMap = Map<Task, APITask>()
    
    var errors: [Error] = []
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    static let shared = API()
    static let baseURL = URL(string: "http://logan-env.tdbmskijxc.us-east-2.elasticbeanstalk.com/")!
    
    var user: String = "101626062651726400398"
    
    private var fetching: Bool = false
    
    // MARK: - External fetch
    
    func fetchData(_ completion: @escaping ((Bool, [Error]) -> Void)) {
        if !fetching {
            fetching = true
            
            semesters = []
            tags = []
            assessments = []
            assignments = []
            tasks = []
            
            errors = []
            
            fetchTags(completion)
        }
    }
    
    fileprivate func fetchTags(_ completion: @escaping ((Bool, [Error]) -> Void)) {
        getTags { (error, response) in
            if error != nil {
                self.errors.append(error!)
            } else if response != nil {
                for dict in response! {
                    if let tag = APITag(dict: dict) {
                        self.tags.append(tag)
                    }
                }
                
                self.fetchSemesters(completion)
            }
        }
    }
    
    fileprivate func fetchSemesters(_ completion: @escaping ((Bool, [Error]) -> Void)) {
        getSemesters { (semesters_error, semesters_response) in
            if semesters_error != nil {
                self.errors.append(semesters_error!)
            } else if semesters_response != nil {
                for semester_dict in semesters_response! {
                    if let semester = APISemester(dict: semester_dict) {
                        
                        self.getCourses(forSemester: semester, completion: { (courses_error, courses_response) in
                            if courses_error != nil {
                                self.errors.append(courses_error!)
                            } else if courses_response != nil {
                                for course_dict in courses_response! {
                                    if let course = APICourse(dict: course_dict, semester: semester) {
                                        
                                        self.getSections(forCourse: course.id, completion: { (sections_error, sections_response) in
                                            if sections_error != nil {
                                                self.errors.append(sections_error!)
                                            } else if sections_response != nil {
                                                for section_dict in sections_response! {
                                                    if let section = APISection(dict: section_dict, course: course) {
                                                        course.sections.append(section)
                                                    }
                                                }
                                                
                                                semester.courses.append(course)
                                                
                                                if semester.courses.count == courses_response!.count {
                                                    self.semesters.append(semester)
                                                }
                                                
                                                if self.semesters.count == semesters_response!.count {
                                                    self.fetchAssessments(completion)
                                                }
                                            }
                                        })
                                        
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    fileprivate func fetchAssessments(_ completion: @escaping ((Bool, [Error]) -> Void)) {
        getAssessments { (error, response) in
            if error != nil {
                self.errors.append(error!)
            } else if response != nil {
                for dict in response! {
                    var source: APISource?
                    
                    if let src = dict["source"] as? String {
                        source = self.findSource(src)
                    }
                    
                    if let assessment = APIAssessment(dict: dict, source: source) {
                        self.assessments.append(assessment)
                    }
                }
                
                self.fetchAssignments(completion)
            }
        }
    }
    
    fileprivate func fetchAssignments(_ completion: @escaping ((Bool, [Error]) -> Void)) {
        getAssignments { (error, response) in
            if error != nil {
                self.errors.append(error!)
            } else if response != nil {
                for dict in response! {
                    if let assignment = APIAssignment(dict: dict, sources: self.findSources((dict["sources"] as? [String]) ?? [])) {
                        self.assignments.append(assignment)
                    }
                    
                    self.fetchTasks(completion)
                }
            }
        }
    }
    
    fileprivate func fetchTasks(_ completion: @escaping ((Bool, [Error]) -> Void)) {
        getTasks { (error, response) in
            if error != nil {
                self.errors.append(error!)
            } else if response != nil {
                for dict in response! {
                    if let task = APITask(dict: dict, sources: self.findSources((dict["sources"] as? [String]) ?? [])) {
                        self.tasks.append(task)
                    }
                    
                    DispatchQueue.main.async {
                        self.fetching = false
                        completion(true, self.errors)
                    }
                }
            }
        }
    }
    
    // MARK: - Utility functions
    
    func prepareRequest(method: HTTPMethod, url: String, body: Data? = nil) -> (session: URLSession, request: URLRequest)? {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
        
        guard let requestURL = URL(string: url, relativeTo: API.baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        request.httpBody = body
        
        return (session, request)
    }
    
    func simpleGet(_ url: String, callback: @escaping ArrayCallback) {
        guard let (session, request) = prepareRequest(method: API.HTTPMethod.GET, url: url) else {
            callback(APIError.invalidUrlError("Invalid URL '\(url)'"), nil)
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                callback(APIError.requestError(error!.localizedDescription), nil)
            } else if data != nil {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let array = response as? [[String: Any]] {
                        callback(nil, array)
                    } else if let errDict = response as? [String: Any], let message = errDict["error"] as? String {
                        callback(APIError.responseError(message), nil)
                    } else {
                        callback(APIError.responseError("Invalid response"), nil)
                    }
                } catch {
                    callback(APIError.responseError(error.localizedDescription), nil)
                }
            } else {
                callback(APIError.responseError("Empty response"), nil)
            }
        }
        
        task.resume()
    }
    
    func simpleGet(_ url: String, callback: @escaping SingleCallback) {
        guard let (session, request) = prepareRequest(method: API.HTTPMethod.GET, url: url) else {
            callback(APIError.invalidUrlError("Invalid URL '\(url)'"), nil)
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                callback(APIError.requestError(error!.localizedDescription), nil)
            } else if data != nil {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let dict = response as? [String: Any] {
                        if let message = dict["error"] as? String {
                            callback(APIError.responseError(message), nil)
                        } else {
                            callback(nil, dict)
                        }
                    } else {
                        callback(APIError.responseError("Invalid response"), nil)
                    }
                } catch {
                    callback(APIError.responseError(error.localizedDescription), nil)
                }
            } else {
                callback(APIError.responseError("Empty response"), nil)
            }
        }
        
        task.resume()
    }
    
    func simplePost(_ url: String, data: [String: Any], callback: @escaping SingleCallback) {
        var json: Data?
        
        do {
            json = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            callback(APIError.invalidJSONError(error.localizedDescription), nil)
            return
        }
        
        guard let (session, request) = prepareRequest(method: HTTPMethod.POST, url: url, body: json) else {
            callback(APIError.invalidUrlError("Invalid URL '\(url)'"), nil)
            return
        }
        
        let task = session.dataTask(with: request) { (data, res, err) in
            if err != nil {
                callback(APIError.requestError(err!.localizedDescription), nil)
            } else if data != nil {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let dict = response as? [String: Any] {
                        if let message = dict["error"] as? String {
                            callback(APIError.responseError(message), nil)
                        } else {
                            callback(nil, dict)
                        }
                    } else {
                        callback(APIError.responseError("Invalid response"), nil)
                    }
                    
                } catch {
                    callback(APIError.responseError(error.localizedDescription), nil)
                }
            } else {
                callback(nil, nil)
            }
        }
        
        task.resume()
    }
    
    func simplePut(_ url: String, data: [String: Any], callback: @escaping SingleCallback) {
        var json: Data?
        
        do {
            json = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            callback(APIError.invalidJSONError(error.localizedDescription), nil)
            return
        }
        
        guard let (session, request) = prepareRequest(method: HTTPMethod.PUT, url: url, body: json) else {
            callback(APIError.invalidUrlError("Invalid URL '\(url)'"), nil)
            return
        }
        
        let task = session.dataTask(with: request) { (data, res, err) in
            if err != nil {
                callback(APIError.requestError(err!.localizedDescription), nil)
            } else if data != nil {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let dict = response as? [String: Any] {
                        if let message = dict["error"] as? String {
                            callback(APIError.responseError(message), nil)
                        } else {
                            callback(nil, dict)
                        }
                    } else {
                        callback(APIError.responseError("Invalid response"), nil)
                    }
                } catch {
                    callback(APIError.responseError(error.localizedDescription), nil)
                }
            } else {
                callback(nil, nil)
            }
        }
        
        task.resume()
    }
    
    func simpleDelete(_ url: String, callback: @escaping SingleCallback) {
        guard let (session, request) = prepareRequest(method: HTTPMethod.DELETE, url: url) else {
            callback(APIError.invalidUrlError("Invalid URL '\(url)'"), nil)
            return
        }
        
        let task = session.dataTask(with: request) { (data, res, err) in
            if err != nil {
                callback(APIError.requestError(err!.localizedDescription), nil)
            } else if data != nil {
                do {
                    let response = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let dict = response as? [String: Any] {
                        if let message = dict["error"] as? String {
                            callback(APIError.responseError(message), nil)
                        } else {
                            callback(nil, dict)
                        }
                    } else {
                        callback(APIError.responseError("Invalid response"), nil)
                    }
                } catch {
                    callback(APIError.responseError(error.localizedDescription), nil)
                }
            } else {
                callback(nil, nil)
            }
        }
        
        task.resume()
    }
    
    func mappedSource(_ src: Commitment) -> APISource {
        if let course = src as? Course {
            return courseMap.pairing(course)!
        } else if let tag = src as? Extracurricular {
            return tagMap.pairing(tag)!
        }
        
        return courseMap.pairs.first!.api
    }
    
    fileprivate func findSource(_ source: String) -> APISource? {
        let type = source.characterAt(index: 0)
        let id = source.substring(from: 2)
        
        switch type {
            
        case "c":
            for semester in semesters {
                for course in semester.courses {
                    if course.id == id {
                        return course
                    }
                }
            }
            return nil
            
        case "t":
            for tag in tags {
                if tag.id == id {
                    return tag
                }
            }
            return nil
            
        case "a":
            for assignment in assignments {
                if assignment.id == id {
                    return assignment
                }
            }
            return nil
            
        default:
            return nil
            
        }
    }
    
    fileprivate func findSources(_ sources: [String]) -> [APISource] {
        var out: [APISource] = []
        
        for source in sources {
            if let result = findSource(source) {
                out.append(result)
            }
        }
        
        return out
    }
    
    // MARK: - Semesters
    
    func getSemesters(completion: @escaping ArrayCallback) {
        simpleGet("users/\(user)/semesters", callback: completion)
    }
    
    func getSemester(_ semester: APISemester, completion: @escaping SingleCallback) {
        simpleGet("users/\(user)/semesters/\(semester.id)", callback: completion)
    }
    
    func createSemester(name: String, startDate: CalendarDay, endDate: CalendarDay, completion: @escaping SingleCallback) {
        let semester: [String: Any] = ["name": name,
                                       "start_date": API.dateFormatter.string(from: startDate.dateValue!),
                                       "end_date": API.dateFormatter.string(from: endDate.dateValue!)]
        
        simplePost("users/\(user)/semesters", data: semester, callback: completion)
    }
    
    func updateSemester(_ semester: APISemester, completion: @escaping SingleCallback) {
        let dict: [String: Any] = ["user": semester.user,
                                   "id": semester.id,
                                   "name": semester.name,
                                   "start_date": API.dateFormatter.string(from: semester.startDate.dateValue!),
                                   "end_date": API.dateFormatter.string(from: semester.endDate.dateValue!)]
        
        simplePost("users/\(user)/semesters/\(semester.id)", data: dict, callback: completion)
    }
    
    func deleteSemester(_ semester: APISemester, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/semesters/\(semester.id)", callback: completion)
    }
    
    // MARK: - Courses
    
    func getCourses(forSemester semester: APISemester, completion: @escaping ArrayCallback) {
        simpleGet("users/\(user)/semesters/\(semester.id)/courses", callback: completion)
    }
    
    func getCourse(_ course: APICourse, completion: @escaping SingleCallback) {
        simpleGet("users/\(user)/courses/\(course.id)", callback: completion)
    }
    
    func createCourse(name: String, descriptor: String, color: String, semester: String, completion: @escaping SingleCallback) {
        var course: [String: String] = ["name": name,
                                        "color": color,
                                        "semester": semester]
        
        if !descriptor.isEmpty {
            course["descriptor"] = descriptor
        }
        
        simplePost("users/\(user)/semesters/\(semester)/courses", data: course, callback: completion)
    }
    
    func updateCourse(_ course: APICourse, completion: @escaping SingleCallback) {
        var dict: [String: String] = ["user": course.user,
                                      "id": course.id,
                                      "name": course.name,
                                      "color": course.color,
                                      "semester": course.semester.id]
        
        if !course.descriptor.isEmpty {
            dict["descriptor"] = course.descriptor
        }
        
        simplePut("users/\(user)/courses/\(course.id)", data: dict, callback: completion)
    }
    
    func deleteCourse(_ course: APICourse, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/courses/\(course.id)", callback: completion)
    }
    
    // MARK: - Sections
    
    func getSections(forCourse course: String, completion: @escaping ArrayCallback) {
        simpleGet("users/\(user)/courses/\(course)/sections", callback: completion)
    }
    
    func getSection(_ section: APISection, completion: @escaping SingleCallback) {
        simpleGet("users/\(user)/sections/\(section.id)", callback: completion)
    }
    
    func createSection(name: String, course: String, location: String, startDate: CalendarDay, endDate: CalendarDay, startTime: ClockTime, endTime: ClockTime, completion: @escaping SingleCallback) {
        var section: [String: String] = ["name": name,
                                         "course": course,
                                         "start_date": API.dateFormatter.string(from: startDate.dateValue!),
                                         "end_date": API.dateFormatter.string(from: endDate.dateValue!),
                                         "start_time": API.timeFormatter.string(from: startTime.dateValue!),
                                         "end_time": API.timeFormatter.string(from: endTime.dateValue!)]
        
        if !location.isEmpty {
            section["location"] = location
        }
        
        simplePost("users/\(user)/courses/\(course)/sections", data: section, callback: completion)
    }
    
    func updateSection(_ section: APISection, completion: @escaping SingleCallback) {
        var dict: [String: String] = ["user": section.user,
                                      "id": section.id,
                                      "name": section.name,
                                      "course": section.course.id,
                                      "start_date": API.dateFormatter.string(from: section.startDate.dateValue!),
                                      "end_date": API.dateFormatter.string(from: section.endDate.dateValue!),
                                      "start_time": API.timeFormatter.string(from: section.startTime.dateValue!),
                                      "end_time": API.timeFormatter.string(from: section.endTime.dateValue!)]
        
        if !section.location.isEmpty {
            dict["location"] = section.location
        }
        
        simplePut("users/\(user)/sections/\(section.id)", data: dict, callback: completion)
    }
    
    func deleteSection(_ section: APISection, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/sections/\(section.id)", callback: completion)
    }
    
    // MARK: - Assessments
    
    func getAssessments(completion: @escaping ArrayCallback) {
        simpleGet("users/\(user)/assessments", callback: completion)
    }
    
    func getAssessment(_ assessment: APIAssessment, completion: @escaping SingleCallback) {
        simpleGet("users/\(user)/assessments/\(assessment.id)", callback: completion)
    }
    
    func createAssessment(name: String, location: String, date: CalendarDay, startTime: ClockTime, endTime: ClockTime, source: APISource?, completion: @escaping SingleCallback) {
        var assessment: [String: String] = ["name": name,
                                            "date": API.dateFormatter.string(from: date.dateValue!),
                                            "start_time": API.timeFormatter.string(from: startTime.dateValue!),
                                            "end_time": API.timeFormatter.string(from: endTime.dateValue!)]
        
        if !location.isEmpty {
            assessment["location"] = location
        }
        
        if let c = source as? APICourse {
            assessment["source"] = "c-\(c.id)"
        } else if let t = source as? APITag {
            assessment["source"] = "t-\(t.id)"
        }
        
        simplePost("users/\(user)/assessments", data: assessment, callback: completion)
    }
    
    func updateAssessment(_ assessment: APIAssessment, completion: @escaping SingleCallback) {
        var dict: [String: Any] = ["user": assessment.user,
                                   "id": assessment.id,
                                   "name": assessment.name,
                                   "date": API.dateFormatter.string(from: assessment.date.dateValue!),
                                   "start_time": API.timeFormatter.string(from: assessment.startTime.dateValue!),
                                   "end_time": API.timeFormatter.string(from: assessment.endTime.dateValue!)]
        
        if !assessment.location.isEmpty {
            dict["location"] = assessment.location
        }
        
        if let c = assessment.source as? APICourse {
            dict["source"] = "c-\(c.id)"
        } else if let t = assessment.source as? APITag {
            dict["source"] = "t-\(t.id)"
        }
        
        simplePut("users/\(user)/assessments/\(assessment.id)", data: dict, callback: completion)
    }
    
    func deleteAssessment(_ assessment: APIAssessment, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/assessments/\(assessment.id)", callback: completion)
    }
    
    // MARK: - Tags
    
    func getTags(completion: @escaping ArrayCallback) {
        simpleGet("users/\(user)/tags", callback: completion)
    }
    
    func getTag(_ tag: APITag, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/tags/\(tag.id)", callback: completion)
    }
    
    func createTag(text: String, color: String, completion: @escaping SingleCallback) {
        let tag: [String: String] = ["text": text,
                                     "color": color]
        
        simplePost("users/\(user)/tags", data: tag, callback: completion)
    }
    
    func updateTag(_ tag: APITag, completion: @escaping SingleCallback) {
        let dict: [String: Any] = ["user": tag.user,
                                   "id": tag.id,
                                   "text": tag.text,
                                   "color": tag.color]
        
        simplePut("users/\(user)/tags/\(tag.id)", data: dict, callback: completion)
    }
    
    func deleteTag(_ tag: APITag, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/tags/\(tag.id)", callback: completion)
    }
    
    // MARK: - Assignments
    
    func getAssignments(completion: @escaping ArrayCallback) {
        simpleGet("users/\(user)/assignments", callback: completion)
    }
    
    func getAssignment(_ assignment: APIAssignment, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/assignments/\(assignment.id)", callback: completion)
    }
    
    func createAssignment(name: String, userDescription: String, dueDate: DueDate, sources: [APISource], finished: Bool, dateFinished: CalendarDay?, completion: @escaping SingleCallback) {
        var assignment: [String : Any] = ["name": name,
                                          "finished": finished]
        
        if !userDescription.isEmpty {
            assignment["description"] = userDescription
        }
        
        if dateFinished != nil {
            assignment["date_finished"] = API.dateFormatter.string(from: dateFinished!.dateValue!)
        }
        
        if case let DueDate.specificDeadline(deadline) = dueDate {
            assignment["due_date"] = API.dateTimeFormatter.string(from: deadline.dateValue!)
        }
        
        if sources.count > 0 {
            var ids: [String] = []
            
            for source in sources {
                if let c = source as? APICourse {
                    ids.append("c-\(c.id)")
                } else if let t = source as? APITag {
                    ids.append("t-\(t.id)")
                }
            }
            
            assignment["sources"] = ids
        }
        
        simplePost("users/\(user)/assignments", data: assignment, callback: completion)
    }
    
    func updateAssignment(_ assignment: APIAssignment, completion: @escaping SingleCallback) {
        var dict: [String: Any] = ["user": assignment.user,
                                   "id": assignment.id,
                                   "name": assignment.name,
                                   "finished": assignment.finished]
        
        if !assignment.userDescription.isEmpty {
            dict["description"] = assignment.userDescription
        }
        
        if assignment.dateFinished != nil {
            dict["date_finished"] = API.dateFormatter.string(from: assignment.dateFinished!.dateValue!)
        }
        
        if case let DueDate.specificDeadline(deadline) = assignment.dueDate {
            dict["due_date"] = API.dateTimeFormatter.string(from: deadline.dateValue!)
        }
        
        if assignment.sources.count > 0 {
            var ids: [String] = []
            
            for source in assignment.sources {
                if let c = source as? APICourse {
                    ids.append("c-\(c.id)")
                } else if let t = source as? APITag {
                    ids.append("t-\(t.id)")
                }
            }
            
            dict["sources"] = ids
        }
        
        simplePut("users/\(user)/assignments/\(assignment.id)", data: dict, callback: completion)
    }
    
    func deleteAssignment(_ assignment: APIAssignment, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/assignments/\(assignment.id)", callback: completion)
    }
    
    // MARK: - Tasks
    
    func getTasks(completion: @escaping ArrayCallback) {
        simpleGet("users/\(user)/tasks", callback: completion)
    }
    
    func getTask(_ task: APITask, completion: @escaping SingleCallback) {
        simpleGet("users/\(user)/tasks/\(task.id)", callback: completion)
    }
    
    func createTask(name: String, userDescription: String, doDate: DueDate, priority: Int, sources: [APISource], finished: Bool, dateFinished: CalendarDay?, completion: @escaping SingleCallback) {
        var task: [String : Any] = ["name": name,
                                    "priority": priority,
                                    "finished": finished]
        
        if !userDescription.isEmpty {
            task["description"] = userDescription
        }
        
        if dateFinished != nil {
            task["date_finished"] = API.dateFormatter.string(from: dateFinished!.dateValue!)
        }
        
        if case let DueDate.specificDay(day) = doDate {
            task["do_date"] = API.dateFormatter.string(from: day.dateValue!)
        } else if case DueDate.asap = doDate {
            task["do_date"] = "asap"
        } else if case DueDate.eventually = doDate {
            task["do_date"] = "eventually"
        }
        
        if sources.count > 0 {
            var ids: [String] = []
            
            for source in sources {
                if let c = source as? APICourse {
                    ids.append("c-\(c.id)")
                } else if let a = source as? APIAssignment {
                    ids.append("a-\(a.id)")
                } else if let t = source as? APITag {
                    ids.append("t-\(t.id)")
                }
            }
            
            task["sources"] = ids
        }
        
        simplePost("users/\(user)/tasks", data: task, callback: completion)
    }
    
    func updateTask(_ task: APITask, completion: @escaping SingleCallback) {
        var dict: [String: Any] = ["user": task.user,
                                   "id": task.id,
                                   "name": task.name,
                                   "priority": task.priority,
                                   "finished": task.finished]
        
        if !task.userDescription.isEmpty {
            dict["description"] = task.userDescription
        }
        
        if task.dateFinished != nil {
            dict["date_finished"] = API.dateFormatter.string(from: task.dateFinished!.dateValue!)
        }
        
        if case let DueDate.specificDay(day) = task.doDate {
            dict["do_date"] = API.dateFormatter.string(from: day.dateValue!)
        } else if case DueDate.asap = task.doDate {
            dict["do_date"] = "asap"
        } else if case DueDate.eventually = task.doDate {
            dict["do_date"] = "eventually"
        }
        
        if task.sources.count > 0 {
            var ids: [String] = []
            
            for source in task.sources {
                if let c = source as? APICourse {
                    ids.append("c-\(c.id)")
                } else if let a = source as? APIAssignment {
                    ids.append("a-\(a.id)")
                } else if let t = source as? APITag {
                    ids.append("t-\(t.id)")
                }
            }
            
            dict["sources"] = ids
        }
        
        simplePut("users/\(user)/tasks/\(task.id)", data: dict, callback: completion)
    }
    
    func deleteTask(_ task: APITask, completion: @escaping SingleCallback) {
        simpleDelete("users/\(user)/tasks/\(task.id)", callback: completion)
    }
    
}
