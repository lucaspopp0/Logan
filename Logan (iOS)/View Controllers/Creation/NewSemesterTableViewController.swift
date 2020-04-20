//
//  NewSemesterTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewSemesterTableViewController: UITableViewController {
    
    let ssemester = Semester(
    
    let semester = Semester(name: "", startDate: CalendarDay(date: Date()), endDate: CalendarDay(date: Date()))

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var startPicker: BetterDatePicker!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var endPicker: BetterDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLabel.text = BetterDateFormatter.autoFormatDate(startPicker.dateValue)
        endLabel.text = BetterDateFormatter.autoFormatDate(endPicker.dateValue)
        
        nameField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        semester.name = nameField.text ?? ""
        
        DataManager.shared.semesters.append(semester)
        DataManager.shared.introduce(semester.record)
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func boundaryChanged(_ sender: BetterDatePicker) {
        if sender.isEqual(startPicker) {
            semester.startDate = sender.calendarDay
            startLabel.text = BetterDateFormatter.autoFormatDate(sender.dateValue)
        } else if sender.isEqual(endPicker) {
            semester.endDate = sender.calendarDay
            endLabel.text = BetterDateFormatter.autoFormatDate(sender.dateValue)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 || indexPath.row == 2 {
            if let cell = tableView.cellForRow(at: indexPath) as? PickerTableViewCell {
                return cell.fittingHeight
            }
        }
        
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

}
