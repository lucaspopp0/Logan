//
//  RoundedButton.swift
//  To Do
//
//  Created by Lucas Popp on 1/30/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 3 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        unifiedInit()
    }
    
    private func unifiedInit() {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
}

