//
//  TaskView.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 9/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskView: UIView {
    
    var task: Task? {
        didSet {
            configure()
        }
    }
    
    let priorityIndicator: PriorityIndicator = PriorityIndicator()
    let checkbox: UICheckbox = UICheckbox()
    let titleLabel: UILabel = UILabel()
    let dueDateLabel: UILabel = UILabel()
    let descriptionLabel: UILabel = UILabel()
    
    private func unifiedInit() {
        addSubview(priorityIndicator)
        addSubview(checkbox)
        addSubview(titleLabel)
        addSubview(dueDateLabel)
        addSubview(descriptionLabel)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        dueDateLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        
        descriptionLabel.textColor = UIColor(white: 0.5, alpha: 1)
        
        titleLabel.numberOfLines = 9
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        arrangeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    func configure() {
        guard let task = task else { return }
        
        checkbox.priority = task.priority
        checkbox.isOn = task.completed
        
        priorityIndicator.priority = task.priority
        
        titleLabel.text = task.title
        
        if task.userDescription == nil {
            descriptionLabel.isHidden = true
        } else {
            descriptionLabel.isHidden = false
            descriptionLabel.text = task.userDescription
        }
        
        checkbox.tintColor = task.associatedCourse?.color ?? UICheckbox.defaultBorderColor
        
        if checkbox.isOn {
            dueDateLabel.isHidden = true
        } else {
            dueDateLabel.textColor = UIColor(white: 0.5, alpha: 1)
            
            switch task.dueDate {
                
            case .specificDay(let day):
                let now = Date()
                if let specificDate = day.dateValue {
                    dueDateLabel.isHidden = false
                    
                    if CalendarDay(date: now) > day {
                        dueDateLabel.textColor = UIColor(red: 0.9569, green: 0.2627, blue: 0.2118, alpha: 1)
                        
                        let numberOfDaysOverdue = -Date.daysBetween(now, and: specificDate)
                        let weekCount = Int(floor(Double(numberOfDaysOverdue) / 7))
                        let dayCount = numberOfDaysOverdue % 7
                        
                        if numberOfDaysOverdue == 1 {
                            dueDateLabel.text = "Due yesterday"
                        } else if specificDate.weekOfYear == now.weekOfYear && specificDate.year == now.year {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEEE"
                            dueDateLabel.text = "Due \(formatter.string(from: specificDate))"
                        } else {
                            let oneWeekAgo = now.addingTimeInterval(-7 * 24 * 60 * 60)
                            
                            if specificDate.weekOfYear == oneWeekAgo.weekOfYear && specificDate.year == oneWeekAgo.year {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "EEEE"
                                dueDateLabel.text = "Due last \(formatter.string(from: specificDate))"
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
                                    dueDateLabel.text = "Due \(dayString) ago"
                                } else if !weekString.isEmpty && dayString.isEmpty {
                                    dueDateLabel.text = "Due \(weekString) ago"
                                } else if !weekString.isEmpty && !dayString.isEmpty {
                                    dueDateLabel.text = "Due \(weekString) and \(dayString) ago"
                                } else {
                                    dueDateLabel.text = "Overdue"
                                }
                            }
                        }
                    } else {
                        let today = Date()
                        let days = Date.daysBetween(today, and: specificDate)
                        
                        if day == CalendarDay(date: today) {
                            dueDateLabel.text = "Due today"
                        } else if days == 1 {
                            dueDateLabel.text = "Due tomorrow"
                        } else if today.weekOfYear == specificDate.weekOfYear {
                            dueDateLabel.text = "Due \(DayOfWeek.forDate(specificDate).longName())"
                        } else {
                            let formatter = BetterDateFormatter()
                            
                            if today.year != specificDate.year {
                                formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                            } else {
                                formatter.dateFormat = "EEEE, MMMM dnn"
                            }
                            
                            dueDateLabel.text = "Due \(formatter.string(from: specificDate))"
                        }
                    }
                } else {
                    dueDateLabel.isHidden = true
                }
                
                break
                
            default:
                dueDateLabel.isHidden = true
                break
                
            }
        }
    }
    
    private func arrangeSubviews() {
        checkbox.frame.size.width = 24
        checkbox.frame.size.height = 24
        checkbox.frame.origin.x = 15
        
        titleLabel.frame.origin.x = checkbox.frame.maxX + 12
        titleLabel.frame.size = titleLabel.sizeThatFits(CGSize(width: frame.size.width - titleLabel.frame.minX - 12, height: CGFloat.greatestFiniteMagnitude))
        
        dueDateLabel.frame.origin.x = checkbox.frame.maxX + 12
        dueDateLabel.frame.size = dueDateLabel.sizeThatFits(CGSize(width: frame.size.width - dueDateLabel.frame.minX - 12, height: CGFloat.greatestFiniteMagnitude))
        
        descriptionLabel.frame.origin.x = checkbox.frame.maxX + 12
        descriptionLabel.frame.size = descriptionLabel.sizeThatFits(CGSize(width: frame.size.width - descriptionLabel.frame.minX - 12, height: CGFloat.greatestFiniteMagnitude))
        
        var labelsHeight: CGFloat = 0
        let labels = [titleLabel, dueDateLabel, descriptionLabel]
        
        for (i, label) in labels.enumerated() {
            if !label.isHidden {
                labelsHeight += label.frame.size.height
                
                if i < labels.count - 1 {
                    labelsHeight += 2
                }
            }
        }
        
        let padding: CGFloat = 12
        let viewHeight = (2 * padding) + max(checkbox.frame.size.height, labelsHeight)
        
        var currentHeight: CGFloat = 0
        
        for label in labels {
            if !label.isHidden {
                label.frame.origin.y = ((viewHeight - labelsHeight) / 2) + currentHeight
                currentHeight += label.frame.size.height + 2
            }
        }
        
        checkbox.frame.origin.y = (viewHeight - checkbox.frame.size.height) / 2
        frame.size.height = viewHeight
    }
    
    override func sizeToFit() {
        arrangeSubviews()
    }
    
}
