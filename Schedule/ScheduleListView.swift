//
//  ScheduleListView.swift
//  Schedule
//
//  Created by Lucas Popp on 3/15/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleListView: UIView {
    
    var sections: [(title: String, classes: [Class])] = []
    var views: [UIView] = []
    
    func reloadData() {
        while views.count > 0 {
            views.removeFirst().removeFromSuperview()
        }
        
        for i in 0 ..< sections.count {
            let headerView = ScheduleHeader(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 60))
            headerView.title = sections[i].title
            views.append(headerView)
            addSubview(headerView)
            
            for j in 0 ..< sections[i].classes.count {
                let scheduleView = ScheduleView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 60))
                scheduleView.classToDisplay = sections[i].classes[j]
                scheduleView.configure()
                views.append(scheduleView)
                addSubview(scheduleView)
                
                if j < sections[i].classes.count - 1 {
                    let separator = ScheduleListSeparator()
                    views.append(separator)
                    addSubview(separator)
                }
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
