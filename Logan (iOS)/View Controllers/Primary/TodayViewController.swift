//
//  TodayViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/13/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DMListener {
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tasksSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var scheduleSections: [(sectionName: String, items: [NSObject])] = []
    var assignmentSections: [(sectionName: String, items: [NSObject])] = []
    var taskSections: [(sectionName: String, items: [NSObject])] = []
    
    var dataSections: [(sectionName: String, items: [NSObject])] {
        get {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return scheduleSections
            case 1:
                return assignmentSections
            case 2:
                return taskSections
            default:
                return []
            }
        }
    }
    
    private var updateTimer: UpdateTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.addListener(self)
        
        updateTimer = UpdateTimer(timeInterval: 0.5, completionBlock: { (userInfo) in
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.updateData()
                self.tableView.reloadData()
            }
        })

        tabBar.backgroundColor = UIColor.teal500
        
        if segmentedControl.selectedSegmentIndex == 2 {
            tasksSegmentedControl.isHidden = false
        } else {
            tasksSegmentedControl.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
        tableView.reloadData()
    }
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
            tasksSegmentedControl.isHidden = false
        } else {
            tasksSegmentedControl.isHidden = true
        }
        
        updateData()
        tableView.reloadData()
    }
    
    @IBAction func taskCategoryChanged(_ sender: UISegmentedControl) {
        updateData()
        tableView.reloadData()
    }
    
    func updateData() {
        if segmentedControl.selectedSegmentIndex == 0 {
            scheduleSections = []
            
            func addClass(_ classToAdd: Class, toSection section: String) {
                for i in 0 ..< dataSections.count {
                    if scheduleSections[i].sectionName == section {
                        scheduleSections[i].items.append(classToAdd)
                        return
                    }
                }
                
                scheduleSections.append((sectionName: section, items: [classToAdd]))
            }
            
            if let currentSemester = DataManager.shared.currentSemester {
                let today = CalendarDay(date: Date())
                let now = ClockTime(date: Date())
                let currentDayOfWeek = DayOfWeek.forDate(Date())
                
                var allClasses: [Class] = []
                
                for course in currentSemester.courses {
                    for courseClass in course.classes {
                        if courseClass.startDate <= today && courseClass.endDate >= today && courseClass.daysOfWeek.contains(currentDayOfWeek) {
                            allClasses.append(courseClass)
                        }
                    }
                }
                
                allClasses.sort(by: { (c1, c2) -> Bool in
                    return c1.endTime < c2.startTime
                })
                
                for scheduleClass in allClasses {
                    if scheduleClass.startDate <= today && scheduleClass.endDate >= today && scheduleClass.daysOfWeek.contains(currentDayOfWeek) {
                        if scheduleClass.endTime <= now {
                            addClass(scheduleClass, toSection: "Past")
                        } else if scheduleClass.startTime >= now {
                            addClass(scheduleClass, toSection: "Upcoming")
                        } else if scheduleClass.startTime <= now && scheduleClass.endTime >= now {
                            addClass(scheduleClass, toSection: "Current")
                        }
                    }
                }
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            assignmentSections = []
            
            var assignmentsToSort: [Assignment] = []
            
            let now = Date()
            var days: Int = 0
            for assignment in DataManager.shared.assignments {
                if case .specificDeadline(let deadline) = assignment.dueDate {
                    days = Date.daysBetween(now, and: deadline.dateValue!)
                    
                    if days == 1 || days == 2 {
                        assignmentsToSort.append(assignment)
                    }
                }
            }
            
            assignmentsToSort.sort { (assignment1, assignment2) -> Bool in
                switch assignment1.dueDate {
                    
                case .specificDeadline(let deadline1):
                    switch assignment2.dueDate {
                        
                    case .specificDeadline(let deadline2):
                        return deadline1 < deadline2
                        
                    default:
                        return true
                        
                    }
                    
                default:
                    return true
                    
                }
            }
            
            func addAssignment(_ assignment: Assignment, toSectionWithName sectionName: String) {
                var found: Bool = false
                
                for i in 0 ..< assignmentSections.count {
                    if assignmentSections[i].sectionName == sectionName {
                        assignmentSections[i].items.append(assignment)
                        found = true
                        break
                    }
                }
                
                if !found {
                    assignmentSections.append((sectionName: sectionName, items: [assignment]))
                }
            }
            
            for assignment in assignmentsToSort {
                switch assignment.dueDate {
                    
                case .asap:
                    addAssignment(assignment, toSectionWithName: "ASAP")
                    break
                    
                case .eventually:
                    addAssignment(assignment, toSectionWithName: "Eventually")
                    break
                    
                case .specificDeadline(let deadline):
                    if let dayDate = deadline.day.dateValue {
                        let today = Date()
                        let days = Date.daysBetween(today, and: dayDate)
                        
                        if deadline.day == CalendarDay(date: today) {
                            addAssignment(assignment, toSectionWithName: "Today")
                        } else if days < 0 {
                            addAssignment(assignment, toSectionWithName: "Overdue")
                        } else if days == 1 {
                            addAssignment(assignment, toSectionWithName: "Tomorrow")
                        } else if today.weekOfYear == dayDate.weekOfYear {
                            addAssignment(assignment, toSectionWithName: DayOfWeek.forDate(dayDate).longName())
                        } else {
                            let formatter = BetterDateFormatter()
                            
                            if today.year != dayDate.year {
                                formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                            } else {
                                formatter.dateFormat = "EEEE, MMMM dnn"
                            }
                            
                            addAssignment(assignment, toSectionWithName: formatter.string(from: dayDate))
                        }
                    } else {
                        addAssignment(assignment, toSectionWithName: "Eventually")
                    }
                    break
                    
                default:
                    break
                    
                }
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            taskSections = []
            
            var tasksToSort: [Task] = []
            
            if tasksSegmentedControl.selectedSegmentIndex == 0 {
                for task in DataManager.shared.tasks {
                    if !task.completed {
                        if task.dueDate.intValue == DueDate.asapIntValue {
                            tasksToSort.append(task)
                        }
                    }
                }
            } else if tasksSegmentedControl.selectedSegmentIndex == 1 {
                let today = CalendarDay(date: Date())
                for task in DataManager.shared.tasks {
                    if !task.completed {
                        if case let .specificDay(day) = task.dueDate {
                            if day == today {
                                tasksToSort.append(task)
                            }
                        }
                    }
                }
            } else if tasksSegmentedControl.selectedSegmentIndex == 2 {
                for task in DataManager.shared.tasks {
                    if !task.completed {
                        if task.dueDate.intValue == DueDate.eventuallyIntValue {
                            tasksToSort.append(task)
                        }
                    }
                }
            }
            
            tasksToSort.sort(by: DataManager.shared.initialSortAlgorithm(showingCompletedTasks: false))
            
            func addTask(_ task: Task, toSectionWithName sectionName: String) {
                var found: Bool = false
                
                for i in 0 ..< dataSections.count {
                    if taskSections[i].sectionName == sectionName {
                        taskSections[i].items.append(task)
                        found = true
                        break
                    }
                }
                
                if !found {
                    taskSections.append((sectionName: sectionName, items: [task]))
                }
            }
            
            for task in tasksToSort {
                switch task.dueDate {
                case .asap:
                    addTask(task, toSectionWithName: "ASAP")
                    break
                    
                case .eventually:
                    addTask(task, toSectionWithName: "Eventually")
                    break
                    
                case .specificDay(let day):
                    if let deadline = day.dateValue {
                        let today = Date()
                        let days = Date.daysBetween(today, and: deadline)
                        
                        if day == CalendarDay(date: today) {
                            addTask(task, toSectionWithName: "Today")
                        } else if days < 0 {
                            addTask(task, toSectionWithName: "Overdue")
                        } else if days == 1 {
                            addTask(task, toSectionWithName: "Tomorrow")
                        } else if today.weekOfYear == deadline.weekOfYear {
                            addTask(task, toSectionWithName: DayOfWeek.forDate(deadline).longName())
                        } else {
                            let formatter = BetterDateFormatter()
                            
                            if today.year != deadline.year {
                                formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                            } else {
                                formatter.dateFormat = "EEEE, MMMM dnn"
                            }
                            
                            addTask(task, toSectionWithName: formatter.string(from: deadline))
                        }
                    } else {
                        addTask(task, toSectionWithName: "Eventually")
                    }
                    break
                    
                default:
                    break
                }
            }
            
            for i in 0 ..< dataSections.count {
                if taskSections[i].sectionName == "Overdue" {
                    taskSections[i].items = (taskSections[i].items as! [Task]).sorted(by: { (task1, task2) -> Bool in
                        switch task1.dueDate {
                        case .specificDay(let day1):
                            switch task2.dueDate {
                            case .specificDay(let day2):
                                return day1 > day2
                                
                            default:
                                return true
                            }
                            
                        default:
                            return true
                        }
                    })
                }
                
                taskSections[i].items = (taskSections[i].items as! [Task]).sorted(by: DataManager.shared.sectionSortAlgorithm(showingCompletedTasks: false))
            }
        }
    }
    
    // MARK: - DMListener
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType) {
        if eventType == DMLoadingEventType.start {
            if let leftNavigationButton = navigationItem.leftBarButtonItem {
                if leftNavigationButton.title != nil && leftNavigationButton.title! == "Sync" {
                    leftNavigationButton.isEnabled = false
                }
            }
        } else if eventType == DMLoadingEventType.end {
            updateData()
            tableView.reloadData()
            
            if let leftNavigationButton = navigationItem.leftBarButtonItem {
                if leftNavigationButton.title != nil && leftNavigationButton.title! == "Sync" {
                    leftNavigationButton.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataSections[indexPath.section].items[indexPath.row]
        
        if let scheduleClass = item as? Class {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Class", for: indexPath) as? ScheduleTableViewCell {
                cell.classToDisplay = scheduleClass
                cell.configureCell()
                
                return cell
            }
        } else if let assignment = item as? Assignment {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Assignment", for: indexPath) as? AssignmentTableViewCell {
                cell.assignment = assignment
                cell.configureCell()
                
                return cell
            }
        } else if let task = item as? Task {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath) as? TaskTableViewCell {
                cell.task = task
                cell.configureCell()
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 0 || segmentedControl.selectedSegmentIndex == 1 {
            return dataSections[section].sectionName
        }
        
        return nil
    }

}
