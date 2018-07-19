//
//  EventTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController {

    var correspondingExtracurricular: Extracurricular!
    var event: Event!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = event.name
        locationField.text = event.location
        
        startTimePicker.date = event.startTime.dateValue!
        startTimeLabel.text = BetterDateFormatter.autoFormatTime(startTimePicker.date)
        endTimePicker.date = event.endTime.dateValue!
        endTimeLabel.text = BetterDateFormatter.autoFormatTime(endTimePicker.date)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataManager.shared.update(event.record)
    }
    
    @IBAction func textUpdated(_ sender: Any?) {
        event.name = nameField.text ?? ""
        event.location = locationField.text
    }
    
    @IBAction func dateUpdated(_ sender: Any) {}
    
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
