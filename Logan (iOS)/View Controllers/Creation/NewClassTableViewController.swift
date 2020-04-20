//
//  NewClassTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/14/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewClassTableViewController: UITableViewController, DayOfWeekPickerDelegate {
    
    var correspondingCourse: Course!
    var newClass: Section = Section()
    
    @IBOutlet weak var titleField: UITextField!
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
            titleField.becomeFirstResponder()
            
            for semester in DataManager.shared.semesters {
                if semester.courses.contains(correspondingCourse) {
                    newClass.startDate = semester.startDate
                    newClass.endDate = semester.endDate
                    
                    newClass.startTime = ClockTime(date: Date())
                    newClass.endTime = ClockTime(date: Date())
                    break
                }
            }
            
            startDatePicker.calendarDay = newClass.startDate
            startDateLabel.text = BetterDateFormatter.autoFormatDate(newClass.startDate.dateValue!)
            endDatePicker.calendarDay = newClass.endDate
            endDateLabel.text = BetterDateFormatter.autoFormatDate(newClass.endDate.dateValue!)
            
            startTimePicker.date = newClass.startTime.dateValue!
            startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
            endTimePicker.date = newClass.endTime.dateValue!
            endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
            
            weeklyRepeatLabel.text = "\(newClass.weeklyRepeat) week(s)"
            weeklyRepeatStepper.value = Double(newClass.weeklyRepeat)
            
            var daysOfWeekString: [String] = []
            
            for day in newClass.daysOfWeek.sorted(by: { (day1, day2) -> Bool in
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
        newClass.title = titleField.text ?? ""
        newClass.location = locationField.text
        
        correspondingCourse.classes.append(newClass)
        
        DataManager.shared.introduce(newClass.record)
        DataManager.shared.update(correspondingCourse.record)
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            if datePicker.isEqual(startDatePicker) {
                startDateLabel.text = BetterDateFormatter.autoFormatDate(startDatePicker.dateValue)
                newClass.startDate = startDatePicker.calendarDay
            } else if datePicker.isEqual(endDatePicker) {
                endDateLabel.text = BetterDateFormatter.autoFormatDate(endDatePicker.dateValue)
                newClass.endDate = endDatePicker.calendarDay
            }
        } else if let timePicker = sender as? UIDatePicker {
            if timePicker.isEqual(startTimePicker) {
                startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
                newClass.startTime = ClockTime(date: startTimePicker.date)
            } else if timePicker.isEqual(endTimePicker) {
                endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
                newClass.endTime = ClockTime(date: endTimePicker.date)
            }
        }
    }
    
    @IBAction func weeklyRepeatStepped(_ stepper: UIStepper) {
        newClass.weeklyRepeat = Int(stepper.value)
        weeklyRepeatLabel.text = "\(newClass.weeklyRepeat) week(s)"
        weeklyRepeatStepper.value = Double(newClass.weeklyRepeat)
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
        newClass.daysOfWeek = daysOfWeek.sorted(by: { (day1, day2) -> Bool in
            return day1.rawValue < day2.rawValue
        })
        
        var daysOfWeekString: [String] = []
        
        for day in newClass.daysOfWeek {
            daysOfWeekString.append(day.shortName())
        }
        
        daysOfWeekLabel.text = daysOfWeekString.joined(separator: "/")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let picker = segue.destination as? DayOfWeekPickerTableViewController {
            picker.daysOfWeek = newClass.daysOfWeek
            picker.delegate = self
            picker.tableView.reloadData()
        }
    }

}
