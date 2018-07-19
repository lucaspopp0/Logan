//
//  PriorityIndicator.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/3/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@IBDesignable class PriorityIndicator: UIView {
    
    private static let dotSize: CGSize = CGSize(width: 3, height: 3)
    private static let dotPadding: CGFloat = 2
    
    var priority: Priority = Priority.normal {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            let numberOfDots: CGFloat = CGFloat(priority.rawValue)
            let numberOfSpaces: CGFloat = max(0, numberOfDots - 1)
            
            return CGSize(width: PriorityIndicator.dotSize.height, height: (numberOfDots * PriorityIndicator.dotSize.width) + (numberOfSpaces * PriorityIndicator.dotPadding))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        priority.textColor.setFill()
        
        for i in 0 ..< priority.rawValue {
            let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0, y: CGFloat(i) * (PriorityIndicator.dotSize.width + PriorityIndicator.dotPadding)), size: PriorityIndicator.dotSize))
            path.fill()
        }
    }
    
}
