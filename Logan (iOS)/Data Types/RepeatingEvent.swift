//
//  RepeatingEvent.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import CloudKit

class RepeatingEvent: Event {
    
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
    
    override init(record: CKRecord) {
        super.init(record: record)
        
        if let name = record["name"] as? String, let id = record["id"] as? Int, let startTimeString = record["startTime"] as? String, let endTimeString = record["endTime"] as? String,
            let weeklyRepeat = record["weeklyRepeat"] as? Int, let daysOfWeek = record["daysOfWeek"] as? [Int], let startDateString = record["startDate"] as? String, let endDateString = record["endDate"] as? String {
            self.name = name
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
        
        Event.NEXT_SAVE_ID = max(self.ID + 1, Event.NEXT_SAVE_ID)
    }
    
    override init() {
        let tempRecord = CKRecord(recordType: "RepeatingEvent")
        tempRecord["name"] = "" as CKRecordValue
        tempRecord["weeklyRepeat"] = 1 as CKRecordValue
        tempRecord["daysOfWeek"] = [Int]() as CKRecordValue
        tempRecord["id"] = Event.NEXT_SAVE_ID as CKRecordValue
        tempRecord["startDate"] = "" as CKRecordValue
        tempRecord["endDate"] = "" as CKRecordValue
        tempRecord["startTime"] = "" as CKRecordValue
        tempRecord["endTime"] = "" as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
}
