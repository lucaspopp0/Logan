//
//  ExamTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ExamTableViewController: UITableViewController {
    
    var exam: Exam!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: BetterDatePicker!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleField.text = exam.title
        locationField.text = exam.location
        
        datePicker.calendarDay = exam.date
        dateLabel.text = BetterDateFormatter.autoFormatDate(exam.date.dateValue!)
        
        startTimePicker.date = exam.startTime.dateValue!
        startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
        endTimePicker.date = exam.endTime.dateValue!
        endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager.shared.update(exam.record)
    }
    
    @IBAction func titleUpdated(_ sender: Any) {
        exam.title = titleField.text ?? ""
    }
    
    @IBAction func locationUpdated(_ sender: Any) {
        exam.location = locationField.text
    }
    
    @IBAction func dateUpdated(_ sender: Any) {
        if let datePicker = sender as? BetterDatePicker {
            dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
            exam.date = datePicker.calendarDay
        } else if let timePicker = sender as? UIDatePicker {
            if timePicker.isEqual(startTimePicker) {
                startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
                exam.startTime = ClockTime(date: startTimePicker.date)
            } else if timePicker.isEqual(endTimePicker) {
                endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
                exam.endTime = ClockTime(date: endTimePicker.date)
            }
        }
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
    
}

