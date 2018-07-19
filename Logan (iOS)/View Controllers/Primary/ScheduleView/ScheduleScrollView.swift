//
//  ScheduleScrollView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleScrollView: UIScrollView {
    
    let scheduleView: ScheduleView = ScheduleView(frame: CGRect.zero)
    
    private func unifiedInit() {
        scheduleView.frame.size.width = bounds.size.width
        addSubview(scheduleView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    func reloadData() {
        scheduleView.reloadData()
        scheduleView.sizeToFit()
        contentSize = scheduleView.frame.size
    }
    
}
