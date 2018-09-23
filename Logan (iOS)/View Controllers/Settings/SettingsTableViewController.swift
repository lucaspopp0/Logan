//
//  SettingsTableViewController.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 7/21/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic Cell", for: indexPath)

        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = "Calendars"
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "View Logs"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "API Info"
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Developer"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == tableView.numberOfSections - 1 {
            return "© \(CalendarDay(date: Date()).year) Lucas Popp"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 0, let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textAlignment = NSTextAlignment.center
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "Edit Calendars", sender: self)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "View Logs", sender: self)
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "API Info", sender: self)
            }
        }
    }

}
