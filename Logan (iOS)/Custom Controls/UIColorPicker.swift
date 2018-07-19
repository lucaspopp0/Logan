//
//  UIColorPicker.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class UIColorPicker: UIControl {
    
    var colorValue: UIColor = UIColor.black
    
    private static let swatchSpacing: CGFloat = 12
    
    private var swatches: [[UIColorSwatch]] = []
    
    override var intrinsicContentSize: CGSize {
        get {
            let swatchSize = (frame.size.width - (6 * UIColorPicker.swatchSpacing)) / 7
            
            return CGSize(width: frame.size.width, height: (2 * swatchSize) + (1 * UIColorPicker.swatchSpacing))
        }
    }
    
    private func unifiedInit() {
        let colors = [UIColor.red500, UIColor.pink500, UIColor.purple500, UIColor.indigo500, UIColor.blue500, UIColor.cyan500, UIColor.green500, UIColor.lime500, UIColor.yellow500, UIColor.orange500, UIColor.deepOrange500, UIColor.red900, UIColor.brown500]
        
        var row: [UIColorSwatch] = []
        
        for color in colors {
            let newSwatch = UIColorSwatch()
            newSwatch.colorValue = color
            row.append(newSwatch)
            
            if row.count == 7 {
                swatches.append(row)
                row = []
            }
        }
        
        if row.count > 0 {
            swatches.append(row)
        }
        
        for row in swatches {
            for swatch in row {
                swatch.addTarget(self, action: #selector(self.swatchPressed(_:)), for: UIControlEvents.touchUpInside)
                addSubview(swatch)
            }
        }
        
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
        let swatchSize = (frame.size.width - (6 * UIColorPicker.swatchSpacing)) / 7
        
        for (r, row) in swatches.enumerated() {
            for (c, swatch) in row.enumerated() {
                swatch.frame = CGRect(x: (swatchSize + UIColorPicker.swatchSpacing) * CGFloat(c), y: (swatchSize + UIColorPicker.swatchSpacing) * CGFloat(r), width: swatchSize, height: swatchSize)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        organize()
    }
    
    @objc private func swatchPressed(_ swatch: UIColorSwatch) {
        colorValue = swatch.colorValue
        sendActions(for: UIControlEvents.valueChanged)
    }

}
