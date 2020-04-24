//
//  Assignment.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation

class Assignment: BEObject {
    
    var title: String
    var dueDate: DueDate
    var userDescription: String?
    var course: Course?
    
    init(id: String, title: String, dueDate: DueDate, userDescription: String?, course: Course?) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.userDescription = userDescription
        self.course = course
    }
    
    override init?(blob: Blob) {
        guard let aid = blob["aid"] as? String,
            let title = blob["title"] as? String,
            let dueDateString = blob["dueDate"] as? String
            else { return nil }
        
        guard let dueDate = DueDate.fromString(dueDateString)
            else { return nil }
        
        self.id = aid
        self.title = title
        self.dueDate = dueDate
        self.userDescription = blob["description"] as? String
    }
    
    override func jsonBlob() -> Blob {
        var blob = super.jsonBlob()
        blob["aid"] = id
        blob["title"] = title
        blob["dueDate"] = dueDate.dbValue
        
        if userDescription != nil { blob["description"] = userDescription! }
        if course != nil { blob["commitmentId"] = course!.id }
        
        return blob
    }
    
}
