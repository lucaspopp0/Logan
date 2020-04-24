//
//  AssignmentPreviewViewController.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 7/30/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class AssignmentPreviewViewController: UIViewController {
    
    var assignment: Assignment! {
        didSet {
            if isViewLoaded {
                configure()
            }
        }
    }
    
    var tasks: [Task] {
        get {
            return DataManager.shared.tasksFor(assignment)
        }
    }
    
    @IBOutlet weak var courseLabel: UILabel!
    
    @IBOutlet weak var titleView: BetterTextView!
    @IBOutlet weak var descriptionView: BetterTextView!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var tasksSeparator: UIView!
    @IBOutlet weak var separatorConstraint: NSLayoutConstraint!
    @IBOutlet weak var taskList: TaskList!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        taskList.sizeToFit()
        preferredContentSize.height = taskList.frame.maxY - 12
    }
    
    func configure() {
        titleView.text = assignment.title
        descriptionView.text = assignment.userDescription
        
        descriptionView.isHidden = descriptionView.text.isEmpty
        
        var attributedDueDate: NSAttributedString!
        
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        if let course = assignment.course {
            courseLabel.isHidden = false
            courseLabel.attributedText = NSAttributedString(string: course.longerName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
                                                                                                    NSAttributedStringKey.foregroundColor : course.color])
        } else {
            courseLabel.isHidden = true
        }
        
        switch assignment.dueDate {
        case .eventually:
            attributedDueDate = NSAttributedString(string: "Eventually", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                      NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
            break
            
        case .asap:
            attributedDueDate = NSAttributedString(string: "ASAP", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
            break
            
        case .specificDeadline(let deadline):
            if deadline.day < CalendarDay.today {
                attributedDueDate = NSAttributedString(string: BetterDateFormatter.autoFormatDate(deadline.day.dateValue!), attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                                                                         NSAttributedStringKey.foregroundColor : UIColor(red: 0.9569, green: 0.2627, blue: 0.2118, alpha: 1)])
            } else {
                attributedDueDate = NSAttributedString(string: BetterDateFormatter.autoFormatDate(deadline.day.dateValue!), attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: bodyFont.pointSize),
                                                                                                                                         NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
            }
            
            break
            
        default:
            break
        }
        
        let mutableDueDate = NSMutableAttributedString(string: "Due: ", attributes: [NSAttributedStringKey.font : bodyFont,
                                                                                     NSAttributedStringKey.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
        mutableDueDate.append(attributedDueDate)
        
        dueDateLabel.attributedText = mutableDueDate
        
        separatorConstraint.constant = 1 / UIScreen.main.scale
        
        taskList.tasks = tasks
        taskList.sizeToFit()
    }

}
