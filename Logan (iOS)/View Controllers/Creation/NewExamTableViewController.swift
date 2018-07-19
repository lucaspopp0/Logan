//
//  NewExamTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewExamTableViewController: UITableViewController {
    
    var correspondingCourse: Course!
    var newExam: Exam = Exam()
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: BetterDatePicker!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    private var alreadyOpened: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !alreadyOpened {
            titleField.becomeFirstResponder()
            
            newExam.date = CalendarDay(date: Date())
            datePicker.calendarDay = newExam.date
            dateLabel.text = BetterDateFormatter.autoFormatDate(Date())
            
            newExam.startTime = ClockTime(date: Date())
            newExam.endTime = ClockTime(date: Date())
            
            startTimePicker.date = newExam.startTime.dateValue!
            startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
            endTimePicker.date = newExam.endTime.dateValue!
            endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
            
            alreadyOpened = true
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        newExam.title = titleField.text ?? ""
        newExam.location = locationField.text
        
        correspondingCourse.exams.append(newExam)
        
        DataManager.shared.introduce(newExam.record)
        DataManager.shared.update(correspondingCourse.record)
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
            newExam.date = datePicker.calendarDay
        } else if let timePicker = sender as? UIDatePicker {
            if timePicker.isEqual(startTimePicker) {
                startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
                newExam.startTime = ClockTime(date: startTimePicker.date)
            } else if timePicker.isEqual(endTimePicker) {
                endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
                newExam.endTime = ClockTime(date: endTimePicker.date)
            }
        }
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
    
}

