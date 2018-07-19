//
//  ScheduleWidgetViewController.swift
//  Schedule
//
//  Created by Lucas Popp on 1/30/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import NotificationCenter

class ScheduleWidgetViewController: UIViewController, DMListener, NCWidgetProviding {
    
    private var updateTimer: UpdateTimer!
    
    @IBOutlet weak var scheduleList: ScheduleListView!
    
    @IBOutlet weak var noClassLabel: UILabel!
    @IBOutlet weak var currentCourseView: UIView!
    @IBOutlet weak var currentCourseColorSwatch: UIColorSwatch!
    @IBOutlet weak var currentCourseLabel: UILabel!
    @IBOutlet weak var currentClassTitleLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSpanLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var currentClass: Class?
    
    func updateCurrentClass() {
        if let currentSemester = DataManager.shared.currentSemester {
            let today = CalendarDay(date: Date())
            let now = ClockTime(date: Date())
            let currentDayOfWeek = DayOfWeek.forDate(Date())
            
            for course in currentSemester.courses {
                for courseClass in course.classes {
                    if courseClass.startDate <= today && courseClass.endDate >= today && courseClass.daysOfWeek.contains(currentDayOfWeek) {
                        if courseClass.startTime <= now && courseClass.endTime >= now {
                            currentClass = courseClass
                            return
                        }
                    }
                }
            }
        }
        
        currentClass = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.addListener(self)
        extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        
        updateTimer = UpdateTimer(timeInterval: 1, completionBlock: { (info) in
            self.updateData()
            self.updateInterface()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTimer.begin()
        updateTimer.fire()
        
        updateInterface()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer.cancel()
    }
    
    func updateData() {
        scheduleList.sections = []
        
        func addClass(_ classToAdd: Class, toSection section: String) {
            for i in 0 ..< scheduleList.sections.count {
                if scheduleList.sections[i].title == section {
                    scheduleList.sections[i].classes.append(classToAdd)
                    return
                }
            }
            
            scheduleList.sections.append((title: section, classes: [classToAdd]))
        }
        
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
                        addClass(scheduleClass, toSection: "Past")
                    } else if scheduleClass.startTime >= now {
                        addClass(scheduleClass, toSection: "Upcoming")
                    } else if scheduleClass.startTime <= now && scheduleClass.endTime >= now {
                        addClass(scheduleClass, toSection: "Current")
                    }
                }
            }
            
