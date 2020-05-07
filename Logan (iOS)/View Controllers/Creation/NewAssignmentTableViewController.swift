//
//  NewAssignmentTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewAssignmentTableViewController: UITableViewController, UITextViewDelegate, AssignmentDueDatePickerDelegate, CoursePickerDelegate {

    let assignment: Assignment = Assignment()
    var correspondingTask: Task?
    
    private var titleView: UITextView!
    private var descriptionView: UITextView!
    
    private var dueDateLabel: UILabel!
    private var dueDateTypeControl: UISegmentedControl!
    private var specificDueDatePicker: BetterDatePicker!
    
    private var courseLabel: UILabel!
    
    private var alreadyLoaded: Bool = false
    
    private var automaticallyAddSwitch: UISwitch!
    private var taskDueDateLabel: UILabel?
    private var taskDueDateTypeControl: UISegmentedControl?
    private var taskDueDatePicker: BetterDatePicker?
    private var taskPriorityPicker: PriorityControl?
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        assignment.title = titleView.text
        assignment.userDescription = descriptionView.text
        
        DataManager.shared.assignments.append(assignment)
        DataManager.shared.introduce(assignment.record)
        
        if correspondingTask != nil {
            correspondingTask?.title = titleView.text
            correspondingTask?.userDescription = assignment.userDescription
            
            DataManager.shared.tasks.append(correspondingTask!)
            DataManager.shared.introduce(correspondingTask!.record)
        }
        
        InterfaceManager.shared.assignmentsController.updateData()
        InterfaceManager.shared.assignmentsController.tableView.reloadData()
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
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
            if let date = deadline.dateValue {
                dueDateLabel.text = BetterDateFormatter.autoFormatDate(date)
            }
            break
            
        default: break
            
        }
    }
    
    private func updateTaskDueDateText() {
        if correspondingTask != nil {
            switch correspondingTask!.dueDate {
                
            case .asap:
                taskDueDateLabel?.text = "ASAP"
                break
                
            case .eventually:
                taskDueDateLabel?.text = "Eventually"
                break
                
            case .specificDay(let specificDay):
                if let specificDate = specificDay.dateValue {
                    taskDueDateLabel?.text = BetterDateFormatter.autoFormatDate(specificDate)
                } else {
                    taskDueDateLabel?.text = "Invalid date"
                }
                
                break
                
            default: break
                
            }
        }
    }
    
    @IBAction func dueDateTypeChanged(_ sender: UISegmentedControl) {
        tableView.beginUpdates()
        
        if sender.isEqual(taskDueDateTypeControl) {
            if sender.selectedSegmentIndex == 0 {
                if taskDueDatePicker != nil {
                    correspondingTask?.dueDate = DueDate.specificDay(day: taskDueDatePicker!.calendarDay)
                }
            } else if sender.selectedSegmentIndex == 1 {
                correspondingTask?.dueDate = DueDate.asap
            } else if sender.selectedSegmentIndex == 2 {
                correspondingTask?.dueDate = DueDate.eventually
            }
            
            updateTaskDueDateText()
        }
        
        tableView.endUpdates()
    }
    
    @IBAction func specificDueDatePicked(_ sender: BetterDatePicker) {
        if sender.isEqual(specificDueDatePicker) {
            assignment.dueDate = DueDate.specificDeadline(deadline: BetterDate(date: specificDueDatePicker.dateValue))
            
            updateDueDateText()
        } else if sender.isEqual(taskDueDatePicker) {
            correspondingTask?.dueDate = DueDate.specificDay(day: taskDueDatePicker!.calendarDay)
            
            updateTaskDueDateText()
        }
    }
    
    @IBAction func correspondingTaskToggled(_ sender: UISwitch) {
        if sender.isOn {
            correspondingTask = Task()
            correspondingTask?.relatedAssignment = assignment
            
            switch assignment.dueDate {
                
            case .asap:
                correspondingTask?.dueDate = DueDate.asap
                break
                
            case .eventually:
                correspondingTask?.dueDate = DueDate.eventually
                break
                
            case .specificDeadline(let deadline):
                if let date = deadline.dateValue {
                    correspondingTask?.dueDate = DueDate.specificDay(day: CalendarDay(date: date.addingTimeInterval(-24 * 60 * 60)))
                }
                break
                
            default: break
            }
            
            tableView.insertRows(at: [IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2)], with: UITableViewRowAnimation.automatic)
        } else {
            correspondingTask = nil
            tableView.deleteRows(at: [IndexPath(row: 1, section: 2), IndexPath(row: 2, section: 2)], with: UITableViewRowAnimation.automatic)
        }
    }
    
    @IBAction func taskPriorityChanged(_ sender: PriorityControl) {
        correspondingTask?.priority = sender.priority
    }
    
    // MARK: - Assignment due date picker delegate
    
    func dueDateTypeChanged(in cell: AssignmentDueDateTableViewCell) {
        if cell.segmentedControl.selectedSegmentIndex >= 0, let selectedSegment = cell.segmentedControl.titleForSegment(at: cell.segmentedControl.selectedSegmentIndex) {
            if selectedSegment == "On date" {
                assignment.dueDate = DueDate.specificDeadline(deadline: BetterDate(date: specificDueDatePicker.dateValue))
            } else if selectedSegment == "Before class" {
                
            } else if selectedSegment == "ASAP" {
                assignment.dueDate = DueDate.asap
            } else if selectedSegment == "Eventually" {
                assignment.dueDate = DueDate.eventually
            }
        }
        
        updateDueDateText()
        
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
        if textView.isEqual(titleView) {
            assignment.title = titleView.text
        } else if textView.isEqual(descriptionView) {
            assignment.userDescription = descriptionView.text
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Commitment picker delegate
    
    func selectedCourse(_ course: Course?, in picker: CoursePickerTableViewController) {
        assignment.course = course
        courseLabel.text = assignment.course?.longerName ?? "None"
        courseLabel.textColor = assignment.course?.color ?? UIColor.black.withAlphaComponent(0.5)
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
            if automaticallyAddSwitch != nil && automaticallyAddSwitch.isOn {
                return 3
            } else {
                return 1
            }
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
                    
                    if !alreadyLoaded {
                        alreadyLoaded = true
                        titleView.becomeFirstResponder()
                    }
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
                    updateDueDateText()
                    
                    dueDateTypeControl = cell.segmentedControl

                    switch assignment.dueDate {
                    case .specificDeadline(_):
                        dueDateTypeControl.selectedSegmentIndex = 0
                        break
                    case .asap:
                        dueDateTypeControl.selectedSegmentIndex = 1
                        break
                    case .eventually:
                        dueDateTypeControl.selectedSegmentIndex = 2
                        break
                    default: break
                    }
                    
                    specificDueDatePicker = cell.datePicker
                    
                    switch assignment.dueDate {
                        
                    case .specificDeadline(let deadline):
                        specificDueDatePicker.calendarDay = deadline.day
                        break
                        
                    default:
                        specificDueDatePicker.calendarDay = CalendarDay(date: Date())
                        break
                        
                    }
                    
                    return cell
                }
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Commitment", for: indexPath)
                
                if let label = cell.viewWithTag(1) as? UILabel {
                    courseLabel = label
                    courseLabel.text = assignment.course?.name ?? "None"
                }
                
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Corresponding Task", for: indexPath)
                
                if let cellSwitch = cell.viewWithTag(1) as? UISwitch {
                    automaticallyAddSwitch = cellSwitch
                }
                
                return cell
            } else if indexPath.row == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Task Due Date", for: indexPath) as? TaskDueDatePickerTableViewCell {
                    taskDueDateLabel = cell.displayLabel
                    taskDueDateTypeControl = cell.segmentedControl
                    taskDueDatePicker = cell.datePicker
                    
                    if correspondingTask != nil {
                        updateTaskDueDateText()
                        
                        switch correspondingTask!.dueDate {
                        case .specificDay(let day):
                            taskDueDateTypeControl?.selectedSegmentIndex = 0
                            taskDueDatePicker?.calendarDay = day
                            break
                        case .asap:
                            taskDueDateTypeControl?.selectedSegmentIndex = 1
                            break
                        case .eventually:
                            taskDueDateTypeControl?.selectedSegmentIndex = 2
                            break
                        default: break
                        }
                    }
                    
                    return cell
                }
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Task Priority", for: indexPath)
                
                if let picker = cell.viewWithTag(1) as? PriorityControl {
                    taskPriorityPicker = picker
                    
                    if correspondingTask != nil {
                        taskPriorityPicker?.priority = correspondingTask!.priority
                    }
                }
                
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
        } else if indexPath.section == 2 && indexPath.row == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? TaskDueDatePickerTableViewCell {
                return cell.fittingHeight
            }
        }
        
        return UITableViewAutomaticDimension
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
        } else if indexPath.section == 2 && indexPath.row == 1 {
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if let pickerCell = tableView.cellForRow(at: indexPath) as? TaskDueDatePickerTableViewCell {
                if pickerCell.pickerOpen {
                    tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Corresponding Task"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "A corresponding task reminding you to complete this assignment can be added automatically."
        }
        
        return nil
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let coursePicker = segue.destination as? CoursePickerTableViewController {
            coursePicker.course = assignment.course
            coursePicker.delegate = self
            coursePicker.tableView.reloadData()
        }
    }

}
