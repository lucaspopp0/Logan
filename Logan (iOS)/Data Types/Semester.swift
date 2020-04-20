//
//  Semester.swift
//  Todo
//
//  Created by Lucas Popp on 12/22/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation

class Semester: BEObject {
    
    var name: String
    var startDate: CalendarDay
    var endDate: CalendarDay
    
    var courses: [Course] = []
    
    init(id: String, name: String, startDate: CalendarDay, endDate: CalendarDay) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
    
    init?(blob: Blob) {
        guard let sid = blob["sid"] as? String, let name = blob["name"] as? String, let startDate = blob["startDate"] as? String, let endDate = blob["endDate"] as? String else { return nil }
        
        self.id = sid
        self.name = name
    
        guard let startDay = CalendarDay(string: startDate), let endDay = CalendarDay(string: endDate) else { return nil }
        self.startDate = startDay
        self.endDate = endDay
    }
    
    override func jsonBlob() -> Blob {
        var blob = ["sid": id,
                    "name": name,
                    "startDate": startDate.stringValue,
                    "endDate": endDate.stringValue]
        
        if let user = DataManager.shared.currentUser {
            blob["uid"] = user.id
        }
        
        return blob
    }
    
}
