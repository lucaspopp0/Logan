//
//  CommitmentsTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class CommitmentsTableViewController: UITableViewController, DMListener {
    
    private var dataSections: [(title: String, objects: [CKEnabled])] = []
    
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
        dataSections = []
        
        if DataManager.shared.extracurriculars.count > 0 {
            dataSections.append((title: "Extracurricular", objects: DataManager.shared.extracurriculars))
        }
        
        func addSemester(_ semester: Semester, toSection section: String) {
            for i in 0 ..< dataSections.count {
                if dataSections[i].title == section {
                    dataSections[i].objects.append(semester)
                    return
                }
            }
            
            dataSections.append((title: section, objects: [semester]))
        }
        
        for semester in DataManager.shared.semesters {
            if semester.endDate < CalendarDay(date: Date()) {
                addSemester(semester, toSection: "Past Academic")
            } else if semester.startDate > CalendarDay(date: Date()) {
                addSemester(semester, toSection: "Upcoming Academic")
            } else {
                addSemester(semester, toSection: "Current Academic")
            }
        }
        
        let titleOrder = ["Current Academic", "Extracurricular", "Upcoming Academic", "Past Academic"]
        
        dataSections.sort { (section1, section2) -> Bool in
            return titleOrder.index(of: section1.title)! < titleOrder.index(of: section2.title)!
        }
    }
    
    // MARK: - DMListener
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType) {
        if eventType == DMLoadingEventType.end {
            updateData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSections[section].objects.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSections[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let semester = dataSections[indexPath.section].objects[indexPath.row] as? Semester, let cell = tableView.dequeueReusableCell(withIdentifier: "Semester", for: indexPath) as? SemesterTableViewCell {
            cell.semester = semester
            cell.configureCell()
            
            return cell
        } else if let extracurricular = dataSections[indexPath.section].objects[indexPath.row] as? Extracurricular, let cell = tableView.dequeueReusableCell(withIdentifier: "Extracurricular", for: indexPath) as? ExtracurricularTableViewCell {
            cell.extracurricular = extracurricular
            cell.configureCell()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let semesterController = segue.destination as? SemesterTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow, let semester = dataSections[selectedIndexPath.section].objects[selectedIndexPath.row] as? Semester {
            semesterController.semester = semester
            
            DataManager.shared.pauseAutoUpdate()
        } else if let extracurricularController = segue.destination as? ExtracurricularTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow, let extracurricular = dataSections[selectedIndexPath.section].objects[selectedIndexPath.row] as? Extracurricular {
            extracurricularController.extracurricular = extracurricular
            
            DataManager.shared.pauseAutoUpdate()
        }
    }
    
}

