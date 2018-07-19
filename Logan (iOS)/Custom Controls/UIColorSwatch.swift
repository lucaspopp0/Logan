//
//  UIColorSwatch.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@IBDesignable class UIColorSwatch: UIControl {
    
    @IBInspectable var colorValue: UIColor = UIColor.black {
        didSet {
            shapeLayer.fillColor = colorValue.cgColor
        }
    }
    
    private let borderLayer = CAShapeLayer()
    private let shapeLayer = CAShapeLayer()
    
    private func unifiedInit() {
        layer.addSublayer(shapeLayer)
        layer.addSublayer(borderLayer)
        
        layer.masksToBounds = true
        clipsToBounds = true
        
        backgroundColor = UIColor.clear
        
        borderLayer.strokeColor = UIColor.black.withAlphaComponent(0.2).cgColor
        borderLayer.lineWidth = 1
        borderLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.fillColor = colorValue.cgColor
        
        organize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    private func organize() {
        borderLayer.path = CGPath(ellipseIn: bounds.insetBy(dx: 0.5, dy: 0.5), transform: nil)
        shapeLayer.path = CGPath(ellipseIn: bounds, transform: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        organize()
    }

}
