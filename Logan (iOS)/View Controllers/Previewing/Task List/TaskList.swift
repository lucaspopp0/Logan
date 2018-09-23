//
//  TaskList.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 9/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskList: UIView {
    
    var tasks: [Task] = [] {
        didSet {
            reloadData()
        }
    }
    
    var views: [UIView] = []
    
    func reloadData() {
        while views.count > 0 {
            views.removeFirst().removeFromSuperview()
        }
        
        for i in 0 ..< tasks.count {
            let taskView = TaskView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 60))
            taskView.task = tasks[i]
            taskView.configure()
            taskView.sizeToFit()
            views.append(taskView)
            addSubview(taskView)
            
            if i < tasks.count - 1 {
                let separator = TaskListSeparator()
                views.append(separator)
                addSubview(separator)
            }
        }
    }
    
    override func sizeToFit() {
        arrangeViews()
    }
    
    func arrangeViews() {
        var totalHeight: CGFloat = 0
        
        for view in views {
            view.frame.origin.x = 0
            view.frame.size.width = frame.size.width
            view.sizeToFit()
            view.frame.origin.y = totalHeight
            totalHeight += view.frame.size.height
        }
        
        frame.size.height = totalHeight
    }
    
}

