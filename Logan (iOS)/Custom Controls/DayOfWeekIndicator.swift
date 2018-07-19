//
//  DayOfWeekIndicator.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@IBDesignable class DayOfWeekIndicator: UIView {
    
    private let labels: [UILabel] = [UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel()]
    
    @IBInspectable var labelSpacing: CGFloat = 6 {
        didSet {
            organize()
        }
    }
    
    var daysOfWeek: [DayOfWeek] = [] {
        didSet {
            for i in 0 ..< labels.count {
                if let day = DayOfWeek(rawValue: i), daysOfWeek.contains(day) {
                    labels[i].textColor = tintColor
                } else {
                    labels[i].textColor = UIColor.black.withAlphaComponent(0.5)
                }
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var size: CGSize = CGSize.zero
            
            for i in 0 ..< labels.count {
                size.height = max(size.height, labels[i].intrinsicContentSize.height)
                
                size.width += labels[i].intrinsicContentSize.width + (i > 0 ? labelSpacing : 0)
            }
            
            return size
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        unifiedInit()
        invalidateIntrinsicContentSize()
    }
    
    private func unifiedInit() {
        for (label, str) in zip(labels, ["S", "M", "T", "W", "T", "F", "S"]) {
            label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
            label.text = str
            addSubview(label)
        }
        
        for i in 0 ..< labels.count {
            if let day = DayOfWeek(rawValue: i), daysOfWeek.contains(day) {
                labels[i].textColor = tintColor
            } else {
                labels[i].textColor = UIColor.black.withAlphaComponent(0.5)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        organize()
    }
    
    private func organize() {
        var x: CGFloat = 0
        
        for label in labels {
            label.sizeToFit()
            label.frame.origin.x = x
            label.frame.origin.y = 0
            x += label.frame.size.width + labelSpacing
        }
    }
    
}
