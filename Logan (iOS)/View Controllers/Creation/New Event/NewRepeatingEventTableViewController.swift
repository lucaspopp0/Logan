//
//  NewRepeatingEventTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewRepeatingEventTableViewController: NewEventTableViewController, DayOfWeekPickerDelegate {
    
    var repeatingEvent: RepeatingEvent {
        get {
            return newEvent as! RepeatingEvent
        }
    }
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: BetterDatePicker!
    
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: BetterDatePicker!
    
    @IBOutlet weak var weeklyRepeatLabel: UILabel!
    @IBOutlet weak var weeklyRepeatStepper: UIStepper!
    @IBOutlet weak var daysOfWeekLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEvent = RepeatingEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !alreadyOpened {
            nameField.becomeFirstResponder()
            
            repeatingEvent.startDate = CalendarDay(date: Date())
            repeatingEvent.endDate = CalendarDay(date: Date())
            
            repeatingEvent.startTime = ClockTime(date: Date())
            repeatingEvent.endTime = ClockTime(date: Date())
            
            startDatePicker.calendarDay = repeatingEvent.startDate
            startDateLabel.text = BetterDateFormatter.autoFormatDate(startDatePicker.dateValue)
            endDatePicker.calendarDay = repeatingEvent.endDate
            endDateLabel.text = BetterDateFormatter.autoFormatDate(endDatePicker.dateValue)
            
            startTimePicker.date = newEvent.startTime.dateValue!
            startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
            endTimePicker.date = newEvent.endTime.dateValue!
            endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
            
            weeklyRepeatLabel.text = "\(repeatingEvent.weeklyRepeat) week(s)"
            weeklyRepeatStepper.value = Double(repeatingEvent.weeklyRepeat)
            
            var daysOfWeekString: [String] = []
            
            for day in repeatingEvent.daysOfWeek.sorted(by: { (day1, day2) -> Bool in
                return day1.rawValue < day2.rawValue
            }) {
                daysOfWeekString.append(day.shortName())
            }
            
            daysOfWeekLabel.text = daysOfWeekString.joined(separator: "/")
            
            alreadyOpened = true
        }
    }
    
    override func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            if datePicker.isEqual(startDatePicker) {
                startDateLabel.text = BetterDateFormatter.autoFormatDate(startDatePicker.dateValue)
                repeatingEvent.startDate = startDatePicker.calendarDay
            } else if datePicker.isEqual(endDatePicker) {
                endDateLabel.text = BetterDateFormatter.autoFormatDate(endDatePicker.dateValue)
                repeatingEvent.endDate = endDatePicker.calendarDay
            }
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
    
    @IBAction func weeklyRepeatStepped(_ stepper: UIStepper) {
        repeatingEvent.weeklyRepeat = Int(stepper.value)
        weeklyRepeatLabel.text = "\(repeatingEvent.weeklyRepeat) week(s)"
        weeklyRepeatStepper.value = Double(repeatingEvent.weeklyRepeat)
    }
    
    // MARK: - Day of week picker delegate
    
    func daysOfWeekSelected(_ daysOfWeek: [DayOfWeek]) {
        repeatingEvent.daysOfWeek = daysOfWeek.sorted(by: { (day1, day2) -> Bool in
            return day1.rawValue < day2.rawValue
        })
        
        var daysOfWeekString: [String] = []
        
        for day in repeatingEvent.daysOfWeek {
            daysOfWeekString.append(day.shortName())
        }
        
        daysOfWeekLabel.text = daysOfWeekString.joined(separator: "/")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let picker = segue.destination as? DayOfWeekPickerTableViewController {
            picker.daysOfWeek = repeatingEvent.daysOfWeek
            picker.delegate = self
            picker.tableView.reloadData()
        }
    }
    
}
