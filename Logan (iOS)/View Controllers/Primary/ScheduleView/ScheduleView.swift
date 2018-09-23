//
//  ScheduleView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import EventKit

class ScheduleView: UIView {
    
    var hourHeight: CGFloat = 80 {
        didSet {
            UserDefaults.standard.set(Float(hourHeight), forKey: "hourHeight")
            reloadData()
        }
    }
    
    var roundedHourHeight: CGFloat {
        get {
            if hourHeight < 87.5 && hourHeight > 72.5 {
                return 80
            }
            
            return hourHeight
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: super.intrinsicContentSize.width, height: 24 * roundedHourHeight)
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
    let timeLabel = UILabel()
    var hourLabels: [UILabel] = []
    var hourLines: [UIView] = []
    
    private var timer: Timer!
    
    private var maxLabelWidth: CGFloat = 0
    private var eventOffset: CGFloat {
        get {
            return maxLabelWidth + 8
        }
    }
    
    private func unifiedInit() {
        hourHeight = CGFloat(UserDefaults.standard.float(forKey: "hourHeight"))
        
        if hourHeight == 0 {
            hourHeight = 80
        }
        
        timeIndicator.backgroundColor = UIColor.orange500
        timeLabel.textColor = UIColor.orange500
        timeLabel.frame.origin.x = 0
        timeLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        timeLabel.textAlignment = NSTextAlignment.right
        addSubview(timeIndicator)
        addSubview(timeLabel)
        
        timeLabel.text = "10:00"
        timeLabel.sizeToFit()
        maxLabelWidth = timeLabel.frame.size.width
        
        startTimer()
        
        for hour in 1 ..< 24 {
            let formattedHour = (hour == 0) ? 12 : (hour <= 12 ? hour : hour - 12)
            let ampm = hour < 12 ? "A" : "P"
            
            let newLine = UIView()
            newLine.backgroundColor = UIColor(white: 0, alpha: 0.1)
            hourLines.append(newLine)
            addSubview(newLine)
            
            let newLabel = UILabel()
            newLabel.text = "\(formattedHour)\(ampm)"
            newLabel.textColor = UIColor(white: 0, alpha: 0.2)
            newLabel.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
            newLabel.sizeToFit()
            newLabel.frame.origin.x = 0
            hourLabels.append(newLabel)
            addSubview(newLabel)
            newLabel.frame.size.width = maxLabelWidth
            newLabel.textAlignment = NSTextAlignment.right
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
        timeIndicator.frame = CGRect(x: 0, y: (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: ClockTime(date: Date())) / 60)), width: bounds.size.width, height: 1)
        
        timeLabel.text = BetterDateFormatter.autoFormatTime(Date()).substring(to: -3)
        timeLabel.frame.origin.y = timeIndicator.frame.origin.y + 3
    }
    
    func reloadData() {
        timeIndicator.isHidden = (day != CalendarDay(date: Date()))
        timeLabel.isHidden = timeIndicator.isHidden
        
        while eventViews.count > 0 {
            eventViews.removeFirst().removeFromSuperview()
        }
        
        var classesToDisplay: [Class] = []
        var eventsToDisplay: [Event] = []
        let calendarEventsToDisplay: [EKEvent] = DataManager.shared.events(for: day)
        
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
            classView.frame.size.height = (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(ctd.startTime, and: ctd.endTime)) / 60) - 2
            classView.frame.origin.y = (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: ctd.startTime) ) / 60) + 1
            classView.dayOfWeek = dayOfWeek
            
            eventViews.append(classView)
            addSubview(classView)
        }
        
        for event in eventsToDisplay {
            let eventView = EventView()
            eventView.event = event
            eventView.frame.size.width = frame.size.width - 12
            eventView.frame.origin.x = 6
            eventView.frame.size.height = (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(event.startTime, and: event.endTime)) / 60) - 2
            eventView.frame.origin.y = (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: event.startTime) ) / 60) + 1
            eventView.dayOfWeek = dayOfWeek
            
            eventViews.append(eventView)
            addSubview(eventView)
        }
        
        for event in calendarEventsToDisplay {
            if event.isAllDay {
                continue
            }
            
            let eventView = EventView()
            eventView.calendarEvent = event
            eventView.frame.size.width = frame.size.width - 12
            eventView.frame.origin.x = 6
            eventView.frame.size.height = (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(ClockTime(date: event.startDate), and: ClockTime(date: event.endDate))) / 60) - 2
            eventView.frame.origin.y = (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: ClockTime(date: event.startDate)) ) / 60) + 1
            eventView.dayOfWeek = dayOfWeek
            
            eventViews.append(eventView)
            addSubview(eventView)
        }
        
        updateTime()
        
        timeIndicator.removeFromSuperview()
        timeLabel.removeFromSuperview()
        addSubview(timeIndicator)
        addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for hour in 1 ..< hourLines.count + 1 {
            hourLines[hour - 1].frame = CGRect(x: eventOffset, y: roundedHourHeight * CGFloat(hour), width: bounds.size.width - eventOffset, height: 1)
            hourLabels[hour - 1].frame.origin.y = (roundedHourHeight * CGFloat(hour)) - (hourLabels[hour - 1].frame.size.height / 2)
        }
        
        for view in eventViews {
            view.frame.origin.x = eventOffset
            view.frame.origin.y = (roundedHourHeight / 60) * (CGFloat(ClockTime.secondsBetween(dayStart, and: view.startTime)) / 60) + 1
            view.frame.size.width = bounds.size.width - eventOffset - 6
        }
    }
    
    override func sizeToFit() {
        let itcs = intrinsicContentSize
        
        frame.size.width = max(frame.size.width, itcs.width)
        frame.size.height = max(frame.size.height, itcs.height)
    }
    
}
