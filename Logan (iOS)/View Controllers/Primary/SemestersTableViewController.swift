//
//  SemestersTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SemestersTableViewController: UITableViewController, DataManagerListener {
    
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    private var data: TableData<Semester> = TableData<Semester>()

    override func viewDidLoad() {
        super.viewDidLoad()

        InterfaceManager.shared.semestersController = self
        DataManager.shared.addListener(self)
        
        if DataManager.shared.currentCloudStatus == DataManager.ConnectionStatus.fetching {
            syncButton.image = #imageLiteral(resourceName: "Cloud Progress")
        } else if DataManager.shared.currentCloudStatus == DataManager.ConnectionStatus.ready {
            syncButton.image = #imageLiteral(resourceName: "Cloud Sync")
        } else if DataManager.shared.currentCloudStatus == DataManager.ConnectionStatus.error {
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
        data.clear()
        
        for semester in DataManager.shared.semesters {
            if semester.endDate < CalendarDay(date: Date()) {
                data.add(item: semester, section: "Past")
            } else if semester.startDate > CalendarDay(date: Date()) {
                data.add(item: semester, section: "Upcoming")
            } else {
                data.add(item: semester, section: "Current")
            }
        }
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType) {
        if eventType == DataManager.LoadingEventType.start {
            syncButton.image = #imageLiteral(resourceName: "Cloud Progress")
        } else if eventType == DataManager.LoadingEventType.end {
            updateData()
            tableView.reloadData()
            
            syncButton.image = #imageLiteral(resourceName: "Cloud Sync")
        } else if eventType == DataManager.LoadingEventType.error {
            syncButton.image = #imageLiteral(resourceName: "Cloud Error")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Semester", for: indexPath)

        cell.textLabel?.text = data.sections[indexPath.section].items[indexPath.row].name

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let semesterController = segue.destination as? SemesterTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow {
            semesterController.semester = data.sections[selectedIndexPath.section].items[selectedIndexPath.row]
        }
    }

}
