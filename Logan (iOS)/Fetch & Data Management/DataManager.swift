//
//  DataManager.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation
import EventKit
import UIKit.UIColor

// A protocol to be implemented that allows subscribing to the loading events of a particular data manager
protocol DataManagerListener: AnyObject {
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?)
    
}

// NOTE: The following code observes changes to the iCloud account status

class DataManager: NSObject {
    
    // An enum describing the type of event sent by a data manager
    enum LoadingEventType: Int {
        case start = 0
        case end = 1
        case error = 2
    }
    
    // An enum describing the app's connection to iCloud
    enum ConnectionStatus: Int {
        case ready = 0
        case fetching = 1
        case error = 2
    }
    
    static var shared: DataManager = DataManager()
    
    private var listeners: [DataManagerListener] = []
    
    var currentConnectionStatus: ConnectionStatus = .ready
    
    var isSavingData: Bool {
        get {
            return recordsToProcess.count > 0
        }
    }
    
    private var recordsToProcess: [CKRecordID] = []
    
    private var updateTimer: UpdateTimer!
    
    var currentUser: User?
    
    var currentSemester: Semester?
    var currentCourse: Course? {
        get {
            let today = CalendarDay(date: Date())
            let now = ClockTime(date: Date())
            let currentWeekDay = DayOfWeek.forDate(Date())
            
            for semester in semesters {
                for course in semester.courses {
                    for section in course.sections {
                        if section.startDate <= today && section.endDate >= today && section.daysOfWeek.contains(currentWeekDay) {
                            if section.startTime <= now && section.endTime >= now {
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
    var assignments: [Assignment] = []
    var tasks: [Task] = []
    
    // iCloud Sync Variables
    private let shouldGenerateFakeData: Bool = false
    var fetchFailed: Bool = false
    
    // TODO: manager.dataCompiled?
    private var dataCompiled: Bool = false
    
    // Calendar variables
    
    let eventStore = EKEventStore()
    var calendarIdsToDisplay: Set<String> {
        get {
            return Set<String>(UserDefaults.standard.stringArray(forKey: "Selected Calendars") ?? eventStore.calendars(for: EKEntityType.event).map({ (calendar) -> String in
                return calendar.calendarIdentifier
            }))
        }
        
        set {
            UserDefaults.standard.set([String](newValue), forKey: "Selected Calendars")
        }
    }
    var selectedCalendars: [EKCalendar] {
        get {
            let all = eventStore.calendars(for: EKEntityType.event)
            var selected: [EKCalendar] = []
            let idsToDisplay = calendarIdsToDisplay
            
            for calendar in all {
                if idsToDisplay.contains(calendar.calendarIdentifier) {
                    selected.append(calendar)
                }
            }
            
            return selected
        }
    }
    
    override init() {
        super.init()
        
        // MARK: - EventKit stuff
        checkCalendarAuthorization()
        
        fetchManager = FetchManager(dataManager: self, compilationCallback: { (semesters, extracurriculars, assignments, tasks) in
            self.semesters = semesters
            self.extracurriculars = extracurriculars
            self.assignments = assignments
            self.tasks = tasks

            NotificationManager.shared.scheduleAllReminders()

            self.determineCurrentSemester()
            self.currentCloudStatus = .ready
            self.sendEventToListeners(.end)
        }, failureCallback: { (error) in
            self.currentCloudStatus = .error
            self.sendEventToListeners(.error, error: error)

            if let cloudError = error as? CKError {
                if cloudError.errorCode == 3 {
                    Console.shared.print("CKError 3: Network error.")
                } else if cloudError.code == CKError.Code.requestRateLimited {
                    Console.shared.print("Request rate limited. Max retries reached.")
                } else {
                    Console.shared.print(cloudError.localizedDescription)
                }
            } else {
                Console.shared.print(error.localizedDescription)
            }
        })
        
        updateTimer = UpdateTimer(timeInterval: 60, completionBlock: { (info) in
            self.fetchData()
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
    
    // MARK: - Listeners
    
    func addListener(_ listener: DataManagerListener) {
        listeners.append(listener)
    }
    
    private func sendEventToListeners(_ eventType: LoadingEventType, error: Error? = nil) {
        DispatchQueue.main.async {
            for listener in self.listeners {
                listener.handleLoadingEvent(eventType, error: error)
            }
        }
    }
    
    // MARK: - iCloud Storage
    
    @objc func attemptInitialDataFetch() {
        if UIDevice.current.isSimulator && shouldGenerateFakeData {
            generateFakeData()
            sendEventToListeners(.end)
            return
        }
        
        sendEventToListeners(.start)
        
        // Check iCloud authorization
        defaultContainer.accountStatus { (accountStatus, accountError) in
            DispatchQueue.main.async {
                if let acctErr = accountError {
                    Console.shared.print("Account status error: \(acctErr.localizedDescription)")
                }
                
                switch accountStatus {
                
                case .available:
                    // If successful, attempt to fetch data
                    Console.shared.print("iCloud enabled.")
                    self.privateContainer.fetchUserRecordID(completionHandler: { (userRecordID, error) in
                        if let userRecordError = error {
                            Console.shared.print("User record error: \(userRecordError.localizedDescription)")
                        }
                        
                        if userRecordID != nil {
                            self.fetchDataFromCloud()
                        }
                    })
                    
                    break
                    
                default:
                    self.currentConnectionStatus = .error
                    self.sendEventToListeners(.error, error: accountError)
                    break
                    
                }
            }
        }
    }
    
    private func generateFakeData() {
//        let sem = Semester(name: "Spring 2018", startDate: CalendarDay(date: Date()), endDate: CalendarDay(date: Date()))
//        let course1 = Course()
//        course1.name = "Principles of Chemistry for Engineners"
//        course1.nickname = "Chemistry"
//        course1.color = UIColor.lightGreen500
//
//        let course2 = Course()
//        course2.name = "Physics and Frontiers II"
//        course2.nickname = "Physics"
//        course2.color = UIColor.indigo500
//
//        sem.courses.append(course1)
//        sem.courses.append(course2)
//
//        semesters.append(sem)
//
//        let newAssignment = Assignment()
//        newAssignment.title = "A12"
//        newAssignment.dueDate = DueDate.specificDeadline(deadline: BetterDate(day: CalendarDay(date: Date(timeIntervalSinceNow: 7 * 24 * 60 * 60)), time: ClockTime(hour: 5, minute: 0, ampm: ClockTime.AmPm.pm)!))
//        newAssignment.commitment = course1
//
//        assignments.append(newAssignment)
//
//        let newTask = Task()
//        newTask.title = "Work on ALEKS"
//        newTask.priority = Priority.high
//        newTask.relatedAssignment = newAssignment
//
//        let physicsTask = Task()
//        physicsTask.title = "Homework"
//        physicsTask.commitment = course2
//        physicsTask.priority = Priority.normal
//
//        tasks.append(newTask)
//        tasks.append(physicsTask)
//
//        let taskWithNoCourse = Task()
//        taskWithNoCourse.title = "Blah blah blah"
//        taskWithNoCourse.userDescription = "TurnItIn at 11:59PM!"
//        tasks.append(taskWithNoCourse)
    }
    
    @objc func fetchData() {
        if currentConnectionStatus == .fetching || isSavingData { return }
        
        if UIDevice.current.isSimulator && shouldGenerateFakeData {
            updateTimer.reset()
            sendEventToListeners(.end)
            return
        }
        
        currentConnectionStatus = .fetching
        sendEventToListeners(.start)
        
        updateTimer.reset()
        
        dataCompiled = false
        fetchFailed = false
        
        Console.shared.print("Fetching data from iCloud.")
        privateContainer.fetchUserRecordID(completionHandler: { (userRecordID, userRecordError) in
            DispatchQueue.main.async {
                if userRecordError != nil {
                    Console.shared.print("User record error: \(userRecordError!.localizedDescription)")
                } else if let fetchedUserRecordID = userRecordID {
                    let userReference = CKReference(recordID: fetchedUserRecordID, action: CKReferenceAction.none)
                    self.fetchManager.makeQueries(createdBy: userReference)
                }
            }
        })
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
    
    // MARK: EventKit stuff
    
    private func checkCalendarAuthorization() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch status {
            
        case EKAuthorizationStatus.notDetermined:
            requestCalendarAccess()
            Swift.print("Requesting calendar access")
            break
            
        case EKAuthorizationStatus.authorized:
            let calendars = eventStore.calendars(for: EKEntityType.event)
            
            let events = eventStore.events(matching: eventStore.predicateForEvents(withStart: CalendarDay.today.dateValue!, end: CalendarDay(date: Date().addingTimeInterval(24*60*60)).dateValue!, calendars: nil))
//            Swift.print(events)
            
            break
            
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            Swift.print("Access denied")
            break
            
        }
    }
    
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            if accessGranted {
                DispatchQueue.main.async {
                    Swift.print("Access granted")
                }
            } else {
                DispatchQueue.main.async {
                    Swift.print("Access denied")
                }
            }
        }
    }
    
    func events(for day: CalendarDay) -> [EKEvent] {
        let start = day.dateValue!
        let end = day.dateValue!.addingTimeInterval(24 * 60 * 60)
        let events = eventStore.events(matching: eventStore.predicateForEvents(withStart: start, end: end, calendars: selectedCalendars))
        return events
    }
    
}
