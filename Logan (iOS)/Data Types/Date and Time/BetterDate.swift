//
//  BetterDate.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

func == (_ left: BetterDate, _ right: BetterDate) -> Bool {
    return left.day == right.day && left.time == right.time
}

func < (_ left: BetterDate, _ right: BetterDate) -> Bool {
    return left.day < right.day || (left.day == right.day && left.time < right.time)
}

func <= (_ left: BetterDate, _ right: BetterDate) -> Bool {
    return left.day < right.day || (left.day == right.day && left.time <= right.time)
}

func > (_ left: BetterDate, _ right: BetterDate) -> Bool {
    return left.day > right.day || (left.day == right.day && left.time > right.time)
}

func >= (_ left: BetterDate, _ right: BetterDate) -> Bool {
    return left.day > right.day || (left.day == right.day && left.time >= right.time)
}

class BetterDate {
    
    var day: CalendarDay
    var time: ClockTime
    
    var dateValue: Date? {
        get {
            let calendar = Calendar.autoupdatingCurrent
            var components = calendar.dateComponents([Calendar.Component.month, Calendar.Component.day, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute], from: Date())
            
            components.month = day.month
            components.day = day.day
            components.year = day.year
            
            if time.ampm == .am {
                components.hour = time.hour
            } else {
                components.hour = time.hour + 12
            }
            
            components.minute = time.minute
            
            return calendar.date(from: components)
        }
    }
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
        
        if dateValue != nil {
            return formatter.string(from: dateValue!)
        } else {
            return formatter.string(from: Date())
        }
    }
    
    init(date: Date) {
        day = CalendarDay(date: date)
        time = ClockTime(date: date)
    }
    
    init(day: CalendarDay, time: ClockTime) {
        self.day = day
        self.time = time
    }
    
    init?(month: Int, day: Int, year: Int, hour: Int, minute: Int, ampm: ClockTime.AmPm) {
        if let calendarDay = CalendarDay(month: month, day: day, year: year), let clockTime = ClockTime(hour: hour, minute: minute, ampm: ampm) {
            self.day = calendarDay
            self.time = clockTime
        } else {
            return nil
        }
    }
    
    convenience init?(string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:m a"
        
        if let date = formatter.date(from: string) {
            self.init(date: date)
        } else {
            return nil
        }
    }
    
}
