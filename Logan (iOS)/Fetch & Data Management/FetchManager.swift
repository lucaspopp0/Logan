//
//  FetchManager.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/22/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import CloudKit

enum FetcherState: Int {
    case idle = 0
    case fetching = 1
    case done = 2
    case cancelled = 3
    case failed = 4
}

class FetchManager {
    
    private static let MAX_RETRIES: Int = 2
    
    private var retryCount: Int = 0
    var fetchFailed: Bool = false
    
    private var dataManager: DataManager
    
    internal let defaultContainer = CKContainer.default()
    internal let privateContainer = CKContainer(identifier: "iCloud.com.ppopsacul.TodoContainer")
    
    private(set) var isRetrying: Bool = false
    private var retryTimer: Timer?
    
    private var extracurricularFetcher: Fetcher!
    private var repeatingEventFetcher: Fetcher!
    private var singleEventFetcher: Fetcher!
    private var semesterFetcher: Fetcher!
    private var courseFetcher: Fetcher!
    private var classFetcher: Fetcher!
    private var examFetcher: Fetcher!
    private var assignmentFetcher: Fetcher!
    private var taskFetcher: Fetcher!
    private var reminderFetcher: Fetcher!
    
    private var fetchers: [Fetcher] {
        get {
            return [extracurricularFetcher, repeatingEventFetcher, singleEventFetcher, semesterFetcher, courseFetcher, classFetcher, examFetcher, assignmentFetcher, taskFetcher, reminderFetcher]
        }
    }
    
    private var compilationCallback: (([Semester], [Extracurricular], [Assignment], [Task]) -> Void)
    private var failureCallback: ((Error) -> Void)
    
    var state: FetcherState {
        get {
            var allDone = true
            var allIdle = true
            
            for fetcher in fetchers {
                if fetcher.state != .done { allDone = false }
                if fetcher.state != .idle { allIdle = false }
                
                if fetcher.state == .failed { return .failed }
                else if fetcher.state == .cancelled { return .cancelled }
                else if fetcher.state == .fetching { return .fetching }
            }
            
            if allDone { return .done }
            else if allIdle { return .idle }
            else { return .failed }
        }
    }
    
    init(dataManager: DataManager, compilationCallback: @escaping (([Semester], [Extracurricular], [Assignment], [Task]) -> Void), failureCallback: @escaping ((Error) -> Void)) {
        self.dataManager = dataManager
        
        self.compilationCallback = compilationCallback
        self.failureCallback = failureCallback
        
        extracurricularFetcher = Fetcher(recordType: "Extracurricular", manager: self)
        repeatingEventFetcher = Fetcher(recordType: "RepeatingEvent", manager: self)
        singleEventFetcher = Fetcher(recordType: "SingleEvent", manager: self)
        semesterFetcher = Fetcher(recordType: "Semester", manager: self)
        courseFetcher = Fetcher(recordType: "Course", manager: self)
        classFetcher = Fetcher(recordType: "Class", manager: self)
        examFetcher = Fetcher(recordType: "Exam", manager: self)
        assignmentFetcher = Fetcher(recordType: "Assignment", manager: self)
        taskFetcher = Fetcher(recordType: "Task", manager: self)
        reminderFetcher = Fetcher(recordType: "Reminder", manager: self)
    }
    
    func makeQueries(createdBy creator: CKReference) {
        for fetcher in fetchers {
            fetcher.makeQuery(createdBy: creator, errorHandler: { (error) in
                if let cloudError = error as? CKError, cloudError.code == CKError.Code.requestRateLimited,
                    let retryAfter = cloudError.userInfo[CKErrorRetryAfterKey] as? TimeInterval, self.retryCount < FetchManager.MAX_RETRIES {
                    self.retryQueries(in: retryAfter, createdBy: creator)
                } else {
                    self.failureCallback(error)
                }
                
                for f in self.fetchers {
                    if f !== fetcher {
                        fetcher.cancelQuery()
                    }
                }
            })
        }
    }
    
    private func retryQueries(in timeout: TimeInterval, createdBy creator: CKReference) {
        retryCount += 1
        isRetrying = true
        retryTimer?.invalidate()
        retryTimer = Timer(fire: Date(timeIntervalSinceNow: timeout), interval: 0, repeats: false, block: { (timer) in
            self.isRetrying = false
            self.makeQueries(createdBy: creator)
            timer.invalidate()
        })
    }
    
