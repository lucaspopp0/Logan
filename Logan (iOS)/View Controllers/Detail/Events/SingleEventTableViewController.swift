//
//  SingleEventTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SingleEventTableViewController: EventTableViewController {

    var singleEvent: SingleEvent {
        get {
            return event as! SingleEvent
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: BetterDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        datePicker.calendarDay = singleEvent.date
        dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
    }
    
    override func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
            singleEvent.date = datePicker.calendarDay
        } else if let timePicker = sender as? UIDatePicker {
            if timePicker.isEqual(startTimePicker) {
                startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
                event.startTime = ClockTime(date: startTimePicker.date)
            } else if timePicker.isEqual(endTimePicker) {
                endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
                event.endTime = ClockTime(date: endTimePicker.date)
            }
        }
    }

}
