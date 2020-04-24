//
//  ScheduleTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    var sectionToDisplay: Section? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var colorSwatch: UIColorSwatch?
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel?
    
    func configureCell() {
        guard let sectionToDisplay = sectionToDisplay else { return }
        
        colorSwatch?.colorValue = sectionToDisplay.course.color
        sectionTitleLabel.text = sectionToDisplay.name
        
        if sectionToDisplay.course.nickname == nil {
            courseNameLabel.text = sectionToDisplay.course.name
        } else {
            courseNameLabel.text = sectionToDisplay.course.nickname
        }
        
        let today = Date()
        let now = ClockTime(date: today)
        
        if sectionToDisplay.startTime <= now && sectionToDisplay.endTime >= now {
            timeRemainingLabel.isHidden = false
            
            let timeRemaining = Int(sectionToDisplay.endTime.fixedToDate(today, overridingSeconds: true).timeIntervalSince(today))
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
        
        timeLabel.text = "\(sectionToDisplay.startTime.format("h:mm a")!) - \(sectionToDisplay.endTime.format("h:mm a")!)"
        
        locationLabel?.text = sectionToDisplay.location
    }
    
}
