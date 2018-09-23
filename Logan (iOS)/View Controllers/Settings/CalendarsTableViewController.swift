//
//  CalendarsTableViewController.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 8/30/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import EventKit

class CalendarsTableViewController: UITableViewController {
    
    var sources: [EKSource] {
        get {
            return DataManager.shared.eventStore.sources.sorted(by: { (source1, source2) -> Bool in
                if source1.title == "Subscribed Calendars" {
                    return false
                } else if source2.title == "Subscribed Calendars" {
                    return true
                } else if source1.title == "Other" {
                    return false
                } else if source2.title == "Other" {
                    return true
                } else {
                    return source1.title < source2.title
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sources.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sources[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources[section].calendars(for: EKEntityType.event).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Calendar")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Calendar", for: indexPath)
        
        for (i, calendar) in sources[indexPath.section].calendars(for: EKEntityType.event).enumerated() {
            if indexPath.row == i {
                cell.textLabel?.text = calendar.title
                cell.tintColor = UIColor(cgColor: calendar.cgColor)
                cell.accessoryType = DataManager.shared.calendarIdsToDisplay.contains(calendar.calendarIdentifier) ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
                
                break
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tappedCalendar: EKCalendar!
        
        for (i, calendar) in sources[indexPath.section].calendars(for: EKEntityType.event).enumerated() {
            if indexPath.row == i {
                tappedCalendar = calendar
                break
            }
        }
        
        if DataManager.shared.calendarIdsToDisplay.contains(tappedCalendar.calendarIdentifier) {
            DataManager.shared.calendarIdsToDisplay.remove(tappedCalendar.calendarIdentifier)
        } else {
            DataManager.shared.calendarIdsToDisplay.insert(tappedCalendar.calendarIdentifier)
        }
        
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }

}
