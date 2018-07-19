//
//  NewSingleEventTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewSingleEventTableViewController: NewEventTableViewController {
    
    var singleEvent: SingleEvent {
        get {
            return newEvent as! SingleEvent
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: BetterDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEvent = SingleEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !alreadyOpened {
            nameField.becomeFirstResponder()
            
            singleEvent.date = CalendarDay(date: Date())
            singleEvent.startTime = ClockTime(date: Date())
            singleEvent.endTime = ClockTime(date: Date())
            
            datePicker.calendarDay = singleEvent.date
            dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
            
            startTimePicker.date = newEvent.startTime.dateValue!
            startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
            endTimePicker.date = newEvent.endTime.dateValue!
            endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
            
            alreadyOpened = true
        }
    }
    
    override func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
            singleEvent.date = datePicker.calendarDay
        } else if let timePicker = sender as? UIDatePicker {
            if timePicker.isEqual(startTimePicker) {
                startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
                newEvent.startTime = ClockTime(date: startTimePicker.date)
            } else if timePicker.isEqual(endTimePicker) {
                endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
                newEvent.endTime = ClockTime(date: endTimePicker.date)
            }
        }
    }
    
}
