//
//  OverviewViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DMListener {
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var scheduleViewer: ScheduleScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSections: [(title: String, things: [CKEnabled])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.shared.addListener(self)
        tabBar.backgroundColor = UIColor.teal500
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        scheduleViewer.reloadData()
        tableView.reloadData()
    }
    
    @IBAction func toggleSegment(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            scheduleViewer.isHidden = false
            tableView.isHidden = true
        } else {
            scheduleViewer.isHidden = true
            tableView.isHidden = false
        }
    }
    
    func updateData() {
        dataSections = []
        
        let today = CalendarDay(date: Date())
        let thirtyDays = CalendarDay(date: Date(timeIntervalSinceNow: 30 * 24 * 60 * 60))
        
        var exams: [Exam] = []
        
        for semester in DataManager.shared.semesters {
            for course in semester.courses {
                for exam in course.exams {
                    if exam.date >= today && exam.date <= thirtyDays {
                        exams.append(exam)
                    }
                }
            }
        }
        
        exams.sort { (e1, e2) -> Bool in
            return e1.date <= e2.date
        }
        
        if exams.count > 0 {
            dataSections.append((title: "Exams in the next 30 days", things: exams))
        }
        
        var assignments: [Assignment] = []
        
        for assignment in DataManager.shared.assignments {
            if case .specificDeadline(let deadline) = assignment.dueDate, let dueDate = deadline.dateValue {
                let dayDue = CalendarDay(date: dueDate)
                
                if dayDue >= today && Date.daysBetween(Date(), and: dueDate) <= 8 {
                    if dueDate.weekOfYear == Date().weekOfYear {
                        assignments.append(assignment)
                    }
                }
            }
        }
        
        assignments.sort { (a1, a2) -> Bool in
            if case .specificDeadline(let d1) = a1.dueDate, case .specificDeadline(let d2) = a2.dueDate {
                return d1.dateValue! <= d2.dateValue!
            } else {
                return true
            }
        }
        
        if assignments.count > 0 {
            dataSections.append((title: "Assignments due this week", things: assignments))
        }
    }
    
    // MARK: - DMListener
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType) {
        if eventType == .end {
            updateData()
            scheduleViewer.reloadData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSections[section].things.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let exam = dataSections[indexPath.section].things[indexPath.row] as? Exam, let cell = tableView.dequeueReusableCell(withIdentifier: "Exam", for: indexPath) as? OverviewExamTableViewCell {
            cell.exam = exam
            cell.configureCell()
            
            return cell
        } else if let assignment = dataSections[indexPath.section].things[indexPath.row] as? Assignment, let cell = tableView.dequeueReusableCell(withIdentifier: "Assignment", for: indexPath) as? AssignmentTableViewCell {
            cell.assignment = assignment
            cell.configureCell()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
