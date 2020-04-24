//
//  Task.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation

class Task: BEObject {
    
    var title: String
    var dueDate: DueDate
    var completed: Bool
    var priority: Priority
    
    var userDescription: String?
    var completionDate: CalendarDay?
    var course: Course?
    var relatedAssignment: Assignment?
    
    var associatedCourse: Course? {
        get {
            return relatedAssignment?.course ?? course
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
    
    init?(id: String, title: String, dueDate: DueDate, completed: Bool, priority: Priority, description: String?, completionDate: CalendarDay?, course: Course?, relatedAssignment: Assignment?) {
        if completed && completionDate == nil { return nil }
        
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.completed = completed
        self.userDescription = description
        self.completionDate = completionDate
        self.course = course
        self.relatedAssignment = relatedAssignment
    }
    
    override init?(blob: Blob) {
        guard let tid = blob["tid"] as? String,
            let title = blob["title"] as? String,
            let dueDateString = blob["dueDate"] as? String,
            let completed = blob["completed"] as? Bool,
            let priorityValue = blob["priority"] as? Int
            else { return nil }
        
        guard let dueDate = DueDate.fromString(dueDateString),
            let priority = Priority(rawValue: priorityValue)
            else { return nil }
        
        var completionDate: CalendarDay?
        if let completionDateString = blob["completionDate"] as? String {
            completionDate = CalendarDay(stringValue: completionDateString, format: API.DB_DATE_FORMAT)
        }
        
        if completed && completionDate == nil { return nil }
        
        self.id = tid
        self.title = title
        self.dueDate = dueDate
        self.completed = completed
        self.priority = priority
        self.userDescription = blob["description"] as? String
        self.completionDate = completionDate
    }
    
    override func jsonBlob() -> Blob {
        var blob = super.jsonBlob()
        blob["tid"] = id
        blob["title"] = title
        blob["dueDate"] = dueDate.dbValue
        blob["completed"] = completed
        blob["priority"] = priority.rawValue
        
        if userDescription != nil { blob["description"] = userDescription! }
        if completionDate != nil { blob["completionDate"] = completionDate! }
        if relatedAssignment != nil { blob["relatedAid"] = relatedAssignment!.id }
        if course != nil { blob["commitmentId"] = course!.id }
        
        return blob
    }
    
}
