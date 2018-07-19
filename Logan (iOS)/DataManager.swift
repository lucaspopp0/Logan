//
//  DataManager.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation
import CloudKit
import UIKit.UIColor

// An enum describing the type of event sent by a data manager
enum DMLoadingEventType: Int {
    
    case start = 0
    case end = 1
    case error = 2
    
}

// An enum describing the app's connection to iCloud
enum DMCloudConnectionStatus: Int {
    
    case ready = 0
    case fetching = 1
    case error = 2
    
}

// A protocol to be implemented that allows subscribing to the loading events of a particular data manager
protocol DMListener: AnyObject {
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType)
    
}

// NOTE: The following code observes changes to the iCloud account status

class DataManager: NSObject {
    
    static var shared: DataManager = DataManager()
    
    private var listeners: [DMListener] = []
    
    var currentCloudStatus: DMCloudConnectionStatus = DMCloudConnectionStatus.fetching
    
    var isSavingData: Bool {
        get {
            return recordsToProcess.count > 0
        }
    }
    
    private var recordsToProcess: [CKRecordID] = []
    
    private var updateTimer: UpdateTimer!
    
    var currentSemester: Semester?
    var currentCourse: Course? {
        get {
            let today = CalendarDay(date: Date())
            let now = ClockTime(date: Date())
            let currentWeekDay = DayOfWeek.forDate(Date())
            
            for semester in semesters {
                for course in semester.courses {
                    for courseClass in course.classes {
                        if courseClass.startDate <= today && courseClass.endDate >= today && courseClass.daysOfWeek.contains(currentWeekDay) {
                            if courseClass.startTime <= now && courseClass.endTime >= now {
                                return course
                            }
                        }
                    }
                }
            }
            
            return nil
        }
    }
    
    var semesters: [Semester] = []
    var extracurriculars: [Extracurricular] = []
    var assignments: [Assignment] = []
    var tasks: [Task] = []
    
    private var nextFileNumber: Int = 0
    var filePairings: [(number: Int, name: String)] = []
    
    // iCloud Sync Variables
    
    let defaultContainer = CKContainer.default()
    let privateContainer = CKContainer(identifier: "iCloud.com.ppopsacul.TodoContainer")
    
    private let extracurricularFetcher = FetchManager(recordType: "Extracurricular")
    private let repeatingEventFetcher = FetchManager(recordType: "RepeatingEvent")
    private let singleEventFetcher = FetchManager(recordType: "SingleEvent")
    private let semesterFetcher = FetchManager(recordType: "Semester")
    private let courseFetcher = FetchManager(recordType: "Course")
    private let classFetcher = FetchManager(recordType: "Class")
    private let examFetcher = FetchManager(recordType: "Exam")
    private let assignmentFetcher = FetchManager(recordType: "Assignment")
    private let taskFetcher = FetchManager(recordType: "Task")
    private let reminderFetcher = FetchManager(recordType: "Reminder")
    
    private var fetchers: [FetchManager] {
        get {
            return [extracurricularFetcher, repeatingEventFetcher, singleEventFetcher, semesterFetcher, courseFetcher, classFetcher, examFetcher, assignmentFetcher, taskFetcher, reminderFetcher]
        }
    }
    
    var fetchFailed: Bool = false
    
    private var allDataFetched: Bool {
        get {
            for fetcher in fetchers {
                if !fetcher.fetched {
                    return false
                }
            }
            
            return true
        }
    }
    
    private var dataCompiled: Bool = false
    
    override init() {
        super.init()
        
        updateTimer = UpdateTimer(timeInterval: 60, completionBlock: { (info) in
            self.fetchDataFromCloud()
        })
    }
    
    func determineCurrentSemester() {
        let today = CalendarDay(date: Date())
        
        currentSemester = nil
        
        for semester in semesters {
            if semester.startDate <= today && today <= semester.endDate {
                currentSemester = semester
                break
            }
        }
    }
    
    func addFile(at url: URL) {
        filePairings.append((number: nextFileNumber, name: url.absoluteString))
        
        nextFileNumber += 1
    }
    
    func tasksFor(_ assignment: Assignment) -> [Task] {
        var output: [Task] = []
        
        for task in tasks {
            if task.relatedAssignment != nil && task.relatedAssignment!.isEqual(assignment) {
                output.append(task)
            }
        }
        
        return output
    }
    
    // MARK: - Updates
    
    func pauseAutoUpdate() {
        updateTimer.cancel()
    }
    
