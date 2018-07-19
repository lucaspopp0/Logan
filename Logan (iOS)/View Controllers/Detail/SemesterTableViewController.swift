//
//  SemesterTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/6/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SemesterTableViewController: UITableViewController {
    
    var semester: Semester!
    
    private var nameField: UITextField!
    
    private var startDateLabel: UILabel!
    private var startDatePicker: BetterDatePicker!
    
    private var endDateLabel: UILabel!
    private var endDatePicker: BetterDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataManager.shared.update(semester.record)
    }
    
    @IBAction func boundarySet(_ sender: BetterDatePicker) {
        if startDatePicker.isEqual(sender) {
            semester.startDate = sender.calendarDay
        } else if endDatePicker.isEqual(sender) {
            semester.endDate = sender.calendarDay
        }
        
        updateBoundaryTitles()
    }
    
    private func updateBoundaryTitles() {
        startDateLabel.text = BetterDateFormatter.autoFormatDate(semester.startDate.dateValue!)
        endDateLabel.text = BetterDateFormatter.autoFormatDate(semester.endDate.dateValue!)
    }
    
    @IBAction func updateName(_ sender: Any) {
        semester.name = nameField.text ?? ""
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
            
        case 1:
            return semester.courses.count + 1
            
        case 2:
            return 1
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let cell = tableView.cellForRow(at: indexPath) as? PickerTableViewCell {
                return cell.fittingHeight
            }
        }
        
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Name", for: indexPath)
                
                if let field = cell.viewWithTag(1) as? UITextField {
                    nameField = field
                    field.text = semester.name
                }
                
                return cell
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Boundary", for: indexPath) as? PickerTableViewCell {
                    if indexPath.row == 1 {
                        cell.label.text = "Begins"
                        startDateLabel = cell.displayLabel!
                        startDateLabel.text = BetterDateFormatter.autoFormatDate(semester.startDate.dateValue!)
                        
                        if let datePicker = cell.picker as? BetterDatePicker {
                            startDatePicker = datePicker
                            startDatePicker.calendarDay = semester.startDate
                        }
                    } else if indexPath.row == 2 {
                        cell.label.text = "Ends"
                        endDateLabel = cell.displayLabel!
                        endDateLabel.text = BetterDateFormatter.autoFormatDate(semester.endDate.dateValue!)
                        
                        if let datePicker = cell.picker as? BetterDatePicker {
                            endDatePicker = datePicker
                            endDatePicker.calendarDay = semester.endDate
                        }
                    }
                    
                    return cell
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == tableView.numberOfRows(inSection: 1) - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Add Course", for: indexPath)
                cell.textLabel?.textColor = UIColor.teal500
                return cell
            } else if let cell = tableView.dequeueReusableCell(withIdentifier: "Course", for: indexPath) as? CourseTableViewCell {
                cell.course = semester.courses[indexPath.row]
                cell.configureCell()
                
                return cell
            }
        } else if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "Delete Semester", for: indexPath)
        }

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Courses"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.beginUpdates()
            tableView.endUpdates()
        } else if indexPath.section == 2 {
            let alert = UIAlertController(title: "Delete Semester", message: "Are you sure? This action cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                tableView.deselectRow(at: indexPath, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                tableView.deselectRow(at: indexPath, animated: true)
                
                if let semesterIndex = DataManager.shared.semesters.index(of: self.semester) {
                    DataManager.shared.delete(self.semester.record)
                    DataManager.shared.semesters.remove(at: semesterIndex)
                }
                
                self.navigationController?.popViewController(animated: true)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row < tableView.numberOfRows(inSection: 1) - 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.shared.delete(semester.courses[indexPath.row].record)
            semester.courses.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseController = segue.destination as? CourseTableViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if let cell = tableView.cellForRow(at: selectedIndexPath) as? CourseTableViewCell {
                    courseController.course = cell.course
                }
            }
        } else if let navigationController = segue.destination as? BetterNavigationController {
            if let newCourseController = navigationController.topViewController as? NewCourseTableViewController {
                newCourseController.correspondingSemester = semester
            }
        }
    }

}
