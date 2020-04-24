//
//  TaskTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    var task: Task? {
        didSet {
            configureCell()
        }
    }
    
    @IBInspectable var shortenCourseText: Bool = false
    
    @IBOutlet weak var priorityIndicator: PriorityIndicator?
    @IBOutlet weak var checkbox: UICheckbox!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel?
    @IBOutlet weak var dueDateLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    func configureCell() {
        guard let task = task else { return }
        
        checkbox.addTarget(self, action: #selector(self.checkboxToggled), for: UIControlEvents.touchUpInside)
        
        checkbox.priority = task.priority
        checkbox.isOn = task.completed
        
        priorityIndicator?.priority = task.priority
        
        titleLabel.text = (task.title.isEmpty ? "Untitled" : task.title)
        
        if let taskDescription = task.userDescription, !taskDescription.isEmpty {
            descriptionLabel?.isHidden = false
            descriptionLabel?.text = task.userDescription
        } else {
            descriptionLabel?.isHidden = true
        }
        
        checkbox.tintColor = task.associatedCourse?.color ?? UICheckbox.defaultBorderColor
        
        if sourceLabel != nil {
            let courseName = (shortenCourseText ? task.associatedCourse?.shorterName : task.associatedCourse?.longerName) ?? ""
            let assignmentName = task.relatedAssignment?.title ?? ""
            
            if courseName.isEmpty && assignmentName.isEmpty {
                sourceLabel?.isHidden = true
            } else {
                sourceLabel?.isHidden = false
                
                if !courseName.isEmpty && !assignmentName.isEmpty {
                    let attrStr = NSMutableAttributedString()
                    attrStr.append(NSAttributedString(string: courseName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold),
                                                                                       NSAttributedStringKey.foregroundColor : task.associatedCourse!.color]))
                    attrStr.append(NSAttributedString(string: "\u{2009}/\u{2009}\(assignmentName)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
                                                                                                                 NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)]))
                    
                    sourceLabel?.attributedText = attrStr
                } else if !courseName.isEmpty && assignmentName.isEmpty {
                    sourceLabel?.attributedText = NSAttributedString(string: courseName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold),
                                                                                                      NSAttributedStringKey.foregroundColor : task.associatedCourse!.color])
                } else if courseName.isEmpty && !assignmentName.isEmpty {
                    sourceLabel?.attributedText = NSAttributedString(string: assignmentName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
                                                                                                          NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)])
                }
            }
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
        
        // Hide/show UIVisualEffectViews
        (dueDateLabel?.superview?.superview as? UIVisualEffectView)?.isHidden = dueDateLabel?.isHidden ?? true
    }
    
    @objc fileprivate func checkboxToggled() {
        task?.completed = checkbox.isOn
        
        configureCell()
        
        if task != nil {
            DataManager.shared.update(task!.record)
        }
    }
    
}
