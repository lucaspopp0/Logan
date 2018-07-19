//
//  TaskView.swift
//  Tasks
//
//  Created by Lucas Popp on 3/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskView: UIView {
    
    var task: Task? {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var shortenCommitmentText: Bool = false
    
    let priorityIndicator: PriorityIndicator = PriorityIndicator()
    let checkbox: UICheckbox = WidgetCheckbox()
    let titleLabel: UILabel = UILabel()
    let sourceLabel: UILabel = UILabel()
    
    private func unifiedInit() {
        addSubview(priorityIndicator)
        addSubview(checkbox)
        addSubview(titleLabel)
        addSubview(sourceLabel)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
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
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        checkbox.addTarget(self, action: #selector(self.checkboxToggled), for: UIControlEvents.touchUpInside)
        
        checkbox.priority = task.priority
        checkbox.isOn = task.completed
        
        priorityIndicator.priority = task.priority
        
        titleLabel.text = (task.title.isEmpty ? "Untitled" : task.title)
        
        if let commitment = task.relatedAssignment?.commitment ?? task.commitment {
            checkbox.tintColor = commitment.color
        } else {
            checkbox.tintColor = UICheckbox.defaultBorderColor
        }
        
        let commitment = task.relatedAssignment?.commitment ?? task.commitment ?? nil
        let commitmentName = (shortenCommitmentText ? commitment?.shorterName : commitment?.longerName) ?? ""
        let assignmentName = task.relatedAssignment?.title ?? ""
        
        if commitmentName.isEmpty && assignmentName.isEmpty {
            sourceLabel.isHidden = true
        } else {
            sourceLabel.isHidden = false
            
            if !commitmentName.isEmpty && !assignmentName.isEmpty {
                let attrStr = NSMutableAttributedString()
                attrStr.append(NSAttributedString(string: commitmentName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold),
                                                                                       NSAttributedStringKey.foregroundColor : commitment!.color]))
                attrStr.append(NSAttributedString(string: "\u{2009}/\u{2009}\(assignmentName)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
                                                                                                             NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)]))
                
                sourceLabel.attributedText = attrStr
            } else if !commitmentName.isEmpty && assignmentName.isEmpty {
                sourceLabel.attributedText = NSAttributedString(string: commitmentName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold),
                                                                                                      NSAttributedStringKey.foregroundColor : commitment!.color])
            } else if commitmentName.isEmpty && !assignmentName.isEmpty {
                sourceLabel.attributedText = NSAttributedString(string: assignmentName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
                                                                                                      NSAttributedStringKey.foregroundColor : UIColor(white: 0, alpha: 0.5)])
            }
        }
    }
    
    @objc fileprivate func checkboxToggled() {
        task?.completed = checkbox.isOn
        
        configure()
        
        if task != nil {
            DataManager.shared.update(task!.record)
        }
    }
    
    override func sizeToFit() {
        checkbox.frame.origin.x = 15
        checkbox.frame.size.width = 24
        checkbox.frame.size.height = 24
        
        titleLabel.frame.origin.x = checkbox.frame.maxX + 12
        titleLabel.frame.size = titleLabel.sizeThatFits(CGSize(width: frame.size.width - checkbox.frame.maxX - 12 - 15, height: CGFloat.greatestFiniteMagnitude))
        
        sourceLabel.frame.origin.x = checkbox.frame.maxX + 12
        sourceLabel.frame.size = sourceLabel.sizeThatFits(CGSize(width: frame.size.width - checkbox.frame.maxX - 12 - 15, height: CGFloat.greatestFiniteMagnitude))
        
        let textHeight = titleLabel.frame.size.height + (sourceLabel.isHidden ? 0 : sourceLabel.frame.size.height + 2)
        
        let totalHeight = max(textHeight, checkbox.frame.size.height) + (2 * 15)
        
        frame.size.height = totalHeight
        
        checkbox.frame.origin.y = (totalHeight - checkbox.frame.size.height) / 2
        
        sourceLabel.frame.origin.y = ((totalHeight - textHeight) / 2)
        titleLabel.frame.origin.y = ((totalHeight + textHeight) / 2) - titleLabel.frame.size.height
    }
    
}

