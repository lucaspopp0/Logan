//
//  AssignmentsViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/6/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class AssignmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DMListener {
    
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSections: [(sectionName: String, day: CalendarDay?, assignments: [Assignment])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InterfaceManager.shared.assignmentsController = self
        DataManager.shared.addListener(self)
        
        tabBar.backgroundColor = UIColor.teal500
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
    
    func updateData() {
        dataSections = []
        
        var showsPastAssignments: Bool = (segmentedControl.selectedSegmentIndex == 1)
        
        var assignmentsToSort: [Assignment] = []
        
        let today = CalendarDay(date: Date())
        for assignment in DataManager.shared.assignments {
            if assignment.dueDate.intValue == DueDate.asapIntValue || assignment.dueDate.intValue == DueDate.eventuallyIntValue {
                assignmentsToSort.append(assignment)
            } else if case .specificDeadline(let deadline) = assignment.dueDate {
                if (showsPastAssignments && deadline.day < today) || (!showsPastAssignments && today <= deadline.day) {
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
                break
                
            case .specificDeadline(let deadline1):
                switch assignment2.dueDate {
                    
                case .asap:
                    return false
                    
                case .specificDeadline(let deadline2):
                    if showsPastAssignments {
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
        
        func addAssignment(_ assignment: Assignment, toSectionWithName sectionName: String) {
            var found: Bool = false
            
            for i in 0 ..< dataSections.count {
                if dataSections[i].sectionName == sectionName {
                    dataSections[i].assignments.append(assignment)
                    found = true
                    break
                }
            }
            
            if !found {
                var day: CalendarDay?
                
                if case .specificDeadline(let deadline) = assignment.dueDate {
                    day = deadline.day
                }
                
                dataSections.append((sectionName: sectionName, day: day, assignments: [assignment]))
            }
        }
        
        if !showsPastAssignments {
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
        } else {
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
                        addAssignment(assignment, toSectionWithName: BetterDateFormatter.autoFormatDate(dayDate))
                    } else {
                        addAssignment(assignment, toSectionWithName: "Eventually")
                    }
                    break
                    
                default:
                    break
                    
                }
            }
        }
    }
    
    // MARK: - DMListener
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType) {
        if eventType == DMLoadingEventType.end {
            updateData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view delegate/datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSections[section].sectionName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSections[section].assignments.count
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
        
        if dataSections[section].day != nil {
            let formatter = DateFormatter()
            
            if dataSections[section].day!.year == CalendarDay(date: Date()).year {
                formatter.dateFormat = "M/d"
            } else {
                formatter.dateFormat = "M/d/yy"
            }
            
            dateLabel.text = formatter.string(from: dataSections[section].day!.dateValue!)
            
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
            cell.assignment = dataSections[indexPath.section].assignments[indexPath.row]
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
            let assignmentToDelete = dataSections[indexPath.section].assignments[indexPath.row]
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
                    
                    self.dataSections[indexPath.section].assignments.remove(at: indexPath.row)
                    if let assignmentIndex = DataManager.shared.assignments.index(of: assignmentToDelete) {
                        DataManager.shared.delete(assignmentToDelete.record)
                        DataManager.shared.assignments.remove(at: assignmentIndex)
                    }
                    
                    if self.dataSections[indexPath.section].assignments.count == 0 {
                        self.dataSections.remove(at: indexPath.section)
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
                
                dataSections[indexPath.section].assignments.remove(at: indexPath.row)
                if let assignmentIndex = DataManager.shared.assignments.index(of: assignmentToDelete) {
                    DataManager.shared.delete(assignmentToDelete.record)
                    DataManager.shared.assignments.remove(at: assignmentIndex)
                }
                
                if dataSections[indexPath.section].assignments.count == 0 {
                    dataSections.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let assignmentController = segue.destination as? AssignmentTableViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                assignmentController.assignment = dataSections[selectedIndexPath.section].assignments[selectedIndexPath.row]
            }
            
            DataManager.shared.pauseAutoUpdate()
        }
    }

}
