//
//  Exam.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import CloudKit

class Exam: CKEnabled {
    
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
    
    var date: CalendarDay! {
        didSet {
            record["date"] = date.stringValue as CKRecordValue
        }
    }
    
    var startTime: ClockTime! {
        didSet {
            record["startTime"] = startTime.stringValue as CKRecordValue
        }
    }
    
    var endTime: ClockTime! {
        didSet {
            record["endTime"] = endTime.stringValue as CKRecordValue
        }
    }
    
    override init(record: CKRecord) {
        super.init(record: record)
        
        if let title = record["title"] as? String, let id = record["id"] as? Int, let dateString = record["date"] as? String,
            let startTimeString = record["startTime"] as? String, let endTimeString = record["endTime"] as? String {
            
            self.title = title
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
        
        Exam.NEXT_SAVE_ID = max(self.ID + 1, Exam.NEXT_SAVE_ID)
    }
    
    init() {
        let tempRecord = CKRecord(recordType: "Exam")
        tempRecord["title"] = "" as CKRecordValue
        tempRecord["id"] = Class.NEXT_SAVE_ID as CKRecordValue
        tempRecord["date"] = "" as CKRecordValue
        tempRecord["startTime"] = "" as CKRecordValue
        tempRecord["endTime"] = "" as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
    func getValueForStorage() -> Any {
        var dict: [String: Any] = ["Title" : title,
                                   "Date" : date.dateValue ?? Date(),
                                   "Start Time" : startTime.dateValue ?? Date(),
                                   "End Time" : endTime.dateValue ?? Date(),
                                   "ID" : ID]
        
        if location != nil {
            dict["Location"] = location!
        }
        
        return dict
    }
    
}

