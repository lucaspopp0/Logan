//
//  CourseTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class CourseTableViewController: UITableViewController, UITextViewDelegate {
    
    var course: Course!
    
    private var nameView: UITextView!
    private var nicknameView: UITextView!
    private var descriptorField: UITextField!
    private var colorSwatch: UIColorSwatch!
    private var colorPicker: UIColorPicker!
    
    private var colorPickerOpen: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = course.color
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            navigationController?.navigationBar.barTintColor = UIColor.teal500
            
            DataManager.shared.update(course.record)
        }
    }
    
    @IBAction func descriptorUpdated(_ sender: UITextField) {
        course.descriptor = descriptorField.text ?? ""
    }
    
    @IBAction func toggleColorPicker(_ sender: UIColorSwatch) {
        tableView.beginUpdates()
        colorPickerOpen = !colorPickerOpen
        tableView.endUpdates()
    }
    
    @IBAction func colorPicked(_ sender: UIColorPicker) {
        course.color = sender.colorValue
        colorSwatch.colorValue = sender.colorValue
        navigationController?.navigationBar.barTintColor = sender.colorValue
        
        tableView.reloadRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 1) - 1, section: 1)], with: UITableViewRowAnimation.automatic)
    }
    
    // MARK: - Text view delegate
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        
        course.name = nameView.text
        course.nickname = nicknameView.text
        
        tableView.endUpdates()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1 + course.classes.count
        } else if section == 2 {
            return 1 + course.exams.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Name", for: indexPath)
                
                if let textView = cell.viewWithTag(1) as? UITextView {
                    nameView = textView
                    nameView.text = course.name
                }
                
                if let colorSwatch = cell.viewWithTag(2) as? UIColorSwatch {
                    self.colorSwatch = colorSwatch
                    colorSwatch.colorValue = course.color
                }
                
                if let colorPicker = cell.viewWithTag(3) as? UIColorPicker {
                    self.colorPicker = colorPicker
                }
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Nickname", for: indexPath)
                
                if let textView = cell.viewWithTag(1) as? UITextView {
                    nicknameView = textView
                    nicknameView.text = course.nickname
                }
                
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Descriptor", for: indexPath)
                
                if let textField = cell.viewWithTag(1) as? UITextField {
                    descriptorField = textField
                    descriptorField.text = course.descriptor
                }
                
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == course.classes.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Add Class", for: indexPath)
                cell.textLabel?.textColor = course.color
                return cell
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Class", for: indexPath) as? ClassTableViewCell {
                    cell.classToDisplay = course.classes[indexPath.row]
                    cell.configureCell()
                    
                    return cell
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == course.exams.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Add Exam", for: indexPath)
                cell.textLabel?.textColor = course.color
                return cell
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Exam", for: indexPath) as? ExamTableViewCell {
                    cell.exam = course.exams[indexPath.row]
                    cell.configureCell()
                    
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            if tableView.cellForRow(at: indexPath) != nil {
                if colorPickerOpen {
                    return colorPicker.frame.maxY + 15
                } else {
                    return nameView.superview!.frame.maxY + 12
                }
            } else if let cell = tableView.dequeueReusableCell(withIdentifier: "Name") {
                (cell.viewWithTag(1) as? UITextView)?.text = course.name
                
                cell.updateConstraints()
                cell.layoutIfNeeded()
                
                if colorPickerOpen {
                    return cell.viewWithTag(3)!.frame.maxY + 15
                } else {
                    return cell.viewWithTag(1)!.superview!.frame.maxY + 12
                }
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Classes"
        } else if section == 2 {
            return "Exams"
        }
        
        return nil
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
            DataManager.shared.delete(course.classes[indexPath.row].record)
            course.classes.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let classController = segue.destination as? ClassTableViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if selectedIndexPath.section == 1 && selectedIndexPath.row < course.classes.count {
                    classController.classToDisplay = course.classes[selectedIndexPath.row]
                }
            }
        } else if let examController = segue.destination as? ExamTableViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if selectedIndexPath.section == 2 && selectedIndexPath.row < course.exams.count {
                    examController.exam = course.exams[selectedIndexPath.row]
                }
            }
        } else if let navigationController = segue.destination as? BetterNavigationController {
            if let newClassController = navigationController.topViewController as? NewClassTableViewController {
                newClassController.correspondingCourse = course
                navigationController.barColor = course.color
            } else if let newExamController = navigationController.topViewController as? NewExamTableViewController {
                newExamController.correspondingCourse = course
                navigationController.barColor = course.color
            }
        }
    }

}
