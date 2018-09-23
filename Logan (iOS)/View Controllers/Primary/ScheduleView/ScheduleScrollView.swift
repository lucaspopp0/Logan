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
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ScheduleScrollView.handlePinch(_:)))
        addGestureRecognizer(pinch)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    func scrollToNow() {
        if scheduleView.day != CalendarDay.today {
            scheduleView.day = CalendarDay.today
        }
        
        var timeFrame = scheduleView.timeIndicator.frame
        timeFrame.size.height = 40
        timeFrame.origin.y -= 8
        
        scrollRectToVisible(timeFrame, animated: true)
    }
    
    func reloadData() {
        scheduleView.reloadData()
        scheduleView.sizeToFit()
        contentSize = scheduleView.frame.size
    }
    
    @objc func handlePinch(_ gesture: UIGestureRecognizer) {
        if let pinch = gesture as? UIPinchGestureRecognizer {
            let pinchCenter = pinch.location(in: self)
            let pinchOffset = pinchCenter.y - contentOffset.y
            let oldHeight = contentSize.height
            
            scheduleView.hourHeight = scheduleView.hourHeight * pinch.scale
            
            contentSize = scheduleView.intrinsicContentSize
            
            let computedScale = contentSize.height / oldHeight
            
            contentOffset.y = min(max(0, (pinchCenter.y * computedScale) - pinchOffset), contentSize.height - frame.size.height)
            pinch.scale = 1
        }
    }
    
}
