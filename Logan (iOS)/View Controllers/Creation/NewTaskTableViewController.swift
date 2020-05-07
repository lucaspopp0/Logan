//
//  NewTaskTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewTaskTableViewController: CreationController, UITextViewDelegate, CoursePickerDelegate {

    let task = Task(id: "newtask", title: "")!
    
    private var checkbox: UICheckbox!
    private var titleView: UITextView!
    private var descriptionView: UITextView!
    
    private var dueDateLabel: UILabel!
    private var nextConvenientDateButton: UIButton!
    private var dueDateTypeControl: UISegmentedControl!
    private var specificDueDatePicker: BetterDatePicker!
    
    private var courseLabel: UILabel!
    
    private var priorityControl: PriorityControl!
    
    @IBAction override func done(_ sender: Any) {
        super.done(sender)
        
        view.endEditing(true)
        checkbox.isEnabled = false
        titleView.isEditable = false
        descriptionView.isEditable = false
        nextConvenientDateButton.isEnabled = false
        dueDateTypeControl.isEnabled = false
        specificDueDatePicker.isEnabled = false
        priorityControl.isEnabled = false
        
        API.shared.addTask(task) { (success, blob) in
            if success {
                self.task.id = blob!["tid"] as! String
                DataManager.shared.tasks.append(self.task)
                InterfaceManager.shared.tasksController.updateData()
                InterfaceManager.shared.tasksController.tableView.reloadData()
            } else {
                print("Error creating new task")
                // TODO: Inform user
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateDueDateText() {
        switch task.dueDate {
            
        case .asap:
            dueDateLabel.text = "ASAP"
            break
            
        case .eventually:
            dueDateLabel.text = "Eventually"
            break
            
        case .specificDay(let specificDay):
            if let specificDate = specificDay.dateValue {
                let today = Date()
                let days = Date.daysBetween(today, and: specificDate)
                
                if specificDay == CalendarDay(date: today) {
                    dueDateLabel.text = "Today"
                } else if days < 0 {
                    dueDateLabel.text = "Overdue"
                } else if days == 1 {
                    dueDateLabel.text = "Tomorrow"
                } else if today.weekOfYear == specificDate.weekOfYear {
                    dueDateLabel.text = DayOfWeek.forDate(specificDate).longName()
                } else {
                    let formatter = BetterDateFormatter()
                    
                    if today.year != specificDate.year {
                        formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                    } else {
                        formatter.dateFormat = "EEEE, MMMM dnn"
                    }
                    
                    dueDateLabel.text = formatter.string(from: specificDate)
                }
            } else {
                dueDateLabel.text = "Invalid date"
            }
            
            break
            
        default: break
            
        }
    }
    
    @IBAction func dueDateTypeChanged(_ sender: UISegmentedControl) {
        tableView.beginUpdates()
        
        if sender.selectedSegmentIndex == 0 {
            task.dueDate = DueDate.specificDay(day: specificDueDatePicker.calendarDay)
        } else if sender.selectedSegmentIndex == 1 {
            task.dueDate = DueDate.asap
        } else if sender.selectedSegmentIndex == 2 {
            task.dueDate = DueDate.eventually
        }
        
        tableView.endUpdates()
        
        updateDueDateText()
    }
    
    @IBAction func specificDueDatePicked(_ sender: BetterDatePicker) {
        task.dueDate = DueDate.specificDay(day: sender.calendarDay)
        
        updateDueDateText()
    }
    
    @IBAction func priorityChanged(_ sender: UISegmentedControl) {
        task.priority = priorityControl.priority
        checkbox.priority = task.priority
    }
    
    // MARK: - Text view delegate
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        
        task.title = titleView.text
        task.userDescription = descriptionView.text
        
        tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if task.relatedAssignment != nil {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Name", for: indexPath)
                
                if let checkbox = cell.viewWithTag(1) as? UICheckbox {
                    self.checkbox = checkbox
                    checkbox.isOn = task.completed
                    checkbox.priority = task.priority
                }
                
                if let textView = cell.viewWithTag(2) as? UITextView {
                    titleView = textView
                    titleView.text = task.title
                    
                    if !alreadyOpened {
                        alreadyOpened = true
                        titleView.becomeFirstResponder()
                    }
                }
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Description", for: indexPath)
                
                if let textView = cell.viewWithTag(1) as? UITextView {
                    descriptionView = textView
                    descriptionView.text = task.userDescription
                }
                
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Due Date", for: indexPath) as? TaskDueDatePickerTableViewCell {
                    dueDateLabel = cell.displayLabel
                    dueDateTypeControl = cell.segmentedControl
                    nextConvenientDateButton = cell.nextConvenientDateButton
                    specificDueDatePicker = cell.datePicker
                    
                    if task.associatedCourse == nil {
                        nextConvenientDateButton.setTitle("Tomorrow", for: UIControlState.normal)
                    } else {
                        nextConvenientDateButton.setTitle("Before next class", for: UIControlState.normal)
                    }
                    
                    updateDueDateText()
                    
                    switch task.dueDate {
                        
                    case .specificDay(let day):
                        dueDateTypeControl.selectedSegmentIndex = 0
                        specificDueDatePicker.calendarDay = day
                        break
                        
                    case .asap:
                        dueDateTypeControl.selectedSegmentIndex = 1
                        break
                        
                    case .eventually:
                        dueDateTypeControl.selectedSegmentIndex = 2
                        break
                        
                    default: break
                        
                    }
                    
                    return cell
                }
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Priority", for: indexPath)
                
                if let picker = cell.viewWithTag(1) as? PriorityControl {
                    priorityControl = picker
                    priorityControl.priority = task.priority
                }
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Course", for: indexPath)
                
                if task.relatedAssignment != nil {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                }
                
                if let label = cell.viewWithTag(1) as? UILabel {
                    courseLabel = label
                    courseLabel.text = task.associatedCourse?.longerName ?? "None"
                    courseLabel.textColor = task.associatedCourse?.color ?? UIColor.black.withAlphaComponent(0.5)
                }
                
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Related Assignment", for: indexPath) as? AssignmentTableViewCell {
                    cell.assignment = task.relatedAssignment
                    cell.configureCell()
                    
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? TaskDueDatePickerTableViewCell {
                return cell.fittingHeight
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Related Assignment"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            tableView.endEditing(true)
        }
        
        if isSending { return }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.beginUpdates()
            tableView.endUpdates()
            
            if let pickerCell = tableView.cellForRow(at: indexPath) as? TaskDueDatePickerTableViewCell {
                if pickerCell.pickerOpen {
                    tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                }
            }
        } else if indexPath.section == 1 && indexPath.row == 2 {
            if task.relatedAssignment == nil {
                self.performSegue(withIdentifier: "Open Course Picker", sender: self)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Course picker delegate
    
    func selectedCourse(_ course: Course?, in picker: CoursePickerTableViewController) {
        task.course = course
        courseLabel.text = course?.longerName ?? "None"
        courseLabel.textColor = course?.color ?? UIColor.black.withAlphaComponent(0.5)
        
        if course == nil {
            nextConvenientDateButton.setTitle("Tomorrow", for: UIControlState.normal)
        } else {
            nextConvenientDateButton.setTitle("Before next class", for: UIControlState.normal)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let coursePicker = segue.destination as? CoursePickerTableViewController {
            coursePicker.course = task.course
            coursePicker.delegate = self
            coursePicker.tableView.reloadData()
        } else if let assignmentController = segue.destination as? AssignmentTableViewController {
            assignmentController.assignment = task.relatedAssignment
            assignmentController.title = "Related Assignment"
        }
    }

}
