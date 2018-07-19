//
//  NewReminderTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/22/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewReminderTableViewController: UITableViewController, UITextViewDelegate {
    
    let reminder: Reminder = Reminder()
    
    @IBOutlet weak var messageInput: BetterTextView!
    @IBOutlet weak var datePicker: BetterDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var alreadyOpened: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateChanged(nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !alreadyOpened {
            alreadyOpened = true
            messageInput.becomeFirstResponder()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        DataManager.shared.introduce(reminder.record)
        
        if reminder.assignment != nil {
            reminder.assignment!.reminders.append(reminder)
            
            reminder.assignment!.sortReminders()
            
            DataManager.shared.update(reminder.assignment!.record)
        } else if reminder.task != nil {
            // TODO: reminder.task!.reminders.append(reminder)
            // TODO: DataManager.shared.update(task!.record)
        }
        
        NotificationManager.shared.addNotificationForReminder(reminder)
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateChanged(_ sender: Any?) {
        reminder.triggerDate = BetterDate(day: datePicker.calendarDay, time: ClockTime(date: timePicker.date))
        
        dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
        timeLabel.text = BetterDateFormatter.autoFormatTime(timePicker.date)
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        reminder.message = messageInput.text
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? PickerTableViewCell {
            return cell.fittingHeight
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            messageInput.resignFirstResponder()
            
            if let thisPicker = tableView.cellForRow(at: indexPath) as? PickerTableViewCell, let otherPicker = tableView.cellForRow(at: IndexPath(row: 1 - indexPath.row, section: indexPath.section)) as? PickerTableViewCell {
                if thisPicker.pickerOpen && otherPicker.pickerOpen {
                    tableView.selectRow(at: IndexPath(row: 1 - indexPath.row, section: indexPath.section), animated: false, scrollPosition: UITableViewScrollPosition.none)
                    self.tableView(tableView, didSelectRowAt: IndexPath(row: 1 - indexPath.row, section: indexPath.section))
                    tableView.deselectRow(at: IndexPath(row: 1 - indexPath.row, section: indexPath.section), animated: false)
                }
            }
        }
    }

}
