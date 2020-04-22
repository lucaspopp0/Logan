//
//  API.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/21/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation

typealias Blob = [String: Any]

class API: NSObject {
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    struct ResponseError: Error, LocalizedError {
        let message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        var errorDescription: String? {
            return message
        }
    }
    
    struct RequestData {
        let method: HTTPMethod
        let path: String
    }
    
    static let shared = API()
    lazy var BASE_URL = URL(string: "http://logan-backend.us-west-2.elasticbeanstalk.com")
    lazy var baseConfig: URLSessionConfiguration = makeBasicConfig()
    
    var authEstablished: Bool = false
    var currentUid: String?
    
    var unauthedSession: URLSession!
    var authedSession: URLSession?
    
    override init() {
        super.init()
        
        unauthedSession = URLSession(configuration: baseConfig)
    }
    
    private func makeBasicConfig() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["Client-Type": "ios",
                                        "Content-Type": "application/json"]
        return config
    }
    
    private func perror(_ request: RequestData, _ message: String) {
        print("Request error (\(request.method.rawValue) \(request.path)): \(message)")
    }
    
    private func httpTask(method: HTTPMethod, path: String, body: Data? = nil, ignoreAuth: Bool = false, _ completionHandler: @escaping (RequestData, Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let requestData = RequestData(method: method, path: path)
        
        // Display error if the appropriate session is nil
        if ignoreAuth && unauthedSession == nil {
            perror(requestData, "No valid unauthed session exists")
            return nil
        } else if !ignoreAuth && authedSession == nil {
            perror(requestData, "No valid authed session exists")
            return nil
        }
        
        let session = ignoreAuth ? unauthedSession! : authedSession!
        
        // Add the path to the base URL
        guard let fullUrl = URL(string: path, relativeTo: BASE_URL) else {
            perror(requestData, "Invalid URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: fullUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        
        return session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if error != nil {
                return completionHandler(requestData, data, urlResponse, error)
            } else if let httpResponse: HTTPURLResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let message = data != nil ? String(data: data!, encoding: .utf8) ?? "Unknown error" : "Unknown error"
                return completionHandler(requestData, data, urlResponse, ResponseError(message))
            } else {
                return completionHandler(requestData, data, urlResponse, error)
            }
        }
    }
    
    private func basicGet<T>(endpoint: String, _ completion: @escaping (T?) -> Void) {
        guard let task = httpTask(method: .GET, path: endpoint, { (request, data, httpResponse, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(nil)
            }
            
            guard let data = data else {
                self.perror(request, "No response data")
                return completion(nil)
            }
            
            if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? T {
                return completion(response)
            } else {
                self.perror(request, "Improper response format")
                return completion(nil)
            }
        }) else {
            return completion(nil)
        }
        
        task.resume()
    }
    
    func establishAuth(_ idToken: String, _ completion: @escaping (Bool, Bool) -> Void) {
        guard let body = try? JSONSerialization.data(withJSONObject: ["idToken": idToken]) else {
            print("Error serializing JSON for auth handshake")
            return completion(false, false)
        }
        
        guard let task = httpTask(method: .POST, path: "/auth", body: body, ignoreAuth: true, { (request, data, httpResponse, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(false, false)
            }
            
            guard let data = data else {
                self.perror(request, "Empty response")
                return completion(false, false)
            }
            
            if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let bearer = response["bearer"] as? String {
                print("Fetched bearer. Auth established with backend")
                let authedConfig = self.makeBasicConfig()
                authedConfig.httpAdditionalHeaders!["Authorization"] = "Bearer \(bearer)"
                self.authedSession = URLSession(configuration: authedConfig)
                self.authEstablished = true
                
                if let user = response["user"] as? Blob, let uid = user["id"] as? String {
                    print(user["email"] as! String)
                    self.currentUid = uid
                    completion(true, true)
                } else {
                    completion(true, false)
                }
            } else {
                print(String(data: data, encoding: .utf8) ?? "Unable to fetch bearer token. Reason unknown.")
                completion(false, false)
            }
        }) else {
            return completion(false, false)
        }
        
        print("Attempting to fetch bearer token")
        task.resume()
    }
    
    func cleanUser(_ completion: @escaping (Bool) -> Void) {
        guard let task = httpTask(method: .POST, path: "/users/clean", { (request, data, httpResponse, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(false)
            }
            
            completion(true)
        }) else {
            return completion(false)
        }
        
        task.resume()
    }
    
    private func completion(_ prog: Float, _ total: Float) -> String {
        let perc = floor(prog / total * 1000.0) / 10.0
        
        if perc < 10.0 {
            return "  \(perc)%"
        } else if perc > 99.9 {
            return "\(perc)%"
        } else {
            return " \(perc)%"
        }
    }
    
    private func prog(i: Float, total: Float, prefix: String, name: String) {
        print("\(completion(i, total)) | \(prefix): \(name) sent")
    }
    
    func transmitData() {
        var cleanFlag = false
        var failFlag = false
        cleanUser { (success) in
            if success {
                cleanFlag = true
                print("User cleaned")
            } else {
                print("Unable to clean user. Will not transmit data")
                failFlag = true
                cleanFlag = true
            }
        }
        
        while !cleanFlag {}
        if failFlag { return }
        
        let deadlineCutoff = CalendarDay(month: 9, day: 1, year: 2018)!
        
        var semestersMap: [String: String] = [String: String]()
        var coursesMap: [String: String] = [String: String]()
        var assignmentsMap: [String: String] = [String: String]()
        
        var allSemesters: [Semester] = []
        var allAssignments: [Assignment] = []
        var allTasks: [Task] = []
        
        allSemesters.append(contentsOf: DataManager.shared.semesters.filter({ (semester) -> Bool in
            return semester.endDate >= deadlineCutoff
        }))
        
        allAssignments.append(contentsOf: DataManager.shared.assignments.filter({ (assignment) -> Bool in
            switch assignment.dueDate {
            case .specificDeadline(let deadline):
                return deadline.day >= deadlineCutoff
            case .specificDay(let day):
                return day >= deadlineCutoff
            default:
                return true
            }
        }))
        
        allTasks.append(contentsOf: DataManager.shared.tasks.filter({ (task) -> Bool in
            switch task.dueDate {
            case .specificDeadline(let deadline):
                return deadline.day >= deadlineCutoff
            case .specificDay(let day):
                return day >= deadlineCutoff
            default:
                return true
            }
        }))
        
        var totalSemesters: Int = allSemesters.count
        var totalCourses: Int = 0
        var totalSections: Int = 0
        var totalAssignments: Int = allAssignments.count
        var totalTasks: Int = allTasks.count
        
        for semester in allSemesters {
            totalCourses += semester.courses.count
            
            for course in semester.courses {
                totalSections += course.classes.count
            }
        }
        
        var totalCount: Float = Float(totalSections + totalCourses + totalSections + totalAssignments + totalTasks)
        var i: Float = 0.0

        var semesterFlag: Bool = true
        while semesterFlag && !allSemesters.isEmpty {
            let nextSemester = allSemesters.removeFirst()
            i += 1

            let semesterJson: Blob = ["name": nextSemester.name,
                                      "startDate": nextSemester.startDate.stringValue,
                                      "endDate": nextSemester.endDate.stringValue]
            
            guard let semBody = try? JSONSerialization.data(withJSONObject: semesterJson) else {
                print("Error serializing JSON for semester")
                print(semesterJson)
                continue
            }
            
            var semesterId: String?
            guard let task = httpTask(method: .POST, path: "/semesters", body: semBody, { (request, data, httpResponse, error) in
                if let error = error {
                    self.perror(request, error.localizedDescription)
                    semesterFlag = true
                    return
                }
                
                guard let data = data else {
                    self.perror(request, "Empty response")
                    semesterFlag = true
                    return
                }
                
                if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let sid = response["sid"] as? String {
                    semestersMap["\(nextSemester.ID)\(nextSemester.name)"] = sid
                    semesterId = sid
                    semesterFlag = true
                } else {
                    self.perror(request, "Serialization error")
                    semesterFlag = true
                }
            }) else {
                semesterFlag = true
                continue
            }

            semesterFlag = false
            task.resume()
            
            while !semesterFlag {}
            
            prog(i: i, total: totalCount, prefix: "SEM", name: nextSemester.name)
            
            guard let sid = semesterId else { continue }
            
            var courseFlag: Bool = true
            var courses: [Course] = []
            courses.append(contentsOf: nextSemester.courses)
            
            while courseFlag && !courses.isEmpty {
                let nextCourse = courses.removeFirst()
                i += 1
                
                var courseJson: Blob = ["sid": sid,
                                        "name": nextCourse.name,
                                        "color": nextCourse.color.hexString]
                
                if !nextCourse.nickname.isEmpty {
                    courseJson["nickname"] = nextCourse.nickname
                }
                
                if !nextCourse.descriptor.isEmpty {
                    courseJson["descriptor"] = nextCourse.descriptor
                }
                
                guard let courseBody = try? JSONSerialization.data(withJSONObject: courseJson) else {
                    print("Error serializing JSON for course")
                    print(courseJson)
                    continue
                }
                
                var courseId: String?
                guard let courseTask = httpTask(method: .POST, path: "/courses", body: courseBody, { (request, data, httpResponse, error) in
                    if let error = error {
                        self.perror(request, error.localizedDescription)
                        courseFlag = true
                        return
                    }
                    
                    guard let data = data else {
                        self.perror(request, "Empty response")
                        courseFlag = true
                        return
                    }
                    
                    if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let cid = response["cid"] as? String {
                        coursesMap["\(nextCourse.ID)\(nextCourse.name)"] = cid
                        courseId = cid
                        courseFlag = true
                    } else {
                        self.perror(request, "Serialization error")
                        courseFlag = true
                    }
                }) else {
                    courseFlag = true
                    continue
                }
                
                courseFlag = false
                courseTask.resume()
                
                while !courseFlag {}
                
                prog(i: i, total: totalCount, prefix: "CRS", name: nextCourse.name)
                
                guard let cid = courseId else { continue }
                
                var sectionFlag = true
                var sections: [Class] = []
                sections.append(contentsOf: nextCourse.classes)
                
                while sectionFlag && !sections.isEmpty {
                    let nextSection = sections.removeFirst()
                    i += 1
                    
                    var secJson: Blob = ["cid": cid,
                                         "name": nextSection.title,
                                         "start": nextSection.start,
                                         "end": nextSection.end,
                                         "weeklyRepeat": nextSection.weeklyRepeat]
                    
                    var days: [Int] = []
                    for dow in nextSection.daysOfWeek {
                        days.append(dow.rawValue)
                    }
                    days.sort()
                    
                    var eventual = ""
                    for day in days {
                        eventual += "\(day)"
                    }
                    
                    secJson["daysOfWeek"] = eventual
                    
                    if nextSection.location != nil {
                        secJson["location"] = nextSection.location!
                    }
                    
                    guard let secBody = try? JSONSerialization.data(withJSONObject: secJson) else {
                        print("Error serializing JSON for section")
                        print(secJson)
                        continue
                    }
                    
                    var secId: String?
                    guard let sectionTask = httpTask(method: .POST, path: "/sections", body: secBody, { (request, data, httpResponse, error) in
                        if let error = error {
                            self.perror(request, error.localizedDescription)
                            sectionFlag = true
                            return
                        }
                        
                        guard let data = data else {
                            self.perror(request, "Empty response")
                            sectionFlag = true
                            return
                        }
                        
                        if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let secid = response["secid"] as? String {
                            secId = secid
                            sectionFlag = true
                        } else {
                            self.perror(request, "Serialization error")
                            sectionFlag = true
                        }
                    }) else {
                        sectionFlag = true
                        continue
                    }
                    
                    sectionFlag = false
                    sectionTask.resume()
                    
                    while !sectionFlag {}
                    
                    prog(i: i, total: totalCount, prefix: "SEC", name: nextSection.title)
                }
            }
        }
        
        print("-----------------------")
        print("Done adding commitments")
        print("-----------------------")
        
        var assignmentFlag = true
        while assignmentFlag && !allAssignments.isEmpty {
            let next = allAssignments.removeFirst()
            i += 1
            
            if next.title.isEmpty { continue }
            
            var json: Blob = ["title": next.title]
            
            switch next.dueDate {
            case .asap:
                json["dueDate"] = "asap"
                break
            case .eventually:
                json["dueDate"] = "eventually"
                break
            case .specificDay(let day):
                json["dueDate"] = day.stringValue
                break
            case .specificDeadline(let deadline):
                json["dueDate"] = deadline.day.stringValue
                break
            default:
                break
            }
            
            if !next.userDescription.isEmpty {
                json["description"] = next.userDescription
            }
            
            if let course = next.commitment as? Course, let cid = coursesMap["\(course.ID)\(course.name)"] {
                json["commitmentId"] = cid
            }
            
            guard let body = try? JSONSerialization.data(withJSONObject: json) else {
                print("Error serializing JSON for assignment")
                print(json)
                continue
            }
            
            var assignmentId: String?
            guard let task = httpTask(method: .POST, path: "/assignments", body: body, { (request, data, httpResponse, error) in
                if let error = error {
                    self.perror(request, error.localizedDescription)
                    assignmentFlag = true
                    return
                }
                
                guard let data = data else {
                    self.perror(request, "Empty response")
                    assignmentFlag = true
                    return
                }
                
                if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let aid = response["aid"] as? String {
                    assignmentsMap["\(next.ID)\(next.title)"] = aid
                    assignmentId = aid
                    assignmentFlag = true
                } else {
                    self.perror(request, "Serialization error")
                    assignmentFlag = true
                }
            }) else {
                assignmentFlag = true
                continue
            }
            
            assignmentFlag = false
            task.resume()
            
            while !assignmentFlag {}
            prog(i: i, total: totalCount, prefix: "ASS", name: next.title)
        }
        
        print("-----------------------")
        print("Done adding assignments")
        print("-----------------------")
        
        var taskFlag = true
        while taskFlag && !allTasks.isEmpty {
            let next = allTasks.removeFirst()
            i += 1
            
            if next.title.isEmpty { continue }
            
            var json: Blob = ["title": next.title,
                              "priority": next.priority.rawValue - 1,
                              "completed": next.completed]
            
            switch next.dueDate {
            case .asap:
                json["dueDate"] = "asap"
                break
            case .eventually:
                json["dueDate"] = "eventually"
                break
            case .specificDay(let day):
                json["dueDate"] = day.stringValue
                break
            case .specificDeadline(let deadline):
                json["dueDate"] = deadline.day.stringValue
                break
            default:
                break
            }
            
            if !next.userDescription.isEmpty {
                json["description"] = next.userDescription
            }
            
            if let assignment = next.relatedAssignment, let aid = assignmentsMap["\(assignment.ID)\(assignment.title)"] {
                json["relatedAid"] = aid
            }
            
            if let course = next.commitment as? Course, let cid = coursesMap["\(course.ID)\(course.name)"] {
                json["commitmentId"] = cid
            }
            
            if let completionDate = next.completionDate {
                json["completionDate"] = completionDate.stringValue
            }
            
            guard let body = try? JSONSerialization.data(withJSONObject: json) else {
                print("Error serializing JSON for task")
                print(json)
                continue
            }
            
            guard let task = httpTask(method: .POST, path: "/tasks", body: body, { (request, data, httpResponse, error) in
                if let error = error {
                    self.perror(request, error.localizedDescription)
                    taskFlag = true
                    return
                }
                
                guard let data = data else {
                    self.perror(request, "Empty response")
                    taskFlag = true
                    return
                }
                
                if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let tid = response["tid"] as? String {
                    taskFlag = true
                } else {
                    self.perror(request, "Serialization error")
                    taskFlag = true
                }
            }) else {
                taskFlag = true
                continue
            }
            
            taskFlag = false
            task.resume()
            
            while !taskFlag {}
            prog(i: i, total: totalCount, prefix: "TSK", name: next.title)
        }
        
        print("+------+")
        print("| Done |")
        print("+------+")
    }
    
}
