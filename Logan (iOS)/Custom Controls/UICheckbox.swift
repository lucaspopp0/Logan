//
//  UICheckbox.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@IBDesignable class UICheckbox: UIControl {
    
    private class IntangibleLabel: UILabel {
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            return nil
        }
        
    }
    
    // PROPERTIES
    
    static let defaultBorderColor: UIColor = UIColor(white: 0, alpha: 0.3)
    
    @IBInspectable var isOn: Bool = false {
        didSet {
            centerCircle.isHidden = !isOn
            
            if isOn {
                shapeLayer.strokeColor = tintColor.cgColor
                textLabel.textColor = UIColor.white
            } else {
                shapeLayer.strokeColor = tintColor.cgColor
                textLabel.textColor = tintColor
            }
        }
    }
    
    var priority: Priority = Priority.normal {
        didSet {
            switch priority {
                
            case .reallyHigh:
                shapeLayer.lineWidth = 1.75
                textLabel.text = "!!!"
                break
                
            case .high:
                shapeLayer.lineWidth = 1.25
                textLabel.text = "!!"
                break
                
            case .normal:
                shapeLayer.lineWidth = 1
                textLabel.text = "!"
                break
                
            case .low:
                shapeLayer.lineWidth = 1
                textLabel.text = ""
                break
            }
            
            layoutSubviews()
        }
    }
    
    internal let textLabel: UILabel = IntangibleLabel()
    internal let centerCircle: CAShapeLayer = CAShapeLayer()
    
    override var tintColor: UIColor! {
        didSet {
            centerCircle.fillColor = tintColor.cgColor
            shapeLayer.strokeColor = tintColor.cgColor
            textLabel.textColor = tintColor
        }
    }
    
    let shapeLayer: CAShapeLayer = CAShapeLayer()
    
    // METHODS
    
    override func prepareForInterfaceBuilder() {
        unifiedInit()
    }
    
    internal func unifiedInit() {
        backgroundColor = UIColor.clear
        
        tintColor = UICheckbox.defaultBorderColor
        
        layer.masksToBounds = false
        layer.insertSublayer(shapeLayer, below: nil)
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.strokeColor = tintColor.cgColor
        
        shapeLayer.addSublayer(centerCircle)
        centerCircle.fillColor = tintColor.cgColor
        centerCircle.isHidden = !isOn
        
        addSubview(textLabel)
        textLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        
        layoutIfNeeded()
        
        self.addTarget(self, action: #selector(self.toggle), for: UIControlEvents.touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    @objc fileprivate func toggle() {
        isOn = !isOn
    }
    
    private func organize() {
        shapeLayer.path = CGPath(ellipseIn: bounds.insetBy(dx: shapeLayer.lineWidth / 2, dy: shapeLayer.lineWidth / 2), transform: nil)
        
        let inset = pow(85 * shapeLayer.lineWidth, 1/4)
        
        centerCircle.path = CGPath(ellipseIn: bounds.insetBy(dx: inset, dy: inset), transform: nil)
        textLabel.sizeToFit()
        textLabel.frame.origin = CGPoint(x: (bounds.size.width - textLabel.bounds.size.width) / 2, y: (bounds.size.height - textLabel.bounds.size.height) / 2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        organize()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -8, dy: -8).contains(point)
    }
    
}

