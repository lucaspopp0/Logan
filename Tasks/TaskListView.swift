//
//  TaskListView.swift
//  Tasks
//
//  Created by Lucas Popp on 3/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import NotificationCenter

class TaskListView: UIView {
    
    var tasks: [Task] = []
    var views: [UIView] = []
    var extraTasks: Int = 0
    
    var extensionContext: NSExtensionContext?
    
    lazy var extraHeight: CGFloat = {
        let extraView = ShowMoreView()
        extraView.frame.size.width = UIScreen.main.bounds.size.width
        extraView.extraCount = 8
        extraView.sizeToFit()
        
        return extraView.frame.size.height
    }()
    
    func reloadData() {
        while views.count > 0 {
            views.removeFirst().removeFromSuperview()
        }
        
        for i in 0 ..< tasks.count - extraTasks {
            let taskView = TaskView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 60))
            taskView.task = tasks[i]
            taskView.configure()
            taskView.sizeToFit()
            views.append(taskView)
            addSubview(taskView)
            
            if i < tasks.count - extraTasks - 1 {
                let separator = TaskListSeparator()
                views.append(separator)
                addSubview(separator)
            }
        }
        
        if extraTasks > 0 {
            let extraView: ShowMoreView = ShowMoreView()
            extraView.extensionContext = extensionContext
            extraView.extraCount = extraTasks
            extraView.frame.size.width = frame.size.width
            extraView.sizeToFit()
            
            views.append(extraView)
            addSubview(extraView)
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
