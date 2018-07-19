//
//  TaskListSeparator.swift
//  Tasks
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskListSeparator: UIView {
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        addSubview(effectView)
        effectView.frame = bounds
        effectView.alpha = 0.3
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        addSubview(effectView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        effectView.frame = bounds
    }
    
    override func sizeToFit() {
        frame.size.height = 1 / UIScreen.main.scale
        effectView.frame = bounds
    }
    
}
