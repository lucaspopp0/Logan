//
//  NewClassTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/14/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewSectionTableViewController: UITableViewController, DayOfWeekPickerDelegate {
    
    var correspondingCourse: Course!
    var newSection: Section = Section()
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: BetterDatePicker!
    
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: BetterDatePicker!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var weeklyRepeatLabel: UILabel!
    @IBOutlet weak var weeklyRepeatStepper: UIStepper!
    @IBOutlet weak var daysOfWeekLabel: UILabel!
    
    private var alreadyOpened: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !alreadyOpened {
            nameField.becomeFirstResponder()
            
            for semester in DataManager.shared.semesters {
                if semester.courses.contains(correspondingCourse) {
                    newSection.startDate = semester.startDate
                    newSection.endDate = semester.endDate
                    
                    newSection.startTime = ClockTime(date: Date())
                    newSection.endTime = ClockTime(date: Date())
                    break
                }
            }
            
            startDatePicker.calendarDay = newSection.startDate
            startDateLabel.text = BetterDateFormatter.autoFormatDate(newSection.startDate.dateValue!)
            endDatePicker.calendarDay = newSection.endDate
            endDateLabel.text = BetterDateFormatter.autoFormatDate(newSection.endDate.dateValue!)
            
            startTimePicker.date = newSection.startTime.dateValue!
            startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
            endTimePicker.date = newSection.endTime.dateValue!
            endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
            
            weeklyRepeatLabel.text = "\(newSection.weeklyRepeat) week(s)"
            weeklyRepeatStepper.value = Double(newSection.weeklyRepeat)
            
            var daysOfWeekString: [String] = []
            
            for day in newSection.daysOfWeek.sorted(by: { (day1, day2) -> Bool in
                return day1.rawValue < day2.rawValue
            }) {
                daysOfWeekString.append(day.shortName())
            }
            
            daysOfWeekLabel.text = daysOfWeekString.joined(separator: "/")
            
            alreadyOpened = true
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        newSection.name = nameField.text ?? ""
        newSection.location = locationField.text
        
        correspondingCourse.sections.append(newSection)
        
        DataManager.shared.introduce(newSection.record)
        DataManager.shared.update(correspondingCourse.record)
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            if datePicker.isEqual(startDatePicker) {
                startDateLabel.text = BetterDateFormatter.autoFormatDate(startDatePicker.dateValue)
                newSection.startDate = startDatePicker.calendarDay
            } else if datePicker.isEqual(endDatePicker) {
                endDateLabel.text = BetterDateFormatter.autoFormatDate(endDatePicker.dateValue)
                newSection.endDate = endDatePicker.calendarDay
            }
        } else if let timePicker = sender as? UIDatePicker {
            if timePicker.isEqual(startTimePicker) {
                startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
                newSection.startTime = ClockTime(date: startTimePicker.date)
            } else if timePicker.isEqual(endTimePicker) {
                endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
                newSection.endTime = ClockTime(date: endTimePicker.date)
            }
        }
    }
    
    @IBAction func weeklyRepeatStepped(_ stepper: UIStepper) {
        newSection.weeklyRepeat = Int(stepper.value)
        weeklyRepeatLabel.text = "\(newSection.weeklyRepeat) week(s)"
        weeklyRepeatStepper.value = Double(newSection.weeklyRepeat)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? PickerTableViewCell {
            return cell.fittingHeight
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 || indexPath.section == 2 {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: - Day of week picker delegate
    
    func daysOfWeekSelected(_ daysOfWeek: [DayOfWeek]) {
        newSection.daysOfWeek = daysOfWeek.sorted(by: { (day1, day2) -> Bool in
            return day1.rawValue < day2.rawValue
        })
        
        var daysOfWeekString: [String] = []
        
        for day in newSection.daysOfWeek {
            daysOfWeekString.append(day.shortName())
        }
        
        daysOfWeekLabel.text = daysOfWeekString.joined(separator: "/")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let picker = segue.destination as? DayOfWeekPickerTableViewController {
            picker.daysOfWeek = newSection.daysOfWeek
            picker.delegate = self
            picker.tableView.reloadData()
        }
    }

}
