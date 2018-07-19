//
//  AssignmentTaskTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class AssignmentTaskTableViewCell: UITableViewCell {
    
    var task: Task! {
        didSet {
            configureCell()
        }
    }
    @IBOutlet weak var checkbox: UICheckbox!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel?
    
    @IBOutlet weak var checkboxPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelsPaddingConstraint: NSLayoutConstraint!
    
    func configureCell() {
        checkbox.addTarget(self, action: #selector(self.checkboxToggled), for: UIControlEvents.touchUpInside)
        
        checkbox.priority = task.priority
        checkbox.isOn = task.completed
        
        if task.completed {
            checkboxPaddingConstraint.constant = 2
            labelsPaddingConstraint.constant = 4
        } else {
            checkboxPaddingConstraint.constant = 8
            labelsPaddingConstraint.constant = 4
        }
        
        titleLabel.text = (task.title.isEmpty ? "Untitled" : task.title)
        
        if let taskCommitment = task.relatedAssignment?.commitment {
            checkbox.tintColor = taskCommitment.color
        } else {
            checkbox.tintColor = UICheckbox.defaultBorderColor
        }
        
        if checkbox.isOn {
            dueDateLabel?.isHidden = true
        } else {
            if dueDateLabel != nil {
                switch task.dueDate {
                    
                case .specificDay(let day):
                    let now = Date()
                    if let specificDate = day.dateValue {
                        dueDateLabel?.isHidden = false
                        
                        if CalendarDay(date: now) > day {
                            dueDateLabel?.textColor = UIColor(red: 0.9569, green: 0.2627, blue: 0.2118, alpha: 1)
                            
                            let numberOfDaysOverdue = -Date.daysBetween(now, and: specificDate)
                            let weekCount = Int(floor(Double(numberOfDaysOverdue) / 7))
                            let dayCount = numberOfDaysOverdue % 7
                            
                            if numberOfDaysOverdue == 1 {
                                dueDateLabel?.text = "Due yesterday"
                            } else if specificDate.weekOfYear == now.weekOfYear && specificDate.year == now.year {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "EEEE"
                                dueDateLabel?.text = "Due \(formatter.string(from: specificDate))"
                            } else {
                                let oneWeekAgo = now.addingTimeInterval(-7 * 24 * 60 * 60)
                                
                                if specificDate.weekOfYear == oneWeekAgo.weekOfYear && specificDate.year == oneWeekAgo.year {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "EEEE"
                                    dueDateLabel?.text = "Due last \(formatter.string(from: specificDate))"
                                } else {
                                    var weekString = ""
                                    var dayString = ""
                                    
                                    if dayCount > 0 {
                                        if dayCount == 1 {
                                            dayString = "1 day"
                                        } else {
                                            dayString = "\(dayCount) days"
                                        }
                                    }
                                    
                                    if weekCount > 0 {
                                        if weekCount == 1 {
                                            weekString = "1 week"
                                        } else {
                                            weekString = "\(weekCount) weeks"
                                        }
                                    }
                                    
                                    if weekString.isEmpty && !dayString.isEmpty {
                                        dueDateLabel?.text = "Due \(dayString) ago"
                                    } else if !weekString.isEmpty && dayString.isEmpty {
                                        dueDateLabel?.text = "Due \(weekString) ago"
                                    } else if !weekString.isEmpty && !dayString.isEmpty {
                                        dueDateLabel?.text = "Due \(weekString) and \(dayString) ago"
                                    } else {
                                        dueDateLabel?.text = "Overdue"
                                    }
                                }
                            }
                        } else {
                            let today = Date()
                            let days = Date.daysBetween(today, and: specificDate)
                            
                            if day == CalendarDay(date: today) {
                                dueDateLabel?.text = "Due today"
                            } else if days == 1 {
                                dueDateLabel?.text = "Due tomorrow"
                            } else if today.weekOfYear == specificDate.weekOfYear {
                                dueDateLabel?.text = "Due \(DayOfWeek.forDate(specificDate).longName())"
                            } else {
                                let formatter = BetterDateFormatter()
                                
                                if today.year != specificDate.year {
                                    formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                                } else {
                                    formatter.dateFormat = "EEEE, MMMM dnn"
                                }
                                
                                dueDateLabel?.text = "Due \(formatter.string(from: specificDate))"
                            }
                        }
                    } else {
                        dueDateLabel?.isHidden = true
                    }
                    
                    break
                    
                default:
                    dueDateLabel?.isHidden = true
                    break
                    
                }
            }
        }
    }
    
    @objc fileprivate func checkboxToggled() {
        task?.completed = checkbox.isOn
        
        if let tableView = superview as? UITableView {
            tableView.beginUpdates()
            configureCell()
            tableView.endUpdates()
        }
        
        if task != nil {
            DataManager.shared.update(task!.record)
        }
    }
    
}
