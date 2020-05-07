//
//  NewSemesterTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewSemesterTableViewController: CreationController {
    
    let semester = Semester(id: "newsemester", name: "", startDate: CalendarDay(date: Date()), endDate: CalendarDay(date: Date()))

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var startPicker: BetterDatePicker!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var endPicker: BetterDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !alreadyOpened {
            alreadyOpened = true
            
            startLabel.text = BetterDateFormatter.autoFormatDate(startPicker.dateValue)
            endLabel.text = BetterDateFormatter.autoFormatDate(endPicker.dateValue)
            
            nameField.becomeFirstResponder()
        }
    }
    
    @IBAction override func done(_ sender: Any) {
        super.done(sender)
        
        view.endEditing(true)
        nameField.isEnabled = false
        startPicker.isEnabled = false
        endPicker.isEnabled = false
        
        semester.name = nameField.text ?? ""
        
        API.shared.addSemester(semester) { (success, blob) in
            if success {
                self.semester.id = blob!["sid"] as! String
                DataManager.shared.semesters.append(self.semester)
            } else {
                // TODO: Alert user of error
                print("Error creating semester")
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
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