            if allClasses.count == 0 {
                extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact
            } else {
                extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
            }
        }
    }
    
    func updateInterface(_ maxSize: CGSize? = nil) {
        scheduleList.reloadData()
        scheduleList.sizeToFit()
        
        var currentClass: Class? = nil
        var nextClass: Class? = nil
        
        if let currentSemester = DataManager.shared.currentSemester {
            let today = CalendarDay(date: Date())
            let now = ClockTime(date: Date())
            let currentDayOfWeek = DayOfWeek.forDate(Date())
            
            var classesToSort: [Class] = []
            
            for course in currentSemester.courses {
                for courseClass in course.classes {
                    if courseClass.startDate <= today && courseClass.endDate >= today && courseClass.daysOfWeek.contains(currentDayOfWeek) {
                        classesToSort.append(courseClass)
                    }
                }
            }
            
            classesToSort.sort(by: { (c1, c2) -> Bool in
                return c1.startTime <= c2.startTime
            })
            
            for i in 0 ..< classesToSort.count {
                if classesToSort[i].startTime <= now && classesToSort[i].endTime >= now {
                    currentClass = classesToSort[i]
                } else {
                    if i == 0 && classesToSort[i].startTime >= now {
                        nextClass = classesToSort[i]
                        break
                    } else if i > 0 && classesToSort[i - 1].endTime <= now && classesToSort[i].startTime >= now {
                        nextClass = classesToSort[i]
                        break
                    }
                }
            }
        }
        
        if let displayMode = extensionContext?.widgetActiveDisplayMode {
            if displayMode == NCWidgetDisplayMode.expanded {
                currentCourseView.isHidden = true
                noClassLabel.isHidden = true
                scheduleList.isHidden = false
                preferredContentSize = CGSize(width: maxSize?.width ?? scheduleList.frame.size.width, height: scheduleList.frame.maxY)
            } else if displayMode == NCWidgetDisplayMode.compact {
                scheduleList.isHidden = true
                
                if let thisClass = currentClass {
                    noClassLabel.isHidden = true
                    currentCourseView.isHidden = false
                    
                    currentCourseColorSwatch.colorValue = thisClass.course.color
                    currentCourseLabel.text = thisClass.course.longerName
                    currentClassTitleLabel.text = thisClass.title
                    
                    let today = Date()
                    let now = ClockTime(date: today)
                    
                    let timeRemaining = Int(thisClass.endTime.fixedToDate(today, overridingSeconds: true).timeIntervalSince(today))
                    let minutesRemaining = Int(floor(Double(timeRemaining) / 60.0))
                    let secondsRemaining = timeRemaining % 60
                    
                    var minutesString = ""
                    var secondsString = ""
                    
                    if minutesRemaining > 0 {
                        minutesString = "\(minutesRemaining) min"
                    }
                    
                    if secondsRemaining > 0 {
                        secondsString = "\(secondsRemaining) sec"
                    }
                    
                    if minutesString.isEmpty && secondsString.isEmpty {
                        timeRemainingLabel.text = "0 sec"
                    } else if !minutesString.isEmpty && !secondsString.isEmpty {
                        timeRemainingLabel.text = minutesString + " " + secondsString
                    } else if minutesString.isEmpty {
                        timeRemainingLabel.text = secondsString
                    } else if secondsString.isEmpty {
                        timeRemainingLabel.text = minutesString
                    }
                    
                    timeSpanLabel.text = "\(thisClass.startTime.stringValue) - \(thisClass.endTime.stringValue)"
                    
                    locationLabel.text = thisClass.location
                } else {
                    if let upcomingClass = nextClass {
                        noClassLabel.isHidden = true
                        currentCourseView.isHidden = false
                        
                        noClassLabel.isHidden = true
                        currentCourseView.isHidden = false
                        
                        currentCourseColorSwatch.colorValue = upcomingClass.course.color
                        currentCourseLabel.text = upcomingClass.course.longerName
                        currentClassTitleLabel.text = upcomingClass.title
                        
                        let today = Date()
                        let now = ClockTime(date: today)
                        
                        let timeRemaining = Int(upcomingClass.startTime.fixedToDate(today, overridingSeconds: true).timeIntervalSince(today))
                        var minutesRemaining = Int(floor(Double(timeRemaining) / 60))
                        let hoursRemaining = Int(floor(Double(minutesRemaining) / 60))
                        minutesRemaining -= 60 * hoursRemaining
                        let secondsRemaining = timeRemaining % 60
                        
                        var hoursString = ""
                        var minutesString = ""
                        var secondsString = ""
                        
                        if hoursRemaining > 0 {
                            hoursString = "\(hoursRemaining) h"
                        }
                        
                        if minutesRemaining > 0 {
                            minutesString = "\(minutesRemaining) min"
                        }
                        
                        if secondsRemaining > 0 {
                            secondsString = "\(secondsRemaining) sec"
                        }
                        
                        var strings: [String] = []
                        
                        for string in [hoursString, minutesString, secondsString] {
                            if !string.isEmpty {
                                strings.append(string)
                            }
                        }
                        
                        let timeString = strings.joined(separator: " ")
                        
                        if timeString.isEmpty {
                            timeRemainingLabel.text = "In 0 sec"
                        } else {
                            timeRemainingLabel.text = "In \(timeString)"
                        }
                        
                        timeSpanLabel.text = "\(upcomingClass.startTime.stringValue) - \(upcomingClass.endTime.stringValue)"
                        
                        locationLabel.text = upcomingClass.location
                    } else {
                        noClassLabel.isHidden = false
                        currentCourseView.isHidden = true
                    }
                }
            }
        }
    }
    
    // MARK: NCWidgetProviding
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        DataManager.shared.fetchDataFromCloud()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        updateInterface()
        
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            currentCourseView.sizeToFit()
            preferredContentSize = CGSize(width: maxSize.width, height: currentCourseView.intrinsicContentSize.height)
        } else if activeDisplayMode == NCWidgetDisplayMode.expanded {
            preferredContentSize = CGSize(width: maxSize.width, height: scheduleList.frame.size.height)
        }
    }
    
    // MARK: DMListener
    
    func handleLoadingEvent(_ eventType: DMLoadingEventType) {
        if eventType == .end {
            updateCurrentClass()
            updateData()
            updateInterface()
        }
    }
    
}

