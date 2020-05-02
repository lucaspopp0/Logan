//
//  TaskPreviewViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 4/4/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskPreviewViewController: UIViewController {
    
    var task: Task! {
        didSet {
            if isViewLoaded {
                configure()
            }
        }
    }
    
    @IBOutlet weak var courseLabel: UILabel!
    
    @IBOutlet weak var checkbox: UICheckbox!
    @IBOutlet weak var titleView: BetterTextView!
    @IBOutlet weak var descriptionView: BetterTextView!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    override var previewActionItems: [UIPreviewActionItem] {
        get {
            let completionAction = UIPreviewAction(title: "Mark as \(task.completed ? "in" : "")complete", style: UIPreviewActionStyle.default) { (action, controller) in
                self.task.completed = !self.task.completed
            }
            
            return [completionAction]
        }
    }
    
    func configure() {
        checkbox.isOn = task.completed
        checkbox.priority = task.priority
        checkbox.tintColor = task.associatedCourse?.color ?? UICheckbox.defaultBorderColor
        
        titleView.text = task.title
        descriptionView.text = task.userDescription
        
        descriptionView.isHidden = descriptionView.text.isEmpty
        
        var attributedDueDate: NSAttributedString!
        var attributedPriority: NSAttributedString!
        
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        if task.associatedCourse == nil && task.relatedAssignment == nil {
            courseLabel.isHidden = true
        } else {
            courseLabel.isHidden = false
            var courseString: NSAttributedString?
            var assignmentString: NSAttributedString?
            
            if let course = task.associatedCourse {
                courseString = NSAttributedString(string: course.name, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
                                                                                    NSAttributedStringKey.foregroundColor: course.color])
            }
            
            if let assignment = task.relatedAssignment {
                assignmentString = NSAttributedString(string: assignment.title, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
                                                                                             NSAttributedStringKey.foregroundColor: UIColor(white: 0, alpha: 0.5)])
            }
            
            let str = NSMutableAttributedString()
            
            if let courseString = courseString {
                str.append(courseString)
            }
            
            if courseString != nil && assignmentString != nil {
                str.append(NSAttributedString(string: "\u{2009}/\u{2009}", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
                                                                                        NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)]))
            }
            
            if let assignmentString = assignmentString {
                str.append(assignmentString)
            }
            
            courseLabel.attributedText = str
        }
        
        switch task.dueDate {
        case .eventually:
            attributedDueDate = NSAttributedString(string: "Eventually", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                      NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
            break
            
        case .asap:
            attributedDueDate = NSAttributedString(string: "ASAP", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
            break
            
        case .specificDay(let day):
            if day < CalendarDay.today {
                attributedDueDate = NSAttributedString(string: BetterDateFormatter.autoFormatDate(day.dateValue!), attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                                                                NSAttributedStringKey.foregroundColor : UIColor(red: 0.9569, green: 0.2627, blue: 0.2118, alpha: 1)])
            } else {
                attributedDueDate = NSAttributedString(string: BetterDateFormatter.autoFormatDate(day.dateValue!), attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                                                                NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
            }
            
            break
            
        default:
            break
        }
        
        var priorityString = ""
        switch task.priority {
        case .reallyLow:
            priorityString = "Really low"
            break
        case .low:
            priorityString = "Low"
            break
        case .normal:
            priorityString = "Normal"
            break
        case .high:
            priorityString = "High"
            break
        case .reallyHigh:
            priorityString = "Really high"
            break
        }
        
        priorityLabel.attributedText = NSAttributedString(string: priorityString, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                               NSAttributedStringKey.foregroundColor : task.priority.textColor])
        
        let mutableDueDate = NSMutableAttributedString(string: "Do: ", attributes: [NSAttributedStringKey.font : bodyFont,
                                                                                    NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
        mutableDueDate.append(attributedDueDate)
        
        let mutablePriority = NSMutableAttributedString(string: "Priority: ", attributes: [NSAttributedStringKey.font : bodyFont,
                                                                                           NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
        mutablePriority.append(attributedPriority)
        
        dueDateLabel.attributedText = mutableDueDate
        priorityLabel.attributedText = mutablePriority
    }
    
}
