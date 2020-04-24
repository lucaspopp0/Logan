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
    var daysOfWeek: [DayOfWeek]
    var weeklyRepeat: Int
    
    var location: String?
    
    var course: Course!
    
    init(id: String, name: String, startDate: CalendarDay, startTime: ClockTime, endDate: CalendarDay, endTime: ClockTime, daysOfWeek: [DayOfWeek], location: String?, weeklyRepeat: Int, course: Course) {
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
    
    override init?(blob: Blob) {
        guard let secid = blob["secid"] as? String,
            let name = blob["name"] as? String,
            let startString = blob["start"] as? String,
            let endString = blob["end"] as? String,
            let weeklyRepeat = blob["weeklyRepeat"] as? Int,
            let dowString = blob["daysOfWeek"] as? String
            else { return nil }
        
        guard let start = BetterDate(stringValue: startString, format: API.DB_DATETIME_FORMAT),
            let end = BetterDate(stringValue: endString, format: API.DB_DATETIME_FORMAT),
            let daysOfWeek = DayOfWeek.arrayFromString(dowString)
            else { return nil }
            
        self.id = secid
        self.name = name
        self.weeklyRepeat = weeklyRepeat
        self.location = blob["location"] as? String
        self.startDate = start.day
        self.startTime = start.time
        self.endDate = end.day
        self.endTime = end.time
        self.daysOfWeek = daysOfWeek
    }
    
    override func jsonBlob() -> Blob {
        var blob = super.jsonBlob()
        blob["secid"] = id
        blob["cid"] = course.id
        blob["name"] = name
        blob["start"] = BetterDate(day: startDate, time: startTime).format(API.DB_DATETIME_FORMAT)
        blob["end"] = BetterDate(day: endDate, time: endTime).format(API.DB_DATETIME_FORMAT)
        blob["daysOfWeek"] = daysOfWeek.map { $0.rawValue }
        blob["weeklyRepeat"] = weeklyRepeat
        
        if location != nil { blob["location"] = location! }
        
        return blob
    }
    
    func occursOnDay(_ date: Date) -> Bool {
        let day = CalendarDay(date: date)
        
        guard startDate <= day && day <= endDate
            else { return false }
        
        guard let weekDay = date.weekday, let dayOfWeek = DayOfWeek(rawValue: weekDay), daysOfWeek.contains(dayOfWeek)
            else { return false }
        
        let weeksSinceStart = Int(floor(Double((day.dateValue!.timeIntervalSince1970 - startDate.dateValue!.timeIntervalSince1970)) / (7 * 24 * 60 * 60)))
        
        return weeksSinceStart % weeklyRepeat == 0
    }
    
}
