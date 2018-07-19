//
//  ScheduleView.swift
//  Schedule
//
//  Created by Lucas Popp on 3/15/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleView: UIView {
    
    var classToDisplay: Class? {
        didSet {
            configure()
        }
    }
    
    let colorSwatch: UIColorSwatch = UIColorSwatch()
    let courseNameLabel: UILabel = UILabel()
    let classTitleLabel: UILabel = UILabel()
    let timeRemainingLabel: UILabel = UILabel()
    let timeLabel: UILabel = UILabel()
    let locationLabel: UILabel = UILabel()
    
    private func unifiedInit() {
        addSubview(colorSwatch)
        addSubview(courseNameLabel)
        addSubview(classTitleLabel)
        addSubview(timeRemainingLabel)
        addSubview(timeLabel)
        addSubview(locationLabel)
        
        courseNameLabel.font = UIFont.systemFont(ofSize: 17)
        courseNameLabel.textColor = UIColor.black
        
        classTitleLabel.font = UIFont.systemFont(ofSize: 15)
        classTitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        timeRemainingLabel.font = UIFont.systemFont(ofSize: 17)
        timeRemainingLabel.textColor = UIColor.black
        
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        timeLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        
        locationLabel.font = UIFont.systemFont(ofSize: 15)
        locationLabel.textColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    func configure() {
        guard let classToDisplay = classToDisplay else { return }
        
        colorSwatch.colorValue = classToDisplay.course.color
        classTitleLabel.text = classToDisplay.title
        
        if classToDisplay.course.nickname.isEmpty {
            courseNameLabel.text = classToDisplay.course.name
        } else {
            courseNameLabel.text = classToDisplay.course.nickname
        }
        
        let today = Date()
        let now = ClockTime(date: today)
        
        if classToDisplay.startTime <= now && classToDisplay.endTime >= now {
            timeRemainingLabel.isHidden = false
            
            let timeRemaining = Int(classToDisplay.endTime.fixedToDate(today, overridingSeconds: true).timeIntervalSince(today))
            let minutesRemaining = Int(floor(Double(timeRemaining) / 60.0))
            let secondsRemaining = timeRemaining % 60
            
            var minutesString = ""
            var secondsString = ""
            
            if minutesRemaining > 0 {
                minutesString = "\(minutesRemaining) min"
            }
            
            if secondsRemaining > 0 {
                secondsString = "\(secondsRemaining) sec"
            }
            
            if minutesString.isEmpty && secondsString.isEmpty {
                timeRemainingLabel.text = "0 sec"
            } else if !minutesString.isEmpty && !secondsString.isEmpty {
                timeRemainingLabel.text = minutesString + " " + secondsString
            } else if minutesString.isEmpty {
                timeRemainingLabel.text = secondsString
            } else if secondsString.isEmpty {
                timeRemainingLabel.text = minutesString
            }
        } else {
            timeRemainingLabel.isHidden = true
        }
        
        timeLabel.text = "\(classToDisplay.startTime.stringValue) - \(classToDisplay.endTime.stringValue)"
        
        if classToDisplay.location == nil || classToDisplay.location!.isEmpty {
            locationLabel.isHidden = true
        } else {
            locationLabel.isHidden = false
            locationLabel.text = classToDisplay.location
        }
    }
    
    override func sizeToFit() {
        colorSwatch.frame.size.width = 18
        colorSwatch.frame.size.height = 18
        colorSwatch.frame.origin.x = 15
        
        courseNameLabel.sizeToFit()
        classTitleLabel.sizeToFit()
        timeRemainingLabel.sizeToFit()
        timeLabel.sizeToFit()
        locationLabel.sizeToFit()
        
        let stackHeight1 = classTitleLabel.frame.size.height + courseNameLabel.frame.size.height
        var stackHeight2 = timeLabel.frame.size.height
        
        if !timeRemainingLabel.isHidden {
            stackHeight2 += timeRemainingLabel.frame.size.height
        }
        
        if !locationLabel.isHidden {
            stackHeight2 += locationLabel.frame.size.height
        }
        
        frame.size.height = max(colorSwatch.frame.size.height, stackHeight1, stackHeight2) + 30
        colorSwatch.frame.origin.y = (frame.size.height - colorSwatch.frame.size.height) / 2
        
        courseNameLabel.frame.origin.x = colorSwatch.frame.maxX + 12
        courseNameLabel.frame.origin.y = (frame.size.height - stackHeight1) / 2
        classTitleLabel.frame.origin.x = courseNameLabel.frame.minX
        classTitleLabel.frame.origin.y = courseNameLabel.frame.maxY
        
        timeRemainingLabel.frame.origin.y = (frame.size.height - stackHeight2) / 2
        locationLabel.frame.origin.y = ((frame.size.height + stackHeight2) / 2) - locationLabel.frame.size.height
        
        if !timeRemainingLabel.isHidden {
            timeLabel.frame.origin.y = ((frame.size.height - stackHeight2) / 2) + timeRemainingLabel.frame.size.height
        } else {
            timeLabel.frame.origin.y = (frame.size.height - stackHeight2) / 2
        }
        
        timeRemainingLabel.frame.origin.x = frame.size.width - timeRemainingLabel.frame.size.width - 15
        timeLabel.frame.origin.x = frame.size.width - timeLabel.frame.size.width - 15
        locationLabel.frame.origin.x = frame.size.width - locationLabel.frame.size.width - 15
    }
    
}
