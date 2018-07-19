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
    
    @IBOutlet weak var commitmentLabel: UILabel!
    
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
        checkbox.tintColor = (task.relatedAssignment?.commitment ?? task.commitment)?.color ?? UICheckbox.defaultBorderColor
        
        titleView.text = task.title
        descriptionView.text = task.userDescription
        
        descriptionView.isHidden = descriptionView.text.isEmpty
        
        var attributedDueDate: NSAttributedString!
        var attributedPriority: NSAttributedString!
        
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        let commitment = task.relatedAssignment?.commitment ?? task.commitment ?? nil
        let commitmentName = commitment?.longerName ?? ""
        let assignmentName = task.relatedAssignment?.title ?? ""
        
        if commitmentName.isEmpty && assignmentName.isEmpty {
            commitmentLabel.isHidden = true
        } else {
            commitmentLabel.isHidden = false
            
            if !commitmentName.isEmpty && !assignmentName.isEmpty {
                let attrStr = NSMutableAttributedString()
                attrStr.append(NSAttributedString(string: commitmentName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
                                                                                       NSAttributedStringKey.foregroundColor : commitment!.color]))
                attrStr.append(NSAttributedString(string: "\u{2009}/\u{2009}\(assignmentName)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
                                                                                                             NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)]))
                
                commitmentLabel.attributedText = attrStr
            } else if !commitmentName.isEmpty && assignmentName.isEmpty {
                commitmentLabel.attributedText = NSAttributedString(string: commitmentName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
                                                                                                         NSAttributedStringKey.foregroundColor : commitment!.color])
            } else if commitmentName.isEmpty && !assignmentName.isEmpty {
                commitmentLabel.attributedText = NSAttributedString(string: assignmentName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
                                                                                                         NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)])
            }
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
        
        switch task.priority {
        case .low:
            attributedPriority = NSAttributedString(string: "Low", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                NSAttributedStringKey.foregroundColor : task.priority.textColor])
            break
        case .normal:
            attributedPriority = NSAttributedString(string: "Normal", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                   NSAttributedStringKey.foregroundColor : task.priority.textColor])
            break
        case .high:
            attributedPriority = NSAttributedString(string: "High", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                 NSAttributedStringKey.foregroundColor : task.priority.textColor])
            break
        case .reallyHigh:
            attributedPriority = NSAttributedString(string: "Really high", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                        NSAttributedStringKey.foregroundColor : task.priority.textColor])
            break
        }
        
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
