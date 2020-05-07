//
//  Semester.swift
//  Todo
//
//  Created by Lucas Popp on 12/22/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation

class Semester: BEObject {
    
    override var idKey: String { return "sid" }
    
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
    
    override init?(blob: Blob) {
        guard let sid = blob["sid"] as? String,
            let name = blob["name"] as? String,
            let startDate = blob["startDate"] as? String,
            let endDate = blob["endDate"] as? String
            else { return nil }
        
        guard let startDay = CalendarDay(stringValue: startDate, format: API.DB_DATE_FORMAT),
            let endDay = CalendarDay(stringValue: endDate, format: API.DB_DATE_FORMAT)
            else { return nil }
            
        self.id = sid
        self.name = name
        self.startDate = startDay
        self.endDate = endDay
    }
    
    override func jsonBlob() -> Blob {
        var blob = super.jsonBlob()
        blob["sid"] = id
        blob["name"] = name
        blob["startDate"] = startDate.format(API.DB_DATE_FORMAT)
        blob["endDate"] = endDate.format(API.DB_DATE_FORMAT)
        
        return blob
    }
    
}