    func resumeAutoUpdate() {
        if !updateTimer.isOn {
            updateTimer.reset()
        }
    }
    
    // MARK: - Sorting
    
    func initialSortAlgorithm(showingCompletedTasks: Bool) -> ((Task, Task) -> Bool) {
        if !showingCompletedTasks {
            return self.initialSortIncompleteTasks(_:_:)
        } else {
            return self.initialSortCompleteTasks(_:_:)
        }
    }
    
    func initialSortIncompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        switch task1.dueDate {
        case .asap:
            switch task2.dueDate {
            case .asap:
                return task1.title < task2.title
                
            default:
                return true
            }
            
        case .eventually:
            switch task2.dueDate {
            case .eventually:
                return task1.title < task2.title
                
            default:
                return false
            }
            
        case .specificDay(let day1):
            switch task2.dueDate {
            case .asap:
                return false
                
            case .eventually:
                return true
                
            case .specificDay(let day2):
                return day1 < day2
                
            default:
                return task1.title < task2.title
            }
            
        default:
            return task1.title < task2.title
        }
    }
    
    func initialSortCompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        if let completion1 = task1.completionDate, let completion2 = task2.completionDate {
            return completion1 > completion2
        }
        
        return true
    }
    
    func sectionSortAlgorithm(showingCompletedTasks: Bool) -> ((Task, Task) -> Bool) {
        if !showingCompletedTasks {
            return self.sectionSortIncompleteTasks(_:_:)
        } else {
            return self.sectionSortCompleteTasks(_:_:)
        }
    }
    
    func sectionSortIncompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        if task1.priority.rawValue != task2.priority.rawValue {
            return task1.priority.rawValue > task2.priority.rawValue
        }
        
        if task1.commitment != nil && task2.commitment == nil {
            return true
        } else if task1.commitment == nil && task2.commitment != nil {
            return false
        } else if task1.commitment != nil && task2.commitment != nil && !task1.commitment!.isEqual(task2.commitment!) {
            return task1.commitment!.name < task2.commitment!.name
        }
        
        if task1.relatedAssignment != nil && task2.relatedAssignment == nil {
            return true
        } else if task1.relatedAssignment == nil && task2.relatedAssignment != nil {
            return false
        } else if task1.relatedAssignment != nil && task2.relatedAssignment != nil && !task1.relatedAssignment!.isEqual(task2.relatedAssignment!) {
            return task1.relatedAssignment!.title < task2.relatedAssignment!.title
        }
        
        if let creationDate1 = task1.record.creationDate, let creationDate2 = task2.record.creationDate {
            return creationDate1 < creationDate2
        }
        
        return task1.title < task2.title
    }
    
    func sectionSortCompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        if task1.priority.rawValue != task2.priority.rawValue {
            return task1.priority.rawValue > task2.priority.rawValue
        }
        
        if task1.commitment != nil && task2.commitment == nil {
            return true
        } else if task2.commitment == nil && task2.commitment != nil {
            return false
        } else if task1.commitment != nil && task2.commitment != nil && !task1.commitment!.isEqual(task2.commitment!) {
            return task1.commitment!.name < task2.commitment!.name
        }
        
        if task1.relatedAssignment != nil && task2.relatedAssignment == nil {
            return true
        } else if task1.relatedAssignment == nil && task2.relatedAssignment != nil {
            return false
        } else if task1.relatedAssignment != nil && task2.relatedAssignment != nil && !task1.relatedAssignment!.isEqual(task2.relatedAssignment!) {
            return task1.relatedAssignment!.title < task2.relatedAssignment!.title
        }
        
        if let creationDate1 = task1.record.creationDate, let creationDate2 = task2.record.creationDate {
            return creationDate1 > creationDate2
        }
        
        return task1.title < task2.title
    }
    
    func sortTasksForAssignment(_ task1: Task, _ task2: Task) -> Bool {
        switch task1.dueDate {
        case .asap:
            switch task2.dueDate {
            case .asap:
                return task1.title < task2.title
                
            default:
                return true
            }
            
        case .eventually:
            switch task2.dueDate {
            case .eventually:
                return task1.title < task2.title
                
            default:
                return false
            }
            
        case .specificDay(let day1):
            switch task2.dueDate {
            case .asap:
                return false
                
            case .eventually:
                return true
                
            case .specificDay(let day2):
                return day1 < day2
                
            default:
                break
            }
            
        default:
            break
        }
        
        if !task1.completed && task2.completed {
            return true
        } else if task1.completed && !task2.completed {
            return false
        }
        
        if task1.priority.rawValue != task2.priority.rawValue {
            return task1.priority.rawValue > task2.priority.rawValue
        }
        
        if task1.commitment != nil && task2.commitment == nil {
            return true
        } else if task2.commitment == nil && task2.commitment != nil {
            return false
        } else if task1.commitment != nil && task2.commitment != nil && !task1.commitment!.isEqual(task2.commitment!) {
            return task1.commitment!.name < task2.commitment!.name
        }
        
        if task1.relatedAssignment != nil && task2.relatedAssignment == nil {
            return true
        } else if task1.relatedAssignment == nil && task2.relatedAssignment != nil {
            return false
        } else if task1.relatedAssignment != nil && task2.relatedAssignment != nil && !task1.relatedAssignment!.isEqual(task2.relatedAssignment!) {
            return task1.relatedAssignment!.title < task2.relatedAssignment!.title
        }
        
        if let creationDate1 = task1.record.creationDate, let creationDate2 = task2.record.creationDate {
            return creationDate1 < creationDate2
        }
        
        return task1.title < task2.title
    }
    
    // MARK: - Listeners
    
    func addListener(_ listener: DMListener) {
        listeners.append(listener)
    }
    
    private func sendEventToListeners(_ eventType: DMLoadingEventType) {
        DispatchQueue.main.async {
            for listener in self.listeners {
                listener.handleLoadingEvent(eventType)
            }
        }
    }
    
    // MARK: - iCloud Storage
    
    @objc func loadData() {
        
        if UIDevice.current.isSimulator {
            generateFakeData()
            
            sendEventToListeners(DMLoadingEventType.end)
            
            return
        }
        
        self.currentCloudStatus = DMCloudConnectionStatus.fetching
        
        sendEventToListeners(DMLoadingEventType.start)
        
        defaultContainer.accountStatus { (accountStatus, accountError) in
            DispatchQueue.main.async {
                if let acctErr = accountError {
                    Console.shared.print("Account status error: \(acctErr.localizedDescription)")
                }
                
                switch accountStatus {
                    
                case .available:
                    Console.shared.print("iCloud enabled.")
                    
                    self.privateContainer.fetchUserRecordID(completionHandler: { (userRecordID, error) in
                        if let userRecordError = error {
                            Console.shared.print("User record error: \(userRecordError.localizedDescription)")
                        }
                        
                        if userRecordID != nil {
                            self.updateTimer.begin()
                        }
                    })
                    
                    break
                    
                default:
                    self.currentCloudStatus = DMCloudConnectionStatus.error
                    self.sendEventToListeners(DMLoadingEventType.error)
                    break
                    
                }
            }
        }
    }
    
    private func generateFakeData() {
        let sem = Semester(name: "Spring 2018", startDate: CalendarDay(date: Date()), endDate: CalendarDay(date: Date()))
        let course1 = Course()
        course1.name = "Principles of Chemistry for Engineners"
        course1.nickname = "Chemistry"
        course1.color = UIColor.lightGreen500
        
        let course2 = Course()
        course2.name = "Physics and Frontiers II"
        course2.nickname = "Physics"
        course2.color = UIColor.indigo500
        
        sem.courses.append(course1)
        sem.courses.append(course2)
        
        semesters.append(sem)
        
        let newAssignment = Assignment()
        newAssignment.title = "A12"
        newAssignment.dueDate = DueDate.specificDeadline(deadline: BetterDate(month: 4, day: 19, year: 2018, hour: 5, minute: 0, ampm: ClockTime.AmPm.pm)!)
        newAssignment.commitment = course1
        
        assignments.append(newAssignment)
        
        let newTask = Task()
        newTask.title = "Work on ALEKS"
        newTask.priority = Priority.high
        newTask.relatedAssignment = newAssignment
        
        let physicsTask = Task()
        physicsTask.title = "Homework"
        physicsTask.commitment = course2
        physicsTask.priority = Priority.normal
        
        tasks.append(newTask)
        tasks.append(physicsTask)
        
        let taskWithNoCourse = Task()
        taskWithNoCourse.title = "Blah blah blah"
        taskWithNoCourse.userDescription = "TurnItIn at 11:59PM!"
        tasks.append(taskWithNoCourse)
    }
    
    @objc func fetchDataFromCloud() {
        currentCloudStatus = DMCloudConnectionStatus.fetching
        sendEventToListeners(DMLoadingEventType.start)
        
        updateTimer.reset()
        
        for fetcher in fetchers {
            fetcher.fetched = false
        }
        
        dataCompiled = false
        fetchFailed = false
        
        Console.shared.print("Fetching data from iCloud.")
        
        privateContainer.fetchUserRecordID(completionHandler: { (userRecordID, userRecordError) in
            DispatchQueue.main.async {
                if userRecordError != nil {
                    Console.shared.print("User record error: \(userRecordError!.localizedDescription)")
                }
                
                if let fetchedUserRecordID = userRecordID {
                    let userReference = CKReference(recordID: fetchedUserRecordID, action: CKReferenceAction.none)
                    
                    for fetcher in self.fetchers {
                        fetcher.makeQuery(createdBy: userReference, dataManager: self)
                    }
                }
            }
        })
    }
    
    func attemptToCompileFetchedRecords() {
        if !dataCompiled {
            if fetchFailed {
                dataCompiled = true
                
                currentCloudStatus = DMCloudConnectionStatus.error
                sendEventToListeners(DMLoadingEventType.error)
            } else if allDataFetched {
                Console.shared.print("Finished fetching data. Attempting to compile records.")
                
                dataCompiled = true
                
                var events: [Event] = []
                for record in singleEventFetcher.records {
                    events.append(SingleEvent(record: record))
                }
                
                for record in repeatingEventFetcher.records {
                    events.append(RepeatingEvent(record: record))
                }
                
                extracurriculars = []
                for record in extracurricularFetcher.records {
                    extracurriculars.append(Extracurricular(record: record, events: events))
                }
                
                var classes: [Class] = []
                for record in classFetcher.records {
                    classes.append(Class(record: record))
                }
                
                var exams: [Exam] = []
                for record in examFetcher.records {
                    exams.append(Exam(record: record))
                }
                
                var courses: [Course] = []
                for record in courseFetcher.records {
                    courses.append(Course(record: record, classes: classes, exams: exams))
                }
                
                semesters = []
                for record in semesterFetcher.records {
                    semesters.append(Semester(record: record, courses: courses))
                }
                
                var reminders: [Reminder] = []
                for record in reminderFetcher.records {
                    reminders.append(Reminder(record: record))
                }
                
                assignments = []
                for record in assignmentFetcher.records {
                    assignments.append(Assignment(record: record, reminders: reminders))
                }
                
                tasks = []
                for record in taskFetcher.records {
                    tasks.append(Task(record: record))
                }
                
                semesters = semesters.sorted(by: { (semester1, semester2) -> Bool in
                    return semester1.endDate > semester2.endDate
                })
                
                NotificationManager.shared.scheduleAllReminders()
                
                Console.shared.print("All records successfully compiled.")
                
                determineCurrentSemester()
                
                currentCloudStatus = DMCloudConnectionStatus.ready
                sendEventToListeners(DMLoadingEventType.end)
            }
        }
    }
    
    // MARK: - iCloud wrapper
    
    func introduce(_ record: CKRecord) {
        self.recordsToProcess.append(record.recordID)
        
        self.privateContainer.privateCloudDatabase.save(record) { (savedRecord, saveError) in
            DispatchQueue.main.async {
                if let error = saveError {
                    Console.shared.print("Error introducing record: \(error.localizedDescription)")
                }
                
                if let recordIndex = self.recordsToProcess.index(of: record.recordID) {
                    self.recordsToProcess.remove(at: recordIndex)
                }
            }
        }
    }
    
    func update(_ record: CKRecord) {
        self.recordsToProcess.append(record.recordID)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
            DispatchQueue.main.async {
                if let err = error {
                    Console.shared.print("Error: \(err.localizedDescription) (\(record.recordType) \(record.recordID.recordName)")
                }
                
                if let recordIndex = self.recordsToProcess.index(of: record.recordID) {
                    self.recordsToProcess.remove(at: recordIndex)
                }
            }
        }
        
        self.privateContainer.privateCloudDatabase.add(operation)
    }
    
    func delete(_ record: CKRecord) {
        self.recordsToProcess.append(record.recordID)
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])
        
        operation.modifyRecordsCompletionBlock = { _, deletedRecordsIDs, error in
            DispatchQueue.main.async {
                if let err = error {
                    Console.shared.print("Record deletion error: \(err.localizedDescription)")
                }
                
                if let recordIndex = self.recordsToProcess.index(of: record.recordID) {
                    self.recordsToProcess.remove(at: recordIndex)
                }
            }
        }
        
        self.privateContainer.privateCloudDatabase.add(operation)
    }
    
}

