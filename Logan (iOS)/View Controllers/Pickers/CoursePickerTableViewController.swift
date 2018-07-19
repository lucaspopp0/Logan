//
//  CoursePickerTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/8/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@objc protocol CoursePickerDelegate {
    
    func selectedCourse(_ course: Course?, in picker: CoursePickerTableViewController)
    
}

class CoursePickerTableViewController: UITableViewController {
    
    var course: Course?
    var delegate: (AnyObject & CoursePickerDelegate)?

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataManager.shared.semesters.count + 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section > 0 {
            let semester = DataManager.shared.semesters[section - 1]
            
            if semester.isEqual(DataManager.shared.currentSemester) {
                return "\(semester.name) - Current"
            } else {
                return semester.name
            }
        }
        
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return DataManager.shared.semesters[section - 1].courses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "None"
            
            if course == nil {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "Course", for: indexPath) as? CourseTableViewCell {
            cell.course = DataManager.shared.semesters[indexPath.section - 1].courses[indexPath.row]
            cell.configureCell()
            
            if course?.isEqual(cell.course) ?? false {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? CourseTableViewCell {
            course = cell.course
        } else {
            course = nil
        }
        
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                if section == 0, let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                    if course == nil {
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.none
                    }
                } else if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? CourseTableViewCell {
                    if course?.isEqual(cell.course) ?? false {
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.none
                    }
                }
            }
        }
        
        delegate?.selectedCourse(course, in: self)
    }

}
