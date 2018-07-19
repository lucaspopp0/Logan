//
//  SingleEvent.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import CloudKit

class SingleEvent: Event {
    
    var date: CalendarDay = CalendarDay(date: Date()) {
        didSet {
            record["date"] = date.stringValue as CKRecordValue
        }
    }
    
    override init(record: CKRecord) {
        super.init(record: record)
        
        if let name = record["name"] as? String, let id = record["id"] as? Int, let startTimeString = record["startTime"] as? String, let endTimeString = record["endTime"] as? String, let dateString = record["date"] as? String {
            self.name = name
            self.ID = id
            
            if let location = record["location"] as? String {
                self.location = location
            }
            
            if let date = CalendarDay(string: dateString), let startTime = ClockTime(string: startTimeString), let endTime = ClockTime(string: endTimeString) {
                self.date = date
                self.startTime = startTime
                self.endTime = endTime
            }
        }
        
        Event.NEXT_SAVE_ID = max(self.ID + 1, Event.NEXT_SAVE_ID)
    }
    
    override init() {
        let tempRecord = CKRecord(recordType: "SingleEvent")
        tempRecord["name"] = "" as CKRecordValue
        tempRecord["id"] = Event.NEXT_SAVE_ID as CKRecordValue
        tempRecord["startTime"] = "" as CKRecordValue
        tempRecord["endTime"] = "" as CKRecordValue
        tempRecord["date"] = "" as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
}
