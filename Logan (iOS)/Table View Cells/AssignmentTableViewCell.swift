//
//  AssignmentTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/8/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {

    var assignment: Assignment? {
        didSet {
            configureCell()
        }
    }
    
    @IBInspectable var shortenCourseText: Bool = false
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel?
    @IBOutlet weak var dueDateLabel: UILabel?
    
    func configureCell() {
        let title = assignment?.title ?? ""
        
        titleLabel.text = (title.isEmpty ? "Untitled Assignment" : title)
        
        if let courseLabel = courseLabel {
            if let course = assignment?.course {
                courseLabel.isHidden = false
                courseLabel.text = shortenCourseText ? course.shorterName : course.longerName
                courseLabel.textColor = course.color
            } else {
                courseLabel.isHidden = true
            }
        }
        
        if dueDateLabel != nil {
            var deadline: String = ""
            
            if assignment != nil {
                switch assignment!.dueDate {
                    
                case .asap:
                    deadline = "Due ASAP"
                    break
                    
                case .eventually:
                    deadline = "Due eventually"
                    break
                    
                case .specificDeadline(let specificDeadline):
                    if let dayDate = specificDeadline.day.dateValue {
                        let today = Date()
                        let days = Date.daysBetween(today, and: dayDate)
                        
                        if specificDeadline.day == CalendarDay(date: today) {
                            deadline = "Due today"
                        } else if days < 0 {
                            deadline = "Overdue"
                        } else if days == 1 {
                            deadline = "Due tomorrow"
                        } else if today.weekOfYear == dayDate.weekOfYear {
                            deadline = "Due \(DayOfWeek.forDate(dayDate).longName())"
                        } else {
                            let formatter = BetterDateFormatter()
                            
                            if today.year != dayDate.year {
                                formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                            } else {
                                formatter.dateFormat = "EEEE, MMMM dnn"
                            }
                            
                            deadline = "Due \(formatter.string(from: dayDate))"
                        }
                    } else {
                        deadline = ""
                    }
                    break
                    
                default:
                    break
                    
                }
            }
            
            if deadline.isEmpty {
                dueDateLabel!.isHidden = true
            } else {
                dueDateLabel!.isHidden = false
                dueDateLabel!.text = deadline
            }
        }
    }

}
