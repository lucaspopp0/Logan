//
//  Class.swift
//  Todo
//
//  Created by Lucas Popp on 10/20/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation

class Section: BEObject {
    
    var name: String
    var startDate: CalendarDay
    var startTime: ClockTime
    var endDate: CalendarDay
    var endTime: ClockTime
    var daysOfWeek: [DayOfWeek]!
    
    var location: String?
    var weeklyRepeat: Int?
    
    var course: Course!
    
    init(id: String, name: String, startDate: CalendarDay, startTime: ClockTime, endDate: CalendarDay, endTime: ClockTime, daysOfWeek: [DayOfWeek], location: String?, weeklyRepeat: Int?, course: Course) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.startTime = startTime
        self.endDate = endDate
        self.endTime = endTime
        self.daysOfWeek = daysOfWeek
        self.location = location
        self.weeklyRepeat = weeklyRepeat
        self.course = course
    }
    
    init?(blob: Blob) {
        guard let secid = blob["secid"] as? String,
            let name = blob["name"] as? String,
            let startString = blob["start"] as? String,
            let endString = blob["end"] as? String
            else { return nil }
        
        self.id = secid
        self.name = name
        self.location = blob["location"] as? String
        self.weeklyRepeat = blob["weeklyRepeat"] as? Int
        
        guard let start = BetterDate(stringValue: startString, format: API.DB_DATETIME_FORMAT),
            let end = BetterDate(stringValue: endString, format: API.DB_DATETIME_FORMAT)
            else { return nil }
        
        startDate = start.day
        startTime = start.time
        endDate = end.day
        endTime = end.time
        
        if let dowString = blob["daysOfWeek"] as? String, let daysOfWeek = DayOfWeek.arrayFromString(dowString) {
            self.daysOfWeek = daysOfWeek
        }
    }
    
    override func jsonBlob() -> Blob {
        var blob = super.jsonBlob()
        blob["secid"] = id
        blob["cid"] = course.id
        blob["name"] = name
        blob["start"] = BetterDate(day: startDate, time: startTime).format(API.DB_DATETIME_FORMAT)
        blob["end"] = BetterDate(day: endDate, time: endTime).format(API.DB_DATETIME_FORMAT)
        
        if let location = location { blob["location"] = location }
        if let weeklyRepeat = weeklyRepeat { blob["weeklyRepeat"] = weeklyRepeat }
    }
    
}
