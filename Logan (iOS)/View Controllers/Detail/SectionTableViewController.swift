//
//  ClassTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SectionTableViewController: UITableViewController, DayOfWeekPickerDelegate {
    
    var sectionToDisplay: Section!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var weeklyRepeatLabel: UILabel!
    @IBOutlet weak var weeklyRepeatStepper: UIStepper!
    @IBOutlet weak var daysOfWeekLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: BetterDatePicker!
    
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: BetterDatePicker!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = sectionToDisplay.name
        locationField.text = sectionToDisplay.location
        
        startDatePicker.calendarDay = sectionToDisplay.startDate
        startDateLabel.text = BetterDateFormatter.autoFormatDate(sectionToDisplay.startDate.dateValue!)
        endDatePicker.calendarDay = sectionToDisplay.endDate
        endDateLabel.text = BetterDateFormatter.autoFormatDate(sectionToDisplay.endDate.dateValue!)
        
        startTimePicker.date = sectionToDisplay.startTime.dateValue!
        startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
        endTimePicker.date = sectionToDisplay.endTime.dateValue!
        endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
        
        weeklyRepeatLabel.text = "\(sectionToDisplay.weeklyRepeat) week(s)"
        weeklyRepeatStepper.value = Double(sectionToDisplay.weeklyRepeat)
        
        var daysOfWeekString: [String] = []
        
        for day in sectionToDisplay.daysOfWeek.sorted(by: { (day1, day2) -> Bool in
            return day1.rawValue < day2.rawValue
        }) {
            daysOfWeekString.append(day.shortName())
        }
        
        daysOfWeekLabel.text = daysOfWeekString.joined(separator: "/")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager.shared.update(sectionToDisplay.record)
    }
    
    @IBAction func nameUpdated(_ sender: Any) {
        sectionToDisplay.name = nameField.text ?? ""
    }
    
    @IBAction func locationUpdated(_ sender: Any) {
        sectionToDisplay.location = locationField.text
    }
    
    @IBAction func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            if datePicker.isEqual(startDatePicker) {
                startDateLabel.text = BetterDateFormatter.autoFormatDate(startDatePicker.dateValue)
                sectionToDisplay.startDate = startDatePicker.calendarDay
            } else if datePicker.isEqual(endDatePicker) {
                endDateLabel.text = BetterDateFormatter.autoFormatDate(endDatePicker.dateValue)
                sectionToDisplay.endDate = endDatePicker.calendarDay
            }
        } else if let timePicker = sender as? UIDatePicker {
            if timePicker.isEqual(startTimePicker) {
                startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
                sectionToDisplay.startTime = ClockTime(date: startTimePicker.date)
            } else if timePicker.isEqual(endTimePicker) {
                endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
                sectionToDisplay.endTime = ClockTime(date: endTimePicker.date)
            }
        }
    }
    
    @IBAction func weeklyRepeatStepped(_ stepper: UIStepper) {
        sectionToDisplay.weeklyRepeat = Int(stepper.value)
        weeklyRepeatLabel.text = "\(sectionToDisplay.weeklyRepeat) week(s)"
        weeklyRepeatStepper.value = Double(sectionToDisplay.weeklyRepeat)
    }
    
    // MARK: - Day of week picker delegate
    
    func daysOfWeekSelected(_ daysOfWeek: [DayOfWeek]) {
        sectionToDisplay.daysOfWeek = daysOfWeek.sorted(by: { (day1, day2) -> Bool in
            return day1.rawValue < day2.rawValue
        })
        
        var daysOfWeekString: [String] = []
        
        for day in sectionToDisplay.daysOfWeek {
            daysOfWeekString.append(day.shortName())
        }
        
        daysOfWeekLabel.text = daysOfWeekString.joined(separator: "/")
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 || indexPath.section == 2 {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 || indexPath.section == 2 {
            if let cell = tableView.cellForRow(at: indexPath) as? PickerTableViewCell {
                return cell.fittingHeight
            } else {
                return 44
            }
        }
        
        return UITableViewAutomaticDimension
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let picker = segue.destination as? DayOfWeekPickerTableViewController {
            picker.daysOfWeek = sectionToDisplay.daysOfWeek
            picker.delegate = self
            picker.tableView.reloadData()
        }
    }

}
