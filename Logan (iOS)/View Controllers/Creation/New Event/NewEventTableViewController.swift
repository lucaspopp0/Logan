//
//  NewEventTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewEventTableViewController: UITableViewController {

    var correspondingExtracurricular: Extracurricular!
    var newEvent: Event!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    internal var alreadyOpened: Bool = false
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        correspondingExtracurricular.events.append(newEvent)
        
        DataManager.shared.introduce(newEvent.record)
        DataManager.shared.update(correspondingExtracurricular.record)
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textUpdated(_ sender: Any?) {
        newEvent.name = nameField.text ?? ""
        newEvent.location = locationField.text
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
