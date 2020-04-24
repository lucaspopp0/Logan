//
//  AssignmentsViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/6/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class AssignmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate, DataManagerListener {
    
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var isShowingPastAssignments: Bool {
        get {
            return segmentedControl.selectedSegmentIndex == 1
        }
    }
    
    let data: TableData<Assignment> = TableData<Assignment>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InterfaceManager.shared.assignmentsController = self
        DataManager.shared.addListener(self)
        
        tabBar.backgroundColor = UIColor.teal500
        
        registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
        tableView.reloadData()
        
        DataManager.shared.resumeAutoUpdate()
    }
    
    @IBAction func syncWithCloud(_ sender: Any) {
        DataManager.shared.fetchDataFromCloud()
    }
    
    @IBAction func segmentPressed(_ sender: Any) {
        updateData()
        tableView.reloadData()
    }
    
    private func groupNameForAssignment(_ assignment: Assignment) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        
        switch assignment.dueDate {
        case .asap:
            return "ASAP"
            
        case .eventually:
            return "Eventually"
            
        case .specificDeadline(let deadline):
            if let dayDate = deadline.day.dateValue {
                if !isShowingPastAssignments && deadline.day < CalendarDay.today {
                    return "Overdue"
                } else {
                    return formatter.string(from: dayDate)
                }
            } else {
                return "Eventually"
            }
            
        default:
            return ""
        }
    }
    
    private func titleForGroup(_ groupName: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        
        if let groupDate = formatter.date(from: groupName) {
            if isShowingPastAssignments {
                return BetterDateFormatter.autoFormatDate(groupDate)
            } else {
                let today = Date()
                let days = Date.daysBetween(today, and: groupDate)
                
                if days == 0 {
                    return "Today"
                } else if days < 0 {
                    return "Overdue"
                } else if days == 1 {
                    return "Tomorrow"
                } else if today.weekOfYear == groupDate.weekOfYear {
                    return DayOfWeek.forDate(groupDate).longName()
                } else {
                    let betterFormatter = BetterDateFormatter()
                    
                    if today.year != groupDate.year {
                        betterFormatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                    } else {
                        betterFormatter.dateFormat = "EEEE, MMMM dnn"
                    }
                    
                    return betterFormatter.string(from: groupDate)
                }
            }
        } else {
            return groupName
        }
        
        return groupName
    }
    
    func updateData() {
        data.clear()
        
        var assignmentsToSort: [Assignment] = []
        
        let today = CalendarDay(date: Date())
        for assignment in DataManager.shared.assignments {
            if assignment.dueDate.dbValue == "asap" || assignment.dueDate.dbValue == "eventually" {
                assignmentsToSort.append(assignment)
            } else if case .specificDeadline(let deadline) = assignment.dueDate {
                if (isShowingPastAssignments && deadline.day < today) || (!isShowingPastAssignments && today <= deadline.day) {
                    assignmentsToSort.append(assignment)
                }
            }
        }
        
        assignmentsToSort.sort { (assignment1, assignment2) -> Bool in
            switch assignment1.dueDate {
                
            case .asap:
                switch assignment2.dueDate {
                    
                case .asap:
                    // TODO: Add more elaborate sorting
                    return true
                    
                default:
                    return true
                }
                
            case .specificDeadline(let deadline1):
                switch assignment2.dueDate {
                    
                case .asap:
                    return false
                    
                case .specificDeadline(let deadline2):
                    if isShowingPastAssignments {
                        return deadline1 > deadline2
                    } else {
                        return deadline1 < deadline2
                    }
                    
                default:
                    return true
                    
                }
                
            case .eventually:
                return false
                
            default:
                return true
                
            }
        }
        
        for assignment in assignmentsToSort {
            data.add(item: assignment, section: groupNameForAssignment(assignment))
        }
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?) {
        if eventType == DataManager.LoadingEventType.end {
            updateData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view delegate/datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForGroup(data.sections[section].title)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.97, alpha: 1)
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        
        let dateLabel = UILabel()
        dateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        dateLabel.textColor = UIColor(white: 0.5, alpha: 1)
        
        titleLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        container.addSubview(titleLabel)
        
        titleLabel.sizeToFit()
        titleLabel.frame.origin = CGPoint(x: 15, y: 4)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        
        if let date = formatter.date(from: data.sections[section].title) {
            let day = CalendarDay(date: date)
            
            if day.year == CalendarDay.today.year {
                formatter.dateFormat = "M/d"
            } else {
                formatter.dateFormat = "M/d/yy"
            }
            
            dateLabel.text = formatter.string(from: date)
            
            container.addSubview(dateLabel)
            
            dateLabel.sizeToFit()
            dateLabel.frame.origin = CGPoint(x: tableView.frame.size.width - dateLabel.frame.size.width - 15, y: 4)
        }
        
        container.frame.size.width = tableView.frame.size.width
        container.frame.size.height = titleLabel.frame.midY * 2
        
        return container
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Assignment", for: indexPath) as? AssignmentTableViewCell {
            cell.assignment = data.sections[indexPath.section].items[indexPath.row]
            cell.configureCell()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let assignmentToDelete = data.sections[indexPath.section].items[indexPath.row]
            let tasksToDelete = DataManager.shared.tasksFor(assignmentToDelete)
            
            if tasksToDelete.count > 0 {
                let alert = UIAlertController(title: "Delete Assignment", message: "Are you sure? You will not be able to get this assignment back.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                    for taskToDelete in tasksToDelete {
                        if let taskIndex = DataManager.shared.tasks.index(of: taskToDelete) {
                            DataManager.shared.delete(taskToDelete.record)
                            DataManager.shared.tasks.remove(at: taskIndex)
                        }
                    }
                    
                    self.data.sections[indexPath.section].items.remove(at: indexPath.row)
                    if let assignmentIndex = DataManager.shared.assignments.index(of: assignmentToDelete) {
                        DataManager.shared.delete(assignmentToDelete.record)
                        DataManager.shared.assignments.remove(at: assignmentIndex)
                    }
                    
                    if self.data.sections[indexPath.section].items.count == 0 {
                        self.data.sections.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.automatic)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    }
                }))
            } else {
                for taskToDelete in tasksToDelete {
                    if let taskIndex = DataManager.shared.tasks.index(of: taskToDelete) {
                        DataManager.shared.delete(taskToDelete.record)
                        DataManager.shared.tasks.remove(at: taskIndex)
                    }
                }
                
                data.sections[indexPath.section].items.remove(at: indexPath.row)
                if let assignmentIndex = DataManager.shared.assignments.index(of: assignmentToDelete) {
                    DataManager.shared.delete(assignmentToDelete.record)
                    DataManager.shared.assignments.remove(at: assignmentIndex)
                }
                
                if data.sections[indexPath.section].items.count == 0 {
                    data.sections.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath), let previewController = UIStoryboard(name: "Previews", bundle: Bundle.main).instantiateViewController(withIdentifier: "Assignment Preview") as? AssignmentPreviewViewController {
            previewController.loadViewIfNeeded()
            
            previewController.assignment = data.sections[indexPath.section].items[indexPath.row]
            previewController.configure()
            
            previewController.preferredContentSize.height = previewController.taskList.frame.origin.y
            
            previewingContext.sourceRect = cell.frame
            
            return previewController
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let assignmentPreview = viewControllerToCommit as? AssignmentPreviewViewController, let assignmentDetail = storyboard?.instantiateViewController(withIdentifier: "Assignment Detail") as? AssignmentTableViewController {
            assignmentDetail.assignment = assignmentPreview.assignment
            
            DataManager.shared.pauseAutoUpdate()
            
            navigationController?.pushViewController(assignmentDetail, animated: false)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let assignmentController = segue.destination as? AssignmentTableViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                assignmentController.assignment = data.sections[selectedIndexPath.section].items[selectedIndexPath.row]
            }
            
            DataManager.shared.pauseAutoUpdate()
        }
    }

}
