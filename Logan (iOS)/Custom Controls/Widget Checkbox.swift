//
//  UICheckbox.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@IBDesignable class WidgetCheckbox: UICheckbox {
    
    override var isOn: Bool {
        didSet {
            centerCircle.isHidden = !isOn
            
            if isOn {
                shapeLayer.fillColor = nil
                shapeLayer.strokeColor = tintColor.cgColor
            } else {
                shapeLayer.fillColor = tintColor.cgColor
                shapeLayer.strokeColor = nil
            }
            
            textLabel.textColor = UIColor.white
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            centerCircle.fillColor = tintColor.cgColor
            
            if isOn {
                shapeLayer.fillColor = nil
                shapeLayer.strokeColor = tintColor.cgColor
            } else {
                shapeLayer.fillColor = tintColor.cgColor
                shapeLayer.strokeColor = nil
            }
            
            textLabel.textColor = UIColor.white
        }
    }
    
    override func unifiedInit() {
        super.unifiedInit()
        
        shapeLayer.fillColor = tintColor.cgColor
        textLabel.textColor = UIColor.white
    }
    
}
