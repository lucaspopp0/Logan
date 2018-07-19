//
//  SemestersTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SemestersTableViewController: UITableViewController, DMListener {
    
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    private var data: [(title: String, semesters: [Semester])] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        InterfaceManager.shared.semestersController = self
        DataManager.shared.addListener(self)
        
        if DataManager.shared.currentCloudStatus == DMCloudConnectionStatus.fetching {
            syncButton.image = #imageLiteral(resourceName: "Cloud Progress")
        } else if DataManager.shared.currentCloudStatus == DMCloudConnectionStatus.ready {
            syncButton.image = #imageLiteral(resourceName: "Cloud Sync")
        } else if DataManager.shared.currentCloudStatus == DMCloudConnectionStatus.error {
            syncButton.image = #imageLiteral(resourceName: "Cloud Error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
        tableView.reloadData()
    }
    
    @IBAction func syncWithCloud(_ sender: Any) {
        DataManager.shared.fetchDataFromCloud()
    }
    
    func updateData() {
        data = []
        
        func addSemester(_ semester: Semester, toSection section: String) {
            for i in 0 ..< data.count {
                if data[i].title == section {
                    data[i].semesters.append(semester)
                    return
                }
            }
            
            data.append((title: section, semesters: [semester]))
        }
        
        for semester in DataManager.shared.semesters {
            if semester.endDate < CalendarDay(date: Date()) {
                addSemester(semester, toSection: "Past")
            } else if semester.startDate > CalendarDay(date: Date()) {
                addSemester(semester, toSection: "Upcoming")
            } else {
                addSemester(semester, toSection: "Current")
            }
        }
    }
    
    // MARK: - DMListener
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType) {
        if eventType == DMLoadingEventType.start {
            syncButton.image = #imageLiteral(resourceName: "Cloud Progress")
        } else if eventType == DMLoadingEventType.end {
            updateData()
            tableView.reloadData()
            
            syncButton.image = #imageLiteral(resourceName: "Cloud Sync")
        } else if eventType == DMLoadingEventType.error {
            syncButton.image = #imageLiteral(resourceName: "Cloud Error")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].semesters.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Semester", for: indexPath)

        cell.textLabel?.text = data[indexPath.section].semesters[indexPath.row].name

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let semesterController = segue.destination as? SemesterTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow {
            semesterController.semester = data[selectedIndexPath.section].semesters[selectedIndexPath.row]
        }
    }

}
