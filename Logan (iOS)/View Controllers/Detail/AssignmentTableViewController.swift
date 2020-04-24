//
//  AssignmentTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/8/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class AssignmentTableViewController: UITableViewController, UITextViewDelegate, AssignmentDueDatePickerDelegate, CoursePickerDelegate {
    
    var assignment: Assignment! {
        didSet {
            assignmentTasks = DataManager.shared.tasksFor(assignment).sorted(by: Sorting.sortTasksForAssignment(_:_:))
        }
    }
    
    private var assignmentTasks: [Task] = []
    
    private var titleView: UITextView!
    private var descriptionView: UITextView!
    
    private var dueDateLabel: UILabel!
    private var dueDateTypeControl: UISegmentedControl!
    private var specificDueDatePicker: BetterDatePicker!
    
    private var courseLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assignmentTasks = DataManager.shared.tasksFor(assignment).sorted(by: Sorting.sortTasksForAssignment(_:_:))
        tableView.reloadSections([2, 3], with: UITableViewRowAnimation.none)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        assignment.title = titleView.text
        assignment.userDescription = descriptionView.text
        
        DataManager.shared.update(assignment.record)
    }
    
    private func updateDueDateText() {
        switch assignment.dueDate {
            
        case .asap:
            dueDateLabel.text = "ASAP"
            break
            
        case .eventually:
            dueDateLabel.text = "Eventually"
            break
            
        case .specificDeadline(let deadline):
            if let dayDate = deadline.day.dateValue {
                dueDateLabel.text = BetterDateFormatter.autoFormatDate(dayDate)
            } else {
                dueDateLabel.text = "Eventually"
            }
            break
            
        default: break
            
        }
    }
    
    @IBAction func specificDueDatePicked(_ sender: BetterDatePicker) {
        assignment.dueDate = DueDate.specificDeadline(deadline: BetterDate(date: specificDueDatePicker.dateValue))
        
        updateDueDateText()
    }
    
    // MARK: - Assignment due date picker delegate
    
    func dueDateTypeChanged(in cell: AssignmentDueDateTableViewCell) {
        if cell.segmentedControl.selectedSegmentIndex == 0 {
            assignment.dueDate = DueDate.specificDeadline(deadline: BetterDate(date: specificDueDatePicker.dateValue))
        } else if cell.segmentedControl.selectedSegmentIndex == 2 {
            assignment.dueDate = DueDate.asap
        } else if cell.segmentedControl.selectedSegmentIndex == 3 {
            assignment.dueDate = DueDate.eventually
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        updateDueDateText()
        
        if cell.pickerOpen {
            if cell.segmentedControl.selectedSegmentIndex == 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
            } else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: UITableViewScrollPosition.none, animated: true)
            }
        }
    }
    
    // MARK: - Text view delegate
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Course Picker Delegate
    
    func selectedCourse(_ course: Course?, in picker: CoursePickerTableViewController) {
        assignment.course = course
        courseLabel.text = assignment.course?.name ?? "None"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return assignmentTasks.count + 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Title", for: indexPath)
                
                if let textView = cell.viewWithTag(1) as? UITextView {
                    titleView = textView
                    titleView.text = assignment.title
                }
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Description", for: indexPath)
                
                if let textView = cell.viewWithTag(1) as? UITextView {
                    descriptionView = textView
                    descriptionView.text = assignment.userDescription
                }
                
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Due Date", for: indexPath) as? AssignmentDueDateTableViewCell {
                    dueDateLabel = cell.displayLabel
                    
                    dueDateTypeControl = cell.segmentedControl
                    specificDueDatePicker = cell.datePicker
                    
                    switch assignment.dueDate {
                    case .specificDeadline(let deadline):
                        dueDateTypeControl.selectedSegmentIndex = 0
                        specificDueDatePicker.calendarDay = deadline.day
                        break
                    case .asap:
                        dueDateTypeControl.selectedSegmentIndex = 2
                        break
                    case .eventually:
                        dueDateTypeControl.selectedSegmentIndex = 3
                        break
                    default: break
                    }
                    cell.segmentSelected(dueDateTypeControl)
                    updateDueDateText()
                    
                    return cell
                }
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Course", for: indexPath)
                
                if let label = cell.viewWithTag(1) as? UILabel {
                    courseLabel = label
                    courseLabel.text = assignment.course?.longerName ?? "None"
                    courseLabel.textColor = assignment.course?.color ?? UIColor.black.withAlphaComponent(0.5)
                }
                
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Add Task", for: indexPath)
                cell.textLabel?.textColor = UIColor.teal500
                return cell
            } else if let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath) as? AssignmentTaskTableViewCell {
                cell.task = assignmentTasks[indexPath.row]
                cell.configureCell()
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? AssignmentDueDateTableViewCell {
                return cell.fittingHeight
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Tasks"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            tableView.endEditing(true)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if let pickerCell = tableView.cellForRow(at: indexPath) as? AssignmentDueDateTableViewCell {
                if pickerCell.pickerOpen {
                    tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 && indexPath.row < tableView.numberOfRows(inSection: indexPath.section) - 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 2 {
                let taskToDelete = assignmentTasks[indexPath.row]
                
                if let taskIndex = DataManager.shared.tasks.index(of: taskToDelete) {
                    DataManager.shared.delete(taskToDelete.record)
                    DataManager.shared.tasks.remove(at: taskIndex)
                }
                
                assignmentTasks = DataManager.shared.tasksFor(assignment)
                
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskController = segue.destination as? TaskTableViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if let cell = tableView.cellForRow(at: selectedIndexPath) as? AssignmentTaskTableViewCell {
                    taskController.task = cell.task
                }
            }
        } else if let coursePicker = segue.destination as? CoursePickerTableViewController {
            coursePicker.course = assignment.course
            coursePicker.delegate = self
            coursePicker.tableView.reloadData()
        } else if let navigationController = segue.destination as? BetterNavigationController {
            if let newTaskController = navigationController.topViewController as? NewTaskTableViewController {
                newTaskController.task.relatedAssignment = assignment
            }
        }
    }

}
