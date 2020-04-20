//
//  Class.swift
//  Todo
//
//  Created by Lucas Popp on 10/20/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import CloudKit

class Section: CKEnabled {
    
    static var NEXT_SAVE_ID: Int = 0
    var ID: Int = 0 {
        didSet {
            record["id"] = ID as CKRecordValue
        }
    }
    
    var title: String = "" {
        didSet {
            record["title"] = title as CKRecordValue
        }
    }
    
    var course: Course!
    
    var location: String? {
        didSet {
            if location != nil {
                record["location"] = location! as CKRecordValue
            } else {
                record["location"] = nil
            }
        }
    }
    
    var weeklyRepeat: Int = 1 {
        didSet {
            record["weeklyRepeat"] = weeklyRepeat as CKRecordValue
        }
    }
    
    var daysOfWeek: [DayOfWeek] = [] {
        didSet {
            var raw: [Int] = []
            
            for day in daysOfWeek {
                raw.append(day.rawValue)
            }
            
            record["daysOfWeek"] = raw as CKRecordValue
        }
    }
    
    var startDate: CalendarDay = CalendarDay(date: Date()) {
        didSet {
            record["startDate"] = startDate.stringValue as CKRecordValue
        }
    }
    
    var endDate: CalendarDay = CalendarDay(date: Date()) {
        didSet {
            record["endDate"] = endDate.stringValue as CKRecordValue
        }
    }
    
    var startTime: ClockTime = ClockTime(date: Date()) {
        didSet {
            record["startTime"] = startTime.stringValue as CKRecordValue
        }
    }
    
    var endTime: ClockTime = ClockTime(date: Date()) {
        didSet {
            record["endTime"] = endTime.stringValue as CKRecordValue
        }
    }
    
    override init(record: CKRecord) {
        super.init(record: record)
        
        if let title = record["title"] as? String, let weeklyRepeat = record["weeklyRepeat"] as? Int, let daysOfWeek = record["daysOfWeek"] as? [Int], let id = record["id"] as? Int,
            let startDateString = record["startDate"] as? String, let endDateString = record["endDate"] as? String, let startTimeString = record["startTime"] as? String, let endTimeString = record["endTime"] as? String {
            
            self.title = title
            self.ID = id
            self.weeklyRepeat = weeklyRepeat
            
            if let location = record["location"] as? String {
                self.location = location
            }
            
            if let startDate = CalendarDay(string: startDateString), let endDate = CalendarDay(string: endDateString), let startTime = ClockTime(string: startTimeString), let endTime = ClockTime(string: endTimeString) {
                self.startDate = startDate
                self.endDate = endDate
                self.startTime = startTime
                self.endTime = endTime
            }
            
            for raw in daysOfWeek {
                if let day = DayOfWeek(rawValue: raw) {
                    self.daysOfWeek.append(day)
                }
            }
        }
        
        Section.NEXT_SAVE_ID = max(self.ID + 1, Section.NEXT_SAVE_ID)
    }
    
    init() {
        let tempRecord = CKRecord(recordType: "Class")
        tempRecord["title"] = "" as CKRecordValue
        tempRecord["weeklyRepeat"] = 1 as CKRecordValue
        tempRecord["daysOfWeek"] = [Int]() as CKRecordValue
        tempRecord["id"] = Section.NEXT_SAVE_ID as CKRecordValue
        tempRecord["startDate"] = "" as CKRecordValue
        tempRecord["endDate"] = "" as CKRecordValue
        tempRecord["startTime"] = "" as CKRecordValue
        tempRecord["endTime"] = "" as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
    func getValueForStorage() -> Any {
        var dict: [String: Any] = ["Title" : title,
                                   "Repeat" : weeklyRepeat,
                                   "Start Date" : startDate.dateValue ?? Date(),
                                   "Start Time" : startTime.dateValue ?? Date(),
                                   "End Date" : endDate.dateValue ?? Date(),
                                   "End Time" : endTime.dateValue ?? Date(),
                                   "ID" : ID]
        
        if location != nil {
            dict["Location"] = location!
        }
        
        var dotw: [Int] = []
        
        for day in daysOfWeek {
            dotw.append(day.rawValue)
        }
        
        dict["Days of Week"] = dotw
        
        return dict
    }
    
}
