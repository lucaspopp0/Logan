//
//  ScheduleTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController, DataManagerListener {
    
    private var data: TableData<Class> = TableData<Class>()
    
    private var updateTimer: UpdateTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.addListener(self)
        
        updateTimer = UpdateTimer(timeInterval: 0.5, completionBlock: { (userInfo) in
            self.updateData()
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
        tableView.reloadData()
        
        updateTimer.fire()
    }
    
    func updateData() {
        data.clear()
        
        if let currentSemester = DataManager.shared.currentSemester {
            let today = CalendarDay(date: Date())
            let now = ClockTime(date: Date())
            let currentDayOfWeek = DayOfWeek.forDate(Date())
            
            var allClasses: [Class] = []
            
            for course in currentSemester.courses {
                for courseClass in course.classes {
                    if courseClass.startDate <= today && courseClass.endDate >= today && courseClass.daysOfWeek.contains(currentDayOfWeek) {
                        allClasses.append(courseClass)
                    }
                }
            }
            
            allClasses.sort(by: { (c1, c2) -> Bool in
                return c1.endTime < c2.startTime
            })
            
            for scheduleClass in allClasses {
                if scheduleClass.startDate <= today && scheduleClass.endDate >= today && scheduleClass.daysOfWeek.contains(currentDayOfWeek) {
                    if scheduleClass.endTime <= now {
                        data.add(item: scheduleClass, section: "Past")
                    } else if scheduleClass.startTime >= now {
                        data.add(item: scheduleClass, section: "Upcoming")
                    } else if scheduleClass.startTime <= now && scheduleClass.endTime >= now {
                        data.add(item: scheduleClass, section: "Current")
                    }
                }
            }
        }
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType) {
        if eventType == DataManager.LoadingEventType.start {
            if let leftNavigationButton = navigationItem.leftBarButtonItem {
                if leftNavigationButton.title != nil && leftNavigationButton.title! == "Sync" {
                    leftNavigationButton.isEnabled = false
                }
            }
        } else if eventType == DataManager.LoadingEventType.end {
            updateData()
            tableView.reloadData()
            
            if let leftNavigationButton = navigationItem.leftBarButtonItem {
                if leftNavigationButton.title != nil && leftNavigationButton.title! == "Sync" {
                    leftNavigationButton.isEnabled = true
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Class", for: indexPath) as? ScheduleTableViewCell {
            cell.classToDisplay = data.sections[indexPath.section].items[indexPath.row]
            cell.configureCell()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
