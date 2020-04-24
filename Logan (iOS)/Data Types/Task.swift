//
//  Task.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation
import CloudKit

class Task: BEObject {
    
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
    
    var userDescription: String = "" {
        didSet {
            record["userDescription"] = userDescription as CKRecordValue
        }
    }
    
    var completed: Bool = false {
        didSet {
            record["completed"] = (completed ? 1 : 0) as CKRecordValue
            
            if completed {
                completionDate = CalendarDay(date: Date())
            }
        }
    }
    
    var completionDate: CalendarDay? {
        didSet {
            if completionDate == nil {
                record["completionDate"] = "" as CKRecordValue
            } else {
                record["completionDate"] = completionDate!.stringValue as CKRecordValue
            }
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
    
    var dueDate: DueDate = DueDate.eventually {
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
    
    var isOverdue: Bool {
        get {
            if case let DueDate.specificDay(day) = dueDate {
                return Date.daysBetween(Date(), and: day.dateValue!) < 0
            }
            
            return false
        }
    }
    
    var priority: Priority = Priority.normal {
        didSet {
            record["priority"] = priority.rawValue as CKRecordValue
        }
    }
    
    
    var relatedAssignment: Assignment? {
        didSet {
            if relatedAssignment != nil {
                record["relatedAssignment"] = CKReference(record: relatedAssignment!.record, action: CKReferenceAction.none) as CKRecordValue
            } else {
                record["relatedAssignment"] = nil
            }
        }
    }
    
    var tags: [String] = []
    
    init(record: CKRecord, assignments: [Assignment]? = nil, semesters: [Semester]? = nil, extracurriculars: [Extracurricular]? = nil) {
        super.init(record: record)
        
        if let title = record["title"] as? String, let userDescription = record["userDescription"] as? String, let intCompleted = record["completed"] as? Int, let dueDateType = record["dueDateType"] as? Int, let rawPriority = record["priority"] as? Int, let id = record["id"] as? Int {
            self.title = title
            self.userDescription = userDescription
            self.completed = (intCompleted == 1)
            self.priority = Priority(rawValue: rawPriority) ?? Priority.normal
            self.ID = id
            
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
            
            if self.completed {
                if let completionDateString = record["completionDate"] as? String {
                    if !completionDateString.isEmpty, let completionDate = CalendarDay(string: completionDateString) {
                        self.completionDate = completionDate
                    }
                } else {
                    self.completionDate = CalendarDay(date: record.modificationDate!)
                }
            } else {
                self.completionDate = nil
            }
            
            if let commitmentReference = record["commitment"] as? CKReference {
                var commitmentFound: Bool = false
                for semester in semesters ?? DataManager.shared.semesters {
                    for course in semester.courses {
                        if commitmentReference.recordID.isEqual(course.record.recordID) {
                            commitment = course
                            
                            commitmentFound = true
                            break
                        }
                    }
                    
                    if commitmentFound {
                        break
                    }
                }
                
                if !commitmentFound {
                    for extracurricular in extracurriculars ?? DataManager.shared.extracurriculars {
                        if commitmentReference.recordID.isEqual(extracurricular.record.recordID) {
                            commitment = extracurricular
                            break
                        }
                    }
                }
            }
            
            if let relatedAssignmentReference = record["relatedAssignment"] as? CKReference {
                for assignment in assignments ?? DataManager.shared.assignments {
                    if assignment.record.recordID.isEqual(relatedAssignmentReference.recordID) {
                        relatedAssignment = assignment
                        break
                    }
                }
            }
            
            Task.NEXT_SAVE_ID = max(self.ID + 1, Task.NEXT_SAVE_ID)
        }
    }
    
    convenience init() {
        let tempRecord = CKRecord(recordType: "Task")
        tempRecord["title"] = "" as CKRecordValue
        tempRecord["userDescription"] = "" as CKRecordValue
        tempRecord["dueDateType"] = DueDate.specificDay(day: CalendarDay(date: Date())).intValue as CKRecordValue
        tempRecord["optionalSpecificDueDate"] = CalendarDay(date: Date()).stringValue as CKRecordValue
        tempRecord["completed"] = 0 as CKRecordValue
        tempRecord["priority"] = Priority.normal.rawValue as CKRecordValue
        tempRecord["id"] = Task.NEXT_SAVE_ID as CKRecordValue
        
        self.init(record: tempRecord)
    }
    
}
