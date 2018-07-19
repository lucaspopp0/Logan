//
//  ScheduleTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    var classToDisplay: Class? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var colorSwatch: UIColorSwatch?
    @IBOutlet weak var classTitleLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel?
    
    func configureCell() {
        guard let classToDisplay = classToDisplay else { return }
        
        colorSwatch?.colorValue = classToDisplay.course.color
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
        
        locationLabel?.text = classToDisplay.location
    }
    
}
