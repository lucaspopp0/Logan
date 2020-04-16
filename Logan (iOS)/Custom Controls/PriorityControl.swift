//
//  PriorityControl.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/8/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class PriorityControl: UISegmentedControl {
    
    var priority: Priority {
        get {
            return Priority(rawValue: 3 - selectedSegmentIndex)!
        }
        
        set {
            selectedSegmentIndex = 3 - newValue.rawValue
            
            if #available(iOS 13.0, *) {
                selectedSegmentTintColor = newValue.color
            } else {
                tintColor = newValue.color
            }
        }
    }

    private func unifiedInit() {
        removeAllSegments()
        
        for title in ["Low", "Normal", "High", "Really high"] {
            insertSegment(withTitle: title, at: 0, animated: false)
        }
        
        if selectedSegmentIndex == -1 {
            selectedSegmentIndex = 2
        }
        
        addTarget(self, action: #selector(self.updateTint), for: UIControlEvents.valueChanged)
        
        updateTint()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    @objc private func updateTint() {
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor = priority.color
        } else {
            tintColor = priority.color
        }
    }
    
}
