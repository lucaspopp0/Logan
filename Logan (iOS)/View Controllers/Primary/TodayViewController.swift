//
//  TodayViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/13/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataManagerListener {
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tasksSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var scheduleData: TableData<NSObject> = TableData<NSObject>()
    var assignmentData: TableData<NSObject> = TableData<NSObject>()
    var taskData: TableData<NSObject> = TableData<NSObject>()
    
    var data: TableData<NSObject> {
        get {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return scheduleData
            case 1:
                return assignmentData
            case 2:
                return taskData
            default:
                return TableData<NSObject>()
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
            scheduleData.clear()
            
            if let currentSemester = DataManager.shared.currentSemester {
                let today = CalendarDay(date: Date())
                let now = ClockTime(date: Date())
                let currentDayOfWeek = DayOfWeek.forDate(Date())
                
                var allClasses: [Section] = []
                
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
                            scheduleData.add(item: scheduleClass, section: "Past")
                        } else if scheduleClass.startTime >= now {
                            scheduleData.add(item: scheduleClass, section: "Upcoming")
                        } else if scheduleClass.startTime <= now && scheduleClass.endTime >= now {
                            scheduleData.add(item: scheduleClass, section: "Current")
                        }
                    }
                }
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            assignmentData.clear()
            
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
            
            for assignment in assignmentsToSort {
                switch assignment.dueDate {
                    
                case .asap:
                    assignmentData.add(item: assignment, section: "ASAP")
                    break
                    
                case .eventually:
                    assignmentData.add(item: assignment, section: "Eventually")
                    break
                    
                case .specificDeadline(let deadline):
                    if let dayDate = deadline.day.dateValue {
                        let today = Date()
                        let days = Date.daysBetween(today, and: dayDate)
                        
                        if deadline.day == CalendarDay(date: today) {
                            assignmentData.add(item: assignment, section: "Today")
                        } else if days < 0 {
                            assignmentData.add(item: assignment, section: "Overdue")
                        } else if days == 1 {
                            assignmentData.add(item: assignment, section: "Tomorrow")
                        } else if today.weekOfYear == dayDate.weekOfYear {
                            assignmentData.add(item: assignment, section: DayOfWeek.forDate(dayDate).longName())
                        } else {
                            let formatter = BetterDateFormatter()
                            
                            if today.year != dayDate.year {
                                formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                            } else {
                                formatter.dateFormat = "EEEE, MMMM dnn"
                            }
                            
                            assignmentData.add(item: assignment, section: formatter.string(from: dayDate))
                        }
                    } else {
                        assignmentData.add(item: assignment, section: "Eventually")
                    }
                    break
                    
                default:
                    break
                    
                }
            }
        } else if segmentedControl.selectedSegmentIndex == 2 {
            taskData.clear()
            
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
            
            tasksToSort.sort(by: Sorting.initialSortIncompleteTasks(_:_:))
            
            for task in tasksToSort {
                switch task.dueDate {
                case .asap:
                    taskData.add(item: task, section: "ASAP")
                    break
                    
                case .eventually:
                    taskData.add(item: task, section: "Eventually")
                    break
                    
                case .specificDay(let day):
                    if let deadline = day.dateValue {
                        let today = Date()
                        let days = Date.daysBetween(today, and: deadline)
                        
                        if day == CalendarDay(date: today) {
                            taskData.add(item: task, section: "Today")
                        } else if days < 0 {
                            taskData.add(item: task, section: "Overdue")
                        } else if days == 1 {
                            taskData.add(item: task, section: "Tomorrow")
                        } else if today.weekOfYear == deadline.weekOfYear {
                            taskData.add(item: task, section: DayOfWeek.forDate(deadline).longName())
                        } else {
                            let formatter = BetterDateFormatter()
                            
                            if today.year != deadline.year {
                                formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                            } else {
                                formatter.dateFormat = "EEEE, MMMM dnn"
                            }
                            
                            taskData.add(item: task, section: formatter.string(from: deadline))
                        }
                    } else {
                        taskData.add(item: task, section: "Eventually")
                    }
                    break
                    
                default:
                    break
                }
            }
            
            for section in data.sections {
                if section.title == "Overdue" {
                    section.items = (section.items as! [Task]).sorted(by: { (task1, task2) -> Bool in
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
                
                section.items = (section.items as! [Task]).sorted(by: Sorting.sectionSortAlgorithm(showingCompletedTasks: false))
            }
        }
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?) {
        if eventType == .start {
            if let leftNavigationButton = navigationItem.leftBarButtonItem {
                if leftNavigationButton.title != nil && leftNavigationButton.title! == "Sync" {
                    leftNavigationButton.isEnabled = false
                }
            }
        } else if eventType == .end {
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
        return data.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data.sections[indexPath.section].items[indexPath.row]
        
        if let scheduleClass = item as? Section {
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
            return data.sections[section].title
        }
        
        return nil
    }

}
