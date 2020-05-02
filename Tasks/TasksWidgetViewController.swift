//
//  TasksWidgetViewController.swift
//  Tasks
//
//  Created by Lucas Popp on 2/3/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import NotificationCenter

class TasksWidgetViewController: UIViewController, NCWidgetProviding, RowViewDelegate, DataManagerListener {
    
    private enum TaskCategory: Int {
        case asap = 0
        case overdue = 1
        case today = 2
        case eventually = 3
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tasksRowView: RowView!
    
    private var asapTasks: [Task] = []
    private var overdueTasks: [Task] = []
    private var todaysTasks: [Task] = []
    private var eventuallyTasks: [Task] = []
    
    private var tableData: [[Task]] = []
    
    private var tasksForCurrentSection: [Task] {
        get {
            if segmentedControl.selectedSegmentIndex >= 0 && segmentedControl.selectedSegmentIndex < tableData.count {
                return tableData[segmentedControl.selectedSegmentIndex]
            }
            
            return []
        }
    }
    
    private var tasksToHide: Int = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.addListener(self)
        
        extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
        updatePreferredContentSize()
    }
    
    func updatePreferredContentSize(_ maxSize: CGSize? = nil) {
        calculateTasksToHide()
        tasksRowView.reloadData()
        tasksRowView.sizeToFit()
        
        if let displayMode = extensionContext?.widgetActiveDisplayMode, displayMode == NCWidgetDisplayMode.expanded {
            preferredContentSize = CGSize(width: maxSize?.width ?? tasksRowView.frame.size.width, height: tasksRowView.frame.maxY)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        DataManager.shared.fetchData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            preferredContentSize = maxSize
        } else if activeDisplayMode == NCWidgetDisplayMode.expanded {
            updatePreferredContentSize(maxSize)
        }
    }
    
    @IBAction func segmentPressed(_ sender: UISegmentedControl) {
        tasksRowView.reloadData()
        calculateTasksToHide()
        
        updatePreferredContentSize()
    }
    
    func calculateTasksToHide() {
        tasksToHide = 0
        tasksRowView.reloadData()
        tasksRowView.sizeToFit()
        
        let maximumWidgetHeight = UIScreen.main.bounds.size.height - 126
        let maximumListHeight = maximumWidgetHeight - (segmentedControl.frame.midY * 2)
        
        var taskViewCount: Int = 0
        for i in 0 ..< tasksRowView.numberOfRows {
            let view = tasksRowView.viewForRow(i)!
                
            if view is TaskView {
                if view.frame.maxY > maximumListHeight {
                    tasksToHide = tasksForCurrentSection.count - taskViewCount
                    break
                } else if i < tasksRowView.numberOfRows - 1 && view.frame.maxY + ShowMoreView.estimatedHeight > maximumListHeight {
                    tasksToHide = tasksForCurrentSection.count - taskViewCount
                    break
                }
                
                taskViewCount += 1
            }
        }
    }
    
    func updateData() {
        tableData = []
        
        asapTasks = []
        overdueTasks = []
        todaysTasks = []
        eventuallyTasks = []
        
        var tasksToSort: [Task] = []
        
        for task in DataManager.shared.tasks {
            if !task.completed {
                tasksToSort.append(task)
            }
        }
        
        tasksToSort.sort(by: Sorting.initialSortAlgorithm(showingCompletedTasks: false))
        
        for task in tasksToSort {
            switch task.dueDate {
            case .asap:
                asapTasks.append(task)
                break
                
            case .eventually:
                eventuallyTasks.append(task)
                break
                
            case .specificDay(let day):
                if let deadline = day.dateValue {
                    let today = Date()
                    let days = Date.daysBetween(today, and: deadline)
                    
                    if day == CalendarDay(date: today) {
                        todaysTasks.append(task)
                    } else if days < 0 {
                        overdueTasks.append(task)
                    }
                } else {
                    eventuallyTasks.append(task)
                }
                break
                
            default:
                break
            }
        }
        
        overdueTasks.sort { (task1, task2) -> Bool in
            if case .specificDay(let day1) = task1.dueDate {
                if case .specificDay(let day2) = task2.dueDate {
                    return day1 > day2
                }
            }
            
            return true
        }
        
        asapTasks.sort(by: Sorting.sectionSortIncompleteTasks(_:_:))
        overdueTasks.sort(by: Sorting.sectionSortIncompleteTasks(_:_:))
        todaysTasks.sort(by: Sorting.sectionSortIncompleteTasks(_:_:))
        eventuallyTasks.sort(by: Sorting.sectionSortIncompleteTasks(_:_:))
        
        var titleOfSelectedSegment: String = "N"
        
        if segmentedControl.selectedSegmentIndex > -1 {
            titleOfSelectedSegment = (segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "N").substring(to: 1)
        }
        
        segmentedControl.removeAllSegments()
        
        if asapTasks.count > 0 {
            tableData.append(asapTasks)
            segmentedControl.insertSegment(withTitle: "ASAP (\(asapTasks.count))", at: segmentedControl.numberOfSegments, animated: false)
        }
        
        if overdueTasks.count > 0 {
            tableData.append(overdueTasks)
            segmentedControl.insertSegment(withTitle: "Overdue (\(overdueTasks.count))", at: segmentedControl.numberOfSegments, animated: false)
        }
        
        if todaysTasks.count > 0 {
            tableData.append(todaysTasks)
            segmentedControl.insertSegment(withTitle: "Today (\(todaysTasks.count))", at: segmentedControl.numberOfSegments, animated: false)
        }
        
        if eventuallyTasks.count > 0 {
            tableData.append(eventuallyTasks)
            segmentedControl.insertSegment(withTitle: "Eventually (\(eventuallyTasks.count))", at: segmentedControl.numberOfSegments, animated: false)
        }
        
        if segmentedControl.numberOfSegments > 0 {
            for i in 0 ..< segmentedControl.numberOfSegments {
                if (segmentedControl.titleForSegment(at: i) ?? "N").substring(to: 1) == titleOfSelectedSegment {
                    segmentedControl.selectedSegmentIndex = i
                }
            }
            
            if titleOfSelectedSegment == "N" {
                for i in 0 ..< segmentedControl.numberOfSegments {
                    if segmentedControl.titleForSegment(at: i) ?? "" == "T" {
                        segmentedControl.selectedSegmentIndex = i
                        break
                    }
                }
                
                if segmentedControl.selectedSegmentIndex == -1 {
                    segmentedControl.selectedSegmentIndex = 0
                }
            }
        }
        
        tasksRowView.reloadData()
    }
    
    // MARK: - RowViewDelegate
    
    func numberOfRows(in rowView: RowView) -> Int {
        if tasksToHide > 0 {
            return tasksForCurrentSection.count - tasksToHide + 1
        } else {
            return tasksForCurrentSection.count
        }
    }
    
    func viewForRow(_ row: Int, in rowView: RowView) -> UIView {
        if (tasksToHide > 0 && row < tasksForCurrentSection.count - tasksToHide) || tasksToHide == 0 {
            let taskView = TaskView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
            taskView.task = tasksForCurrentSection[row]
            taskView.configure()
            return taskView
        } else if tasksToHide > 0 && row == tasksForCurrentSection.count - tasksToHide {
            let extraView: ShowMoreView = ShowMoreView()
            extraView.extensionContext = extensionContext
            extraView.extraCount = tasksToHide
            extraView.frame.size.width = view.frame.size.width
            return extraView
        }
        
        return UIView()
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?) {
        if eventType == DataManager.LoadingEventType.end {
            updateData()
            updatePreferredContentSize()
        }
    }
    
}
