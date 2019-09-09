//
//  CommitmentsTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class CommitmentsTableViewController: UITableViewController, DataManagerListener {
    
    private let data: TableData<CKEnabled> = TableData<CKEnabled>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.addListener(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
        tableView.reloadData()
        
        DataManager.shared.resumeAutoUpdate()
    }
    
    @IBAction func openSettings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)
        let settingsController = storyboard.instantiateViewController(withIdentifier: "Settings Controller")
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @IBAction func syncWithCloud(_ sender: Any) {
        DataManager.shared.fetchDataFromCloud()
    }
    
    @IBAction func newCommitment(_ sender: Any?) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        sheet.addAction(UIAlertAction(title: "New Semester", style: UIAlertActionStyle.default, handler: { (_) in
            self.performSegue(withIdentifier: "New Semester", sender: self)
        }))
        sheet.addAction(UIAlertAction(title: "New Extracurricular", style: UIAlertActionStyle.default, handler: { (_) in
            self.performSegue(withIdentifier: "New Extracurricular", sender: self)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(sheet, animated: true, completion: nil)
    }
    
    func updateData() {
        data.clear()
        
        if DataManager.shared.extracurriculars.count > 0 {
            data.addSection(TableData<CKEnabled>.Section(title: "Extracurricular", items: DataManager.shared.extracurriculars))
        }
        
        for semester in DataManager.shared.semesters {
            if semester.endDate < CalendarDay(date: Date()) {
                data.add(item: semester, section: "Past Academic")
            } else if semester.startDate > CalendarDay(date: Date()) {
                data.add(item: semester, section: "Upcoming Academic")
            } else {
                data.add(item: semester, section: "Current Academic")
            }
        }
        
        let titleOrder = ["Current Academic", "Extracurricular", "Upcoming Academic", "Past Academic"]
        
        data.sections.sort { (section1, section2) -> Bool in
            return titleOrder.index(of: section1.title)! < titleOrder.index(of: section2.title)!
        }
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?) {
        if eventType == DataManager.LoadingEventType.end {
            updateData()
            tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let semester = data.sections[indexPath.section].items[indexPath.row] as? Semester, let cell = tableView.dequeueReusableCell(withIdentifier: "Semester", for: indexPath) as? SemesterTableViewCell {
            cell.semester = semester
            cell.configureCell()
            
            return cell
        } else if let extracurricular = data.sections[indexPath.section].items[indexPath.row] as? Extracurricular, let cell = tableView.dequeueReusableCell(withIdentifier: "Extracurricular", for: indexPath) as? ExtracurricularTableViewCell {
            cell.extracurricular = extracurricular
            cell.configureCell()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let semesterController = segue.destination as? SemesterTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow, let semester = data.sections[selectedIndexPath.section].items[selectedIndexPath.row] as? Semester {
            semesterController.semester = semester
            
            DataManager.shared.pauseAutoUpdate()
        } else if let extracurricularController = segue.destination as? ExtracurricularTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow, let extracurricular = data.sections[selectedIndexPath.section].items[selectedIndexPath.row] as? Extracurricular {
            extracurricularController.extracurricular = extracurricular
            
            DataManager.shared.pauseAutoUpdate()
        }
    }
    
}