    func attemptToCompileFetchedRecords() {
        if state == .done {
            Console.shared.print("Finished fetching data. Compiling records.")
            
            var events: [Event] = singleEventFetcher.records.map(SingleEvent.init(record:))
            events.append(contentsOf: repeatingEventFetcher.records.map(RepeatingEvent.init(record:)))
            
            let extracurriculars: [Extracurricular] = extracurricularFetcher.records.map { (record) -> Extracurricular in
                return Extracurricular(record: record, events: events)
            }
            
            let classes: [Class] = classFetcher.records.map(Class.init(record:))
            let exams: [Exam] = examFetcher.records.map(Exam.init(record:))
            
            let courses: [Course] = courseFetcher.records.map { (record) -> Course in
                return Course(record: record, classes: classes, exams: exams)
            }
            
            var semesters: [Semester] = semesterFetcher.records.map { (record) -> Semester in
                return Semester(record: record, courses: courses)
            }
            
            let reminders: [Reminder] = reminderFetcher.records.map(Reminder.init(record:))
            
            let assignments: [Assignment] = assignmentFetcher.records.map { (record) -> Assignment in
                return Assignment(record: record, reminders: reminders, semesters: semesters, extracurriculars: extracurriculars)
            }
            
            let tasks: [Task] = taskFetcher.records.map { (record) -> Task in
                return Task(record: record, assignments: assignments, semesters: semesters, extracurriculars: extracurriculars)
            }
            
            semesters.sort { (semester1, semester2) -> Bool in
                return semester1.endDate > semester2.endDate
            }
            
            compilationCallback(semesters, extracurriculars, assignments, tasks)
        }
    }
    
}

class Fetcher {
    
    var fetchManager: FetchManager
    var recordType: String
    
    var records: [CKRecord] = []
    var state: FetcherState = .idle
    
    private var queryResults: [CKRecord] = []
    private var database: CKDatabase?
    private var completionHandler: ((_ results: [CKRecord]?, _ error: Error?) -> Void)?
    
    init(recordType: String, manager: FetchManager) {
        self.recordType = recordType
        self.fetchManager = manager
        
        database = manager.privateContainer.privateCloudDatabase
    }
    
    func makeQuery(createdBy creator: CKReference, errorHandler: @escaping (_ error: Error) -> Void) {
        if state == .fetching { return }
        
        state = .fetching
        queryResults.removeAll()
        
        self.completionHandler = { (results, error) in
            if self.state != .cancelled {
                if let queryError = error {
                    self.state = .failed
                    errorHandler(queryError)
                } else if let fetchedResults = results {
                    self.records = fetchedResults
                    self.state = .done
                    self.fetchManager.attemptToCompileFetchedRecords()
                }
            }
        }
        
        let creatorPredicate = NSPredicate(format: "creatorUserRecordID == %@", creator)
        let basicQuery = CKQuery(recordType: recordType, predicate: creatorPredicate)
        let operation = CKQueryOperation(query: basicQuery)
        
        operation.qualityOfService = QualityOfService.userInitiated
        operation.recordFetchedBlock = self.recordFetched(_:)
        operation.queryCompletionBlock = self.makeSingleQueryCompletionHandler(errorHandler: errorHandler)
        
        database?.add(operation)
    }
    
    func cancelQuery() {
        state = .cancelled
    }
    
    private func recordFetched(_ record: CKRecord) {
        queryResults.append(record)
    }
    
    private func makeSingleQueryCompletionHandler(errorHandler: @escaping (_ error: Error) -> Void) -> ((CKQueryCursor?, Error?) -> Void) {
        return { (cursor, error) in
            if let queryCursor = cursor, self.state == .fetching {
                let continuingOperation = CKQueryOperation(cursor: queryCursor)
                
                continuingOperation.qualityOfService = QualityOfService.userInitiated
                continuingOperation.recordFetchedBlock = self.recordFetched(_:)
                continuingOperation.queryCompletionBlock = self.makeSingleQueryCompletionHandler(errorHandler: errorHandler)
                
                self.database?.add(continuingOperation)
            } else {
                self.completionHandler?(self.queryResults, error)
            }
        }
    }
    
}

