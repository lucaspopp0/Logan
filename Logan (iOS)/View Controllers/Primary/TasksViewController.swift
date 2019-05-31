//
//  TasksViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate, DMListener {
    
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var viewIsVisible: Bool = false
    
    var dataSections: [(sectionName: String, tasks: [Task])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alpha = 0
        activityIndicator.startAnimating()
        
        InterfaceManager.shared.tasksController = self
        DataManager.shared.addListener(self)
        
        if DataManager.shared.currentCloudStatus == DMCloudConnectionStatus.fetching {
            syncButton.image = #imageLiteral(resourceName: "Cloud Progress")
        } else if DataManager.shared.currentCloudStatus == DMCloudConnectionStatus.ready {
            syncButton.image = #imageLiteral(resourceName: "Cloud Sync")
        } else if DataManager.shared.currentCloudStatus == DMCloudConnectionStatus.error {
            syncButton.image = #imageLiteral(resourceName: "Cloud Error")
        }
        
        tabBar.backgroundColor = UIColor.teal500
        
        registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewIsVisible = true
        updateData()
        tableView.reloadData()
        
        DataManager.shared.resumeAutoUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewIsVisible = false
    }
    
    @IBAction func syncWithCloud(_ sender: Any) {
        DataManager.shared.fetchDataFromCloud()
    }
    
    @IBAction func segmentPressed(_ sender: Any) {
        updateData()
        tableView.reloadData()
    }
    
    func updateData() {
        dataSections = []
        
        var showsCompletedTasks: Bool = (segmentedControl.selectedSegmentIndex == 1)
        
        var tasksToSort: [Task] = []
        
        for task in DataManager.shared.tasks {
            if task.completed == showsCompletedTasks {
                tasksToSort.append(task)
            }
        }
        
        tasksToSort.sort(by: DataManager.shared.initialSortAlgorithm(showingCompletedTasks: showsCompletedTasks))
        
        func addTask(_ task: Task, toSectionWithName sectionName: String) {
            var found: Bool = false
            
            for i in 0 ..< dataSections.count {
                if dataSections[i].sectionName == sectionName {
                    dataSections[i].tasks.append(task)
                    found = true
                    break
                }
            }
            
            if !found {
                dataSections.append((sectionName: sectionName, tasks: [task]))
            }
        }
        
        if !showsCompletedTasks {
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
                            if days == -1 {
                                if Date().hour <= 6 {
                                    addTask(task, toSectionWithName: "Tonight")
                                } else {
                                    addTask(task, toSectionWithName: "Yesterday")
                                }
                            } else {
                                addTask(task, toSectionWithName: "Overdue")
                            }
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
        } else {
            for task in tasksToSort {
                if let completionDate = task.completionDate?.dateValue {
                    addTask(task, toSectionWithName: "Completed " + BetterDateFormatter.autoFormatDate(completionDate, forSentence: true))
                } else {
                    addTask(task, toSectionWithName: "Completed at some point")
                }
            }
        }
        
        for i in 0 ..< dataSections.count {
            if dataSections[i].sectionName == "Overdue" {
                dataSections[i].tasks = dataSections[i].tasks.sorted(by: { (task1, task2) -> Bool in
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
            
            dataSections[i].tasks = dataSections[i].tasks.sorted(by: DataManager.shared.sectionSortAlgorithm(showingCompletedTasks: showsCompletedTasks))
        }
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath), let previewController = UIStoryboard(name: "Previews", bundle: Bundle.main).instantiateViewController(withIdentifier: "Task Preview") as? TaskPreviewViewController {
            previewController.loadViewIfNeeded()
            
            previewController.task = dataSections[indexPath.section].tasks[indexPath.row]
            previewController.configure()
            previewController.view.layoutSubviews()
            
            previewController.preferredContentSize.height = (previewController.view.viewWithTag(3)?.frame.maxY ?? -12) + 12
            
            previewingContext.sourceRect = cell.frame
            
            return previewController
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let taskPreview = viewControllerToCommit as? TaskPreviewViewController, let taskDetail = storyboard?.instantiateViewController(withIdentifier: "Task Detail") as? TaskTableViewController {
            taskDetail.task = taskPreview.task
            
            DataManager.shared.pauseAutoUpdate()
            
            navigationController?.pushViewController(taskDetail, animated: false)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSections[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSections[section].tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath) as? TaskTableViewCell {
            cell.task = dataSections[indexPath.section].tasks[indexPath.row]
            cell.configureCell()
            
            var shouldDisplayPriority: Bool = true
            for i in 0 ..< indexPath.row {
                if dataSections[indexPath.section].tasks[i].priority == cell.task!.priority {
                    shouldDisplayPriority = false
                    break
                }
            }
            
            cell.priorityIndicator?.isHidden = !shouldDisplayPriority
            
            switch cell.task!.dueDate {
                
            case .specificDay(let day):
                if day >= CalendarDay(date: Date()) {
                    cell.dueDateLabel?.isHidden = true
                }
                break
                
            default: break
                
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = dataSections[indexPath.section].tasks[indexPath.row]
        
        if case let DueDate.specificDay(specificDay) = task.dueDate {
            var overdue: Bool = false
            
            if Date.daysBetween(Date(), and: specificDay.dateValue!) < 0 {
                overdue = true
            }
            
            let procrastinateAction = UIContextualAction(style: UIContextualAction.Style.normal, title: (overdue ? "Move to\ntoday" : "Push back\na day"), handler: { (action, sourceView, completionHandler) in
                var newDueDate: DueDate?
                
                if overdue {
                    newDueDate = DueDate.specificDay(day: CalendarDay(date: Date()))
                } else {
                    newDueDate = DueDate.specificDay(day: CalendarDay(date: specificDay.dateValue!.addingTimeInterval(24 * 60 * 60)))
                }
                
                if newDueDate != nil {
                    task.dueDate = newDueDate!
                    DataManager.shared.update(task.record)
                }
                
                var previousIndexPath: IndexPath!
                var previousSectionName: String!
                var numberOfRowsInPreviousSection: Int = 0
                
                for section in 0 ..< self.dataSections.count {
                    for row in 0 ..< self.dataSections[section].tasks.count {
                        if self.dataSections[section].tasks[row].isEqual(task) {
                            previousIndexPath = IndexPath(row: row, section: section)
                            previousSectionName = self.dataSections[section].sectionName
                            numberOfRowsInPreviousSection = self.dataSections[section].tasks.count
                            break
                        }
                    }
                    
                    if previousIndexPath != nil {
                        break
                    }
                }
                
                self.updateData()
                
                for section in 0 ..< self.dataSections.count {
                    for row in 0 ..< self.dataSections[section].tasks.count {
                        if self.dataSections[section].tasks[row].isEqual(task) {
                            
                            let newSection = self.dataSections[section]
                            let newIndexPath = IndexPath(row: row, section: section)
                            let newSectionName = newSection.sectionName
                            let numberOfRowsInNewSection = newSection.tasks.count
                            
                            if newSectionName == previousSectionName {
                                self.tableView.moveRow(at: indexPath, to: IndexPath(row: row, section: section))
                            } else {
                                self.tableView.beginUpdates()
                                
                                if numberOfRowsInNewSection == 1 {
                                    self.tableView.insertSections(IndexSet(integer: section), with: UITableViewRowAnimation.automatic)
                                }
                                
                                if numberOfRowsInPreviousSection == 1 {
                                    self.tableView.deleteSections(IndexSet(integer: previousIndexPath.section), with: UITableViewRowAnimation.automatic)
                                }
                                
                                self.tableView.deleteRows(at: [previousIndexPath], with: UITableViewRowAnimation.automatic)
                                self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
                                
                                self.tableView.endUpdates()
                            }
                            
                            completionHandler(true)
                            return
                        }
                    }
                }
                
                completionHandler(false)
            })
            
            procrastinateAction.backgroundColor = UIColor.indigo500
            
            return UISwipeActionsConfiguration(actions: [procrastinateAction])
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = dataSections[indexPath.section].tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Delete") { (action, sourceView, completionHandler) in
            if let taskIndex = DataManager.shared.tasks.index(of: task) {
                self.dataSections[indexPath.section].tasks.remove(at: indexPath.row)
                DataManager.shared.delete(task.record)
                DataManager.shared.tasks.remove(at: taskIndex)
                
                if self.dataSections[indexPath.section].tasks.count == 0 {
                    self.dataSections.remove(at: indexPath.section)
                    self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.automatic)
                } else {
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
                
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - DMListener
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType) {
        if eventType == DMLoadingEventType.start {
            syncButton.image = #imageLiteral(resourceName: "Cloud Progress")
        } else if eventType == DMLoadingEventType.end {
            updateData()
            tableView.reloadData()
            
            syncButton.image = #imageLiteral(resourceName: "Cloud Sync")
            
            if tableView.alpha == 0 {
                if viewIsVisible {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.activityIndicator.alpha = 0
                    }) { (completed) in
                        if completed {
                            self.activityIndicator.stopAnimating()
                            UIView.animate(withDuration: 0.2, animations: {
                                self.tableView.alpha = 1
                            })
                        }
                    }
                } else {
                    activityIndicator.alpha = 0
                    tableView.alpha = 1
                }
            }
        } else if eventType == DMLoadingEventType.error {
            syncButton.image = #imageLiteral(resourceName: "Cloud Error")
            
            let alert = UIAlertController(title: "iCloud Error", message: "Could not connect to iCloud. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskController = segue.destination as? TaskTableViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                taskController.task = dataSections[selectedIndexPath.section].tasks[selectedIndexPath.row]
            }
            
            DataManager.shared.pauseAutoUpdate()
        }
    }

}
