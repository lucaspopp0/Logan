//
//  FetchManager.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/22/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

enum FetcherState: Int {
    case idle = 0
    case fetching = 1
    case done = 2
    case cancelled = 3
    case failed = 4
}

class FetchManager {
    
    func fetchAllData() {
        var failed: Bool = false
        var finished: Bool = false
        var semesters: [Semester] = []
        
        // Fetch semesters and all that first
        API.shared.getSemesters { (beSemesters) in
            guard let beSemesters = beSemesters else { return failed = true }
            
            API.shared.getCourses { (beCourseMap) in
                guard let beCourseMap = beCourseMap else { return failed = true }
                
                API.shared.getSections { (beSectionMap) in
                    guard let beSectionMap = beSectionMap else { return failed = true }
                    
                    // Loop through semester blobs
                    for semesterBlob in beSemesters {
                        guard let semester = Semester(blob: semesterBlob) else {
                            print("Error parsing semester")
                            continue
                        }
                        
                        semesters.append(semester)
                        
                        // Loop through all SIDs
                        for sid in beCourseMap.keys {
                            if sid == semester.id {
                                // If match, loop through all course blobs
                                for courseBlob in beCourseMap[sid]! {
                                    guard let course = Course(blob: courseBlob) else {
                                        print("Error parsing course")
                                        continue
                                    }
                                    
                                    semester.courses.append(course)
                                    course.semester = semester
                                    
                                    for cid in beSectionMap.keys {
                                        if cid == course.id {
                                            for sectionBlob in beSectionMap[cid]! {
                                                guard let section = Section(blob: sectionBlob) else {
                                                    print("Error parsing section")
                                                    continue
                                                }
                                                
                                                course.sections.append(section)
                                                section.course = course
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    print("Finished fetching data")
                    return finished = true
                }
            }
        }
        
        while !failed && !finished {}
        
        if failed {
            print("Failed to fetch schedule data")
            return
        }
        
        var assignments: [Assignment] = []
        
        API.shared.getAssignments { (beAssignments) in
            guard let beAssignments = beAssignments else { return print("Error fetching assignments") }
            
            for blob in beAssignments {
                if let assignment = Assignment(blob: blob) {
                    assignments.append(assignment)
                }
            }
        }
    }
    
}

//class FetchManager2 {
//
//    private static let MAX_RETRIES: Int = 2
//
//    private var retryCount: Int = 0
//    var fetchFailed: Bool = false
//
//    private var dataManager: DataManager
//
//    private(set) var isRetrying: Bool = false
//    private var retryTimer: Timer?
//
////    private var semesterFetcher: Fetcher!
////    private var courseFetcher: Fetcher!
////    private var sectionFetcher: Fetcher!
////    private var assignmentFetcher: Fetcher!
////    private var taskFetcher: Fetcher!
//
////    private var fetchers: [Fetcher] {
////        get {
////            return [semesterFetcher, courseFetcher, sectionFetcher, assignmentFetcher, taskFetcher]
////        }
////    }
//
//    private var compilationCallback: (([Semester], [Assignment], [Task]) -> Void)
//    private var failureCallback: ((Error) -> Void)
//
//    var state: FetcherState {
//        get {
//            var allDone = true
//            var allIdle = true
//
//            for fetcher in fetchers {
//                if fetcher.state != .done { allDone = false }
//                if fetcher.state != .idle { allIdle = false }
//
//                if fetcher.state == .failed { return .failed }
//                else if fetcher.state == .cancelled { return .cancelled }
//                else if fetcher.state == .fetching { return .fetching }
//            }
//
//            if allDone { return .done }
//            else if allIdle { return .idle }
//            else { return .failed }
//        }
//    }
//
//    init(dataManager: DataManager, compilationCallback: @escaping (([Semester], [Assignment], [Task]) -> Void), failureCallback: @escaping ((Error) -> Void)) {
//        self.dataManager = dataManager
//
//        self.compilationCallback = compilationCallback
//        self.failureCallback = failureCallback
//
//        semesterFetcher = Fetcher(recordType: "Semester", manager: self)
//        courseFetcher = Fetcher(recordType: "Course", manager: self)
//        sectionFetcher = Fetcher(recordType: "Class", manager: self)
//        assignmentFetcher = Fetcher(recordType: "Assignment", manager: self)
//        taskFetcher = Fetcher(recordType: "Task", manager: self)
//    }
//
//    func makeQueries(createdBy creator: CKReference) {
//        for fetcher in fetchers {
//            fetcher.makeQuery(createdBy: creator, errorHandler: { (error) in
//                if let cloudError = error as? CKError, cloudError.code == CKError.Code.requestRateLimited,
//                    let retryAfter = cloudError.userInfo[CKErrorRetryAfterKey] as? TimeInterval, self.retryCount < FetchManager.MAX_RETRIES {
//                    self.retryQueries(in: retryAfter, createdBy: creator)
//                } else {
//                    self.failureCallback(error)
//                }
//
//                for f in self.fetchers {
//                    if f !== fetcher {
//                        fetcher.cancelQuery()
//                    }
//                }
//            })
//        }
//    }
//
//    private func retryQueries(in timeout: TimeInterval, createdBy creator: CKReference) {
//        retryCount += 1
//        isRetrying = true
//        retryTimer?.invalidate()
//        retryTimer = Timer(fire: Date(timeIntervalSinceNow: timeout), interval: 0, repeats: false, block: { (timer) in
//            self.isRetrying = false
//            self.makeQueries(createdBy: creator)
//            timer.invalidate()
//        })
//    }
//
//    func attemptToCompileFetchedRecords() {
//        if state == .done {
//            Console.shared.print("Finished fetching data. Compiling records.")
//
//            let sections: [Section] = sectionFetcher.records.map(Section.init(record:))
//
//            let courses: [Course] = courseFetcher.records.map { (record) -> Course in
//                return Course(record: record, classes: sections, exams: exams)
//            }
//
//            var semesters: [Semester] = semesterFetcher.records.map { (record) -> Semester in
//                return Semester(record: record, courses: courses)
//            }
//
//            let assignments: [Assignment] = assignmentFetcher.records.map { (record) -> Assignment in
//                return Assignment(record: record, reminders: reminders, semesters: semesters, extracurriculars: extracurriculars)
//            }
//
//            let tasks: [Task] = taskFetcher.records.map { (record) -> Task in
//                return Task(record: record, assignments: assignments, semesters: semesters, extracurriculars: extracurriculars)
//            }
//
//            semesters.sort { (semester1, semester2) -> Bool in
//                return semester1.endDate > semester2.endDate
//            }
//
//            compilationCallback(semesters, assignments, tasks)
//        }
//    }
//
//}

//class Fetcher {
//
//    var fetchManager: FetchManager
//    var recordType: String
//
//    var records: [CKRecord] = []
//    var state: FetcherState = .idle
//
//    private var queryResults: [CKRecord] = []
//    private var database: CKDatabase?
//    private var completionHandler: ((_ results: [CKRecord]?, _ error: Error?) -> Void)?
//
//    init(recordType: String, manager: FetchManager) {
//        self.recordType = recordType
//        self.fetchManager = manager
//
//        database = manager.privateContainer.privateCloudDatabase
//    }
//
//    func makeQuery(createdBy creator: CKReference, errorHandler: @escaping (_ error: Error) -> Void) {
//        if state == .fetching { return }
//
//        state = .fetching
//        queryResults.removeAll()
//
//        self.completionHandler = { (results, error) in
//            if self.state != .cancelled {
//                if let queryError = error {
//                    self.state = .failed
//                    errorHandler(queryError)
//                } else if let fetchedResults = results {
//                    self.records = fetchedResults
//                    self.state = .done
//                    self.fetchManager.attemptToCompileFetchedRecords()
//                }
//            }
//        }
//
//        let creatorPredicate = NSPredicate(format: "creatorUserRecordID == %@", creator)
//        let basicQuery = CKQuery(recordType: recordType, predicate: creatorPredicate)
//        let operation = CKQueryOperation(query: basicQuery)
//
//        operation.qualityOfService = QualityOfService.userInitiated
//        operation.recordFetchedBlock = self.recordFetched(_:)
//        operation.queryCompletionBlock = self.makeSingleQueryCompletionHandler(errorHandler: errorHandler)
//
//        database?.add(operation)
//    }
//
//    func cancelQuery() {
//        state = .cancelled
//    }
//
//    private func recordFetched(_ record: CKRecord) {
//        queryResults.append(record)
//    }
//
//    private func makeSingleQueryCompletionHandler(errorHandler: @escaping (_ error: Error) -> Void) -> ((CKQueryCursor?, Error?) -> Void) {
//        return { (cursor, error) in
//            if let queryCursor = cursor, self.state == .fetching {
//                let continuingOperation = CKQueryOperation(cursor: queryCursor)
//
//                continuingOperation.qualityOfService = QualityOfService.userInitiated
//                continuingOperation.recordFetchedBlock = self.recordFetched(_:)
//                continuingOperation.queryCompletionBlock = self.makeSingleQueryCompletionHandler(errorHandler: errorHandler)
//
//                self.database?.add(continuingOperation)
//            } else {
//                self.completionHandler?(self.queryResults, error)
//            }
//        }
//    }
//
//}
