//
//  NewClassTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/14/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewSectionTableViewController: CreationController, DayOfWeekPickerDelegate {
    
    var correspondingCourse: Course!
    var newSection: Section!
    
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
    
    func setupInitialData() {
        let startDate = CalendarDay(date: correspondingCourse.semester.startDate.dateValue!)
        let endDate = CalendarDay(date: correspondingCourse.semester.endDate.dateValue!)
        let startTime = ClockTime.now
        let endTime = ClockTime.now
        
        newSection = Section(id: "newsection", name: "", startDate: startDate, startTime: startTime, endDate: endDate, endTime: endTime, daysOfWeek: [], location: nil, weeklyRepeat: 1, course: correspondingCourse)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !alreadyOpened {
            alreadyOpened = true
            
            nameField.becomeFirstResponder()
            
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
        }
    }
    
    @IBAction override func done(_ sender: Any) {
        super.done(sender)
        
        view.endEditing(true)
        nameField.isEnabled = false
        locationField.isEnabled = false
        startDatePicker.isEnabled = false
        endDatePicker.isEnabled = false
        startTimePicker.isEnabled = false
        endTimePicker.isEnabled = false
        weeklyRepeatStepper.isEnabled = false
        
        newSection.name = nameField.text ?? ""
        newSection.location = locationField.text
        
        API.shared.addSection(newSection) { (success, blob) in
            if success {
                self.newSection.id = blob!["secid"] as! String
                self.correspondingCourse.sections.append(self.newSection)
            } else {
                print("Error creating section")
                // TODO: Alert user of error
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
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
