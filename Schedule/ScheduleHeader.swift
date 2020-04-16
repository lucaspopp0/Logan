//
//  ScheduleHeader.swift
//  Schedule
//
//  Created by Lucas Popp on 3/15/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleHeader: UIView {
    
    private let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffectStyle.prominent)))
    private let label = UILabel()
    
    var title: String = "" {
        didSet {
            label.text = title.uppercased()
        }
    }
    
    private func unifiedInit() {
        backgroundColor = UIColor(white: 1, alpha: 0.27)
        
        addSubview(vibrancyView)
        vibrancyView.frame = bounds
        
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold)
        label.textColor = UIColor.white
        vibrancyView.contentView.addSubview(label)
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
        
        vibrancyView.frame = bounds
        label.frame.origin.x = 12
        label.frame.origin.y = (frame.size.height - label.frame.size.height) / 2
    }
    
    override func sizeToFit() {
        label.sizeToFit()
        label.frame.origin.y = 4
        frame.size.height = label.frame.size.height + 8
        vibrancyView.frame = bounds
    }
    
}
