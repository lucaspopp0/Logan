//
//  ScheduleView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleView: UIView {
    
    private static let hourHeight: CGFloat = 90
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: super.intrinsicContentSize.width, height: 24 * ScheduleView.hourHeight)
        }
    }
    
    let dayStart: ClockTime = ClockTime(hour: 0, minute: 0, ampm: ClockTime.AmPm.am)!
    
    var day: CalendarDay = CalendarDay(date: Date()) {
        didSet {
            reloadData()
        }
    }
    
    var eventViews: [EventView] = []
    let timeIndicator = UIView()
    var hourLabels: [UILabel] = []
    var hourLines: [UIView] = []
    
    private var timer: Timer!
    
    private var maxLabelWidth: CGFloat = 0
    
    private func unifiedInit() {
        timeIndicator.backgroundColor = UIColor.orange500
        addSubview(timeIndicator)
        
        startTimer()
        
        for hour in 0 ..< 24 {
            let formattedHour = (hour == 0) ? 12 : (hour <= 12 ? hour : hour - 12)
            let ampm = hour < 12 ? "A" : "P"
            
            let newLine = UIView()
            newLine.backgroundColor = UIColor(white: 0, alpha: 0.08)
            hourLines.append(newLine)
            addSubview(newLine)
            
            let newLabel = UILabel()
            newLabel.text = "\(formattedHour)\(ampm)"
            newLabel.textColor = UIColor(white: 0, alpha: 0.1)
            newLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            newLabel.sizeToFit()
            newLabel.frame.origin.x = 0
            hourLabels.append(newLabel)
            addSubview(newLabel)
            
            maxLabelWidth = max(maxLabelWidth, newLabel.frame.maxX)
        }
        
        for label in hourLabels {
            label.frame.size.width = maxLabelWidth
            label.textAlignment = NSTextAlignment.right
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.updateTime()
        })
    }
    
    private func stopTimer() {
        timer.invalidate()
        timer = nil
    }
    
    func updateTime() {
        timeIndicator.frame = CGRect(x: 0, y: (ScheduleView.hourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: ClockTime(date: Date())) / 60)), width: bounds.size.width, height: 1)
    }
    
    func reloadData() {
        timeIndicator.isHidden = (day != CalendarDay(date: Date()))
        
        while eventViews.count > 0 {
            eventViews.removeFirst().removeFromSuperview()
        }
        
        var classesToDisplay: [Class] = []
        var eventsToDisplay: [Event] = []
        
        let date = day.dateValue!
        let dayOfWeek = DayOfWeek.forDate(date)
        
        for semester in DataManager.shared.semesters {
            for course in semester.courses {
                for potentialClass in course.classes {
                    if potentialClass.startDate <= day && potentialClass.endDate >= day {
                        if potentialClass.daysOfWeek.contains(dayOfWeek) {
                            if potentialClass.weeklyRepeat > 1 {
                                let weeksPassed = Calendar.autoupdatingCurrent.dateComponents([Calendar.Component.weekOfYear], from: potentialClass.startDate.dateValue!, to: date).weekOfYear!
                                if weeksPassed % potentialClass.weeklyRepeat == 0 {
                                    classesToDisplay.append(potentialClass)
                                }
                            } else {
                                classesToDisplay.append(potentialClass)
                            }
                        }
                    }
                }
            }
        }
        
        for extracurricular in DataManager.shared.extracurriculars {
            for event in extracurricular.events {
                if let repeatingEvent = event as? RepeatingEvent {
                    if repeatingEvent.startDate <= day && repeatingEvent.endDate >= day {
                        if repeatingEvent.daysOfWeek.contains(dayOfWeek) {
                            if repeatingEvent.weeklyRepeat > 1 {
                                let weeksPassed = Calendar.autoupdatingCurrent.dateComponents([Calendar.Component.weekOfYear], from: repeatingEvent.startDate.dateValue!, to: date).weekOfYear!
                                if weeksPassed % repeatingEvent.weeklyRepeat == 0 {
                                    eventsToDisplay.append(repeatingEvent)
                                }
                            } else {
                                eventsToDisplay.append(repeatingEvent)
                            }
                        }
                    }
                } else if let singleEvent = event as? SingleEvent {
                    if singleEvent.date == day {
                        eventsToDisplay.append(singleEvent)
                    }
                }
            }
        }
        
        for ctd in classesToDisplay {
            let classView = ClassView()
            classView.classToDisplay = ctd
            classView.frame.size.width = frame.size.width - 12
            classView.frame.origin.x = 6
            classView.frame.size.height = (ScheduleView.hourHeight / 60) * (CGFloat(ClockTime.secondsBetween(ctd.startTime, and: ctd.endTime)) / 60)
            classView.frame.origin.y = (ScheduleView.hourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: ctd.startTime) ) / 60)
            classView.dayOfWeek = dayOfWeek
            
            eventViews.append(classView)
            addSubview(classView)
        }
        
        for event in eventsToDisplay {
            let eventView = EventView()
            eventView.event = event
            eventView.frame.size.width = frame.size.width - 12
            eventView.frame.origin.x = 6
            eventView.frame.size.height = (ScheduleView.hourHeight / 60) * (CGFloat(ClockTime.secondsBetween(event.startTime, and: event.endTime)) / 60)
            eventView.frame.origin.y = (ScheduleView.hourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: event.startTime) ) / 60)
            eventView.dayOfWeek = dayOfWeek
            
            eventViews.append(eventView)
            addSubview(eventView)
        }
        
        updateTime()
        
        timeIndicator.removeFromSuperview()
        addSubview(timeIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for hour in 0 ..< hourLines.count {
            hourLines[hour].frame = CGRect(x: 0, y: ScheduleView.hourHeight * CGFloat(hour), width: bounds.size.width, height: 1)
            hourLabels[hour].frame.origin.y = ScheduleView.hourHeight * CGFloat(hour)
        }
        
        for view in eventViews {
            view.frame.origin.x = maxLabelWidth + 4
            view.frame.origin.y = (ScheduleView.hourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: view.startTime)) / 60)
            view.frame.size.width = bounds.size.width - (maxLabelWidth + 10)
        }
    }
    
    override func sizeToFit() {
        let itcs = intrinsicContentSize
        
        frame.size.width = max(frame.size.width, itcs.width)
        frame.size.height = max(frame.size.height, itcs.height)
    }
    
}
