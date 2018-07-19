//
//  Semester.swift
//  Todo
//
//  Created by Lucas Popp on 12/22/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation
import CloudKit

class Semester: CKEnabled {
    
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
    
    var courses: [Course] = [] {
        didSet {
            var references: [CKReference] = []
            
            for course in courses {
                references.append(CKReference(record: course.record, action: CKReferenceAction.none))
            }
            
            record["courses"] = references as CKRecordValue
        }
    }
    
    init(record: CKRecord, courses: [Course]) {
        super.init(record: record)
        
        if let name = record["name"] as? String, let startString = record["startDate"] as? String, let endString = record["endDate"] as? String, let id = record["id"] as? Int {
            self.name = name
            self.ID = id
            
            if let startDate = CalendarDay(string: startString), let endDate = CalendarDay(string: endString) {
                self.startDate = startDate
                self.endDate = endDate
            }
            
            if let courseReferences = record["courses"] as? [CKReference] {
                for reference in courseReferences {
                    for course in courses {
                        if reference.recordID.isEqual(course.record.recordID) {
                            self.courses.append(course)
                            break
                        }
                    }
                }
            }
            
            Semester.NEXT_SAVE_ID = max(self.ID + 1, Semester.NEXT_SAVE_ID)
        }
    }
    
    convenience init(name: String, startDate: CalendarDay, endDate: CalendarDay) {
        let tempRecord = CKRecord(recordType: "Semester")
        tempRecord["name"] = name as CKRecordValue
        tempRecord["startDate"] = startDate.stringValue as CKRecordValue
        tempRecord["endDate"] = endDate.stringValue as CKRecordValue
        tempRecord["id"] = Semester.NEXT_SAVE_ID as CKRecordValue
        
        self.init(record: tempRecord, courses: [])
    }
    
    func getValueForStorage() -> Any {
        var dict: [String: Any] = ["Name" : name,
                                   "Start Date" : startDate.dateValue ?? Date(),
                                   "End Date" : endDate.dateValue ?? Date(),
                                   "ID" : ID]
        
        var storableCourses: [Any] = []
        
        for course in courses {
            storableCourses.append(course.getValueForStorage())
        }
        
        dict["Courses"] = storableCourses
        
        return dict
    }
    
}
