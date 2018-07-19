//
//  DayOfWeekPickerTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

protocol DayOfWeekPickerDelegate {
    
    func daysOfWeekSelected(_ daysOfWeek: [DayOfWeek])
    
}

class DayOfWeekPickerTableViewController: UITableViewController {
    
    var daysOfWeek: [DayOfWeek] = []
    
    var delegate: (AnyObject & DayOfWeekPickerDelegate)?

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        if let day = DayOfWeek(rawValue: indexPath.row) {
            cell.textLabel?.text = day.longName()
            cell.accessoryType = daysOfWeek.contains(day) ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let day = DayOfWeek(rawValue: indexPath.row) {
            if let dayIndex = daysOfWeek.index(of: day) {
                daysOfWeek.remove(at: dayIndex)
            } else {
                daysOfWeek.append(day)
            }
            
            daysOfWeek.sort(by: { (day1, day2) -> Bool in
                return day1.rawValue < day2.rawValue
            })
            
            delegate?.daysOfWeekSelected(daysOfWeek)
            
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }

}
