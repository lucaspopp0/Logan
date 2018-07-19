//
//  CommitmentPickerTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

protocol CommitmentPickerDelegate {
    
    func selectedCommitment(_ commitment: Commitment?, in picker: CommitmentPickerTableViewController)
    
}

class CommitmentPickerTableViewController: UITableViewController {
    
    var commitment: Commitment?
    var delegate: (AnyObject & CommitmentPickerDelegate)?
    
    private var dataSections: [(title: String, commitments: [Commitment])] = []
    
    func updateData() {
        dataSections = [(title: "", commitments: [])]
        
        func addCommitment(_ commitment: Commitment, toSection title: String) {
            var found: Bool = false
            
            for i in 0 ..< dataSections.count {
                if dataSections[i].title == title {
                    dataSections[i].commitments.append(commitment)
                    found = true
                    break
                }
            }
            
            if !found {
                dataSections.append((title: title, commitments: [commitment]))
            }
        }
        
        if DataManager.shared.currentSemester != nil {
            for course in DataManager.shared.currentSemester!.courses {
                addCommitment(course, toSection: "\(DataManager.shared.currentSemester!.name) - Current")
            }
        }
        
        if DataManager.shared.extracurriculars.count > 0 {
            dataSections.append((title: "Extracurriculars", commitments: DataManager.shared.extracurriculars))
        }
        
        for semester in DataManager.shared.semesters {
            if !semester.isEqual(DataManager.shared.currentSemester) {
                for course in semester.courses {
                    addCommitment(course, toSection: semester.name)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return dataSections[section].title
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dataSections[section].commitments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "None"
            
            if commitment == nil {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            
            return cell
        } else {
            let commitment = dataSections[indexPath.section].commitments[indexPath.row]
            
            if let course = commitment as? Course, let cell = tableView.dequeueReusableCell(withIdentifier: "Course", for: indexPath) as? CourseTableViewCell {
                cell.course = course
                cell.configureCell()
                
                if course.isEqual(self.commitment) {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
                
                return cell
            } else if let extracurricular = commitment as? Extracurricular, let cell = tableView.dequeueReusableCell(withIdentifier: "Extracurricular", for: indexPath) as? ExtracurricularTableViewCell {
                cell.extracurricular = extracurricular
                cell.configureCell()
                
                if extracurricular.isEqual(self.commitment) {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            commitment = nil
        } else {
            commitment = dataSections[indexPath.section].commitments[indexPath.row]
        }
        
        for section in 0 ..< tableView.numberOfSections {
            for row in 0 ..< tableView.numberOfRows(inSection: section) {
                if section == 0, let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                    if commitment == nil {
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.none
                    }
                } else if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                    if indexPath.row == row && indexPath.section == section {
                        cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.none
                    }
                }
            }
        }
        
        delegate?.selectedCommitment(commitment, in: self)
    }
    
}
