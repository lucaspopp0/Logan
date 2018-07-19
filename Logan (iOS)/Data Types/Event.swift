//
//  Event.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import CloudKit

class Event: CKEnabled {
    
    static var NEXT_SAVE_ID: Int = 0
    var ID: Int = 0 {
        didSet {
            record["id"] = ID as CKRecordValue
        }
    }
    
    var name: String = "" {
        didSet {
            record["name"] = name as CKRecordValue
        }
    }
    
    var extracurricular: Extracurricular!
    
    var location: String? {
        didSet {
            if location != nil {
                record["location"] = location! as CKRecordValue
            } else {
                record["location"] = nil
            }
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
        
        if let name = record["name"] as? String, let id = record["id"] as? Int, let startTimeString = record["startTime"] as? String, let endTimeString = record["endTime"] as? String {
            self.name = name
            self.ID = id
            
            if let location = record["location"] as? String {
                self.location = location
            }
            
            if let startTime = ClockTime(string: startTimeString), let endTime = ClockTime(string: endTimeString) {
                self.startTime = startTime
                self.endTime = endTime
            }
        }
        
        Event.NEXT_SAVE_ID = max(self.ID + 1, Event.NEXT_SAVE_ID)
    }
    
    init() {
        let tempRecord = CKRecord(recordType: "Event")
        tempRecord["name"] = "" as CKRecordValue
        tempRecord["id"] = Event.NEXT_SAVE_ID as CKRecordValue
        tempRecord["startTime"] = "" as CKRecordValue
        tempRecord["endTime"] = "" as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
}
