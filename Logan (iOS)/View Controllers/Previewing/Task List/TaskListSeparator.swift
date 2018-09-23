//
//  TaskListSeparator.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 9/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskListSeparator: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.67, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(white: 0.67, alpha: 1)
    }
    
    override func sizeToFit() {
        frame.size.height = 1 / UIScreen.main.scale
    }
    
}
