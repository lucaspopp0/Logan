//
//  OverviewViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataManagerListener, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tabBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var scheduleViewer: ScheduleScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var datePickerBar: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var datePicker: BetterDatePicker!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    internal var datePickerOpen: Bool = false
    
    var leftSwipeRecognizer: UISwipeGestureRecognizer!
    var rightSwipeRecognizer: UISwipeGestureRecognizer!
    
    var data: TableData<BEObject> = TableData<BEObject>()
    
    var alreadyOpened: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(OverviewViewController.handleSwipe(_:)))
        rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(OverviewViewController.handleSwipe(_:)))
        
        leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.left
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.right
        
        leftSwipeRecognizer.delegate = self
        rightSwipeRecognizer.delegate = self
        
        view.addGestureRecognizer(leftSwipeRecognizer)
        view.addGestureRecognizer(rightSwipeRecognizer)
        
        DataManager.shared.addListener(self)
        tabBar.backgroundColor = UIColor.teal500
        datePickerHeightConstraint.constant = dateLabel.frame.maxY + dateLabel.frame.minY
        view.layoutIfNeeded()
        
        datePicker.style = BetterDatePicker.Style.light
        
        toggleSegment(segmentedControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        scheduleViewer.reloadData()
        tableView.reloadData()
        
        dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !alreadyOpened {
            scheduleViewer.scrollToNow()
        }
        
        alreadyOpened = true
    }
    
    @IBAction func toggleDatePicker(_ sender: Any?) {
        if datePickerOpen {
            UIView.animate(withDuration: 0.2) {
                self.datePickerHeightConstraint.constant = self.dateLabel.frame.maxY + self.dateLabel.frame.minY
                self.view.layoutIfNeeded()
            }
            
            datePickerButton.setTitle("Go to…", for: UIControlState.normal)
        } else {
            UIView.animate(withDuration: 0.2) {
                self.datePickerHeightConstraint.constant = self.datePicker.frame.maxY + self.dateLabel.frame.minY
                self.view.layoutIfNeeded()
            }
            
            datePickerButton.setTitle("Done", for: UIControlState.normal)
        }
        
        datePickerOpen = !datePickerOpen
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        dateLabel.text = BetterDateFormatter.autoFormatDate(datePicker.dateValue)
        scheduleViewer.scheduleView.day = datePicker.calendarDay
        scheduleViewer.reloadData()
    }
    
    @IBAction func toggleSegment(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            datePickerBar.isHidden = false
            scheduleViewer.isHidden = false
            tableView.isHidden = true
        } else {
            datePickerBar.isHidden = true
            scheduleViewer.isHidden = true
            tableView.isHidden = false
        }
    }
    
    func updateData() {
        data.clear()
        
        let today = CalendarDay.today
        
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
            data.addSection(TableData<BEObject>.Section(title: "Assignments due this week", items: assignments))
        }
    }
    
    @objc func handleSwipe(_ recognizer: UIGestureRecognizer) {
        if let swipeRecognizer = recognizer as? UISwipeGestureRecognizer, swipeRecognizer.state == UIGestureRecognizerState.ended {
            if swipeRecognizer.direction == UISwipeGestureRecognizerDirection.left {
                datePicker.calendarDay = CalendarDay(date: Date(timeInterval:  (24 * 60 * 60), since: datePicker.dateValue))
                
                dateChanged(datePicker)
            } else if swipeRecognizer.direction == UISwipeGestureRecognizerDirection.right {
                datePicker.calendarDay = CalendarDay(date: Date(timeInterval: -(24 * 60 * 60), since: datePicker.dateValue))
                
                dateChanged(datePicker)
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?) {
        if eventType == .end {
            updateData()
            scheduleViewer.reloadData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let assignment = data.sections[indexPath.section].items[indexPath.row] as? Assignment, let cell = tableView.dequeueReusableCell(withIdentifier: "Assignment", for: indexPath) as? AssignmentTableViewCell {
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
