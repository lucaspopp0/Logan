//
//  Assignment.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation
import CloudKit

class Assignment: CKEnabled {
    
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
    
    var dueDate: DueDate = DueDate.specificDeadline(deadline: BetterDate(date: Date())) {
        didSet {
            record["dueDateType"] = dueDate.intValue as CKRecordValue
            
            switch dueDate {
            case .specificDay(let day):
                record["optionalSpecificDueDate"] = day.stringValue as CKRecordValue
                break
            case .specificDeadline(let deadline):
                record["optionalSpecificDueDate"] = deadline.stringValue as CKRecordValue
                break
            default: break
            }
        }
    }
    
    var userDescription: String = "" {
        didSet {
            record["userDescription"] = userDescription as CKRecordValue
        }
    }
    
    var commitment: (Commitment & CKEnabled)? {
        didSet {
            if commitment != nil {
                record["commitment"] = CKReference(record: commitment!.record, action: CKReferenceAction.none) as CKRecordValue
            } else {
                record["commitment"] = nil
            }
        }
    }
    
    var reminders: [Reminder] = [] {
        didSet {
            var references: [CKReference] = []
            
            for reminder in reminders {
                references.append(CKReference(record: reminder.record, action: CKReferenceAction.none))
            }
            
            record["reminders"] = references as CKRecordValue
        }
    }
    
    var files: [File] = []
    
    init(record: CKRecord, reminders: [Reminder]) {
        super.init(record: record)
        
        if let title = record["title"] as? String, let userDescription = record["userDescription"] as? String, let dueDateType = record["dueDateType"] as? Int, let id = record["id"] as? Int {
            self.title = title
            self.userDescription = userDescription
            self.ID = id
            
            if let reminderReferences = record["reminders"] as? [CKReference] {
                for reference in reminderReferences {
                    for reminder in reminders {
                        if reference.recordID.isEqual(reminder.record.recordID) {
                            self.reminders.append(reminder)
                            reminder.assignment = self
                            break
                        }
                    }
                }
                
                sortReminders()
            }
            
            switch dueDateType {
                
            case 0:
                dueDate = DueDate.eventually
                break
                
            case 1:
                dueDate = DueDate.asap
                break
                
            default:
                if let specificDateString = record["optionalSpecificDueDate"] as? String {
                    
                    if dueDateType == 3, let specificDay = CalendarDay(string: specificDateString) {
                        dueDate = DueDate.specificDay(day: specificDay)
                    } else if dueDateType == 4, let specificDeadline = BetterDate(string: specificDateString) {
                        dueDate = DueDate.specificDeadline(deadline: specificDeadline)
                    }
                    
                }
                break
                
            }
            
            Assignment.NEXT_SAVE_ID = max(self.ID + 1, Assignment.NEXT_SAVE_ID)
            
            if let commitmentReference = record["commitment"] as? CKReference {
                var commitmentFound: Bool = false
                for semester in DataManager.shared.semesters {
                    for course in semester.courses {
                        if commitmentReference.recordID.isEqual(course.record.recordID) {
                            self.commitment = course
                            
                            commitmentFound = true
                            break
                        }
                    }
                    
                    if commitmentFound {
                        break
                    }
                }
                
                if !commitmentFound {
                    for extracurricular in DataManager.shared.extracurriculars {
                        if commitmentReference.recordID.isEqual(extracurricular.record.recordID) {
                            self.commitment = extracurricular
                            break
                        }
                    }
                }
            }
        }
    }
    
    init() {
        let tempRecord = CKRecord(recordType: "Assignment")
        tempRecord["title"] = "" as CKRecordValue
        tempRecord["userDescription"] = "" as CKRecordValue
        tempRecord["dueDateType"] = 0 as CKRecordValue
        tempRecord["id"] = Assignment.NEXT_SAVE_ID as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
    func sortReminders() {
        reminders = reminders.sorted(by: { (reminder1, reminder2) -> Bool in
            return reminder1.triggerDate.dateValue! > reminder2.triggerDate.dateValue!
        })
    }
    
}
