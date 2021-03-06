//
//  ClockTime.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

func == (_ left: ClockTime, _ right: ClockTime) -> Bool {
    return left.hour == right.hour && left.minute == right.minute && left.ampm == right.ampm
}

func < (_ left: ClockTime, _ right: ClockTime) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 < rightDate.timeIntervalSince1970
    }
    
    return false
}

func <= (_ left: ClockTime, _ right: ClockTime) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 <= rightDate.timeIntervalSince1970
    }
    
    return false
}

func > (_ left: ClockTime, _ right: ClockTime) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 > rightDate.timeIntervalSince1970
    }
    
    return false
}

func >= (_ left: ClockTime, _ right: ClockTime) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 >= rightDate.timeIntervalSince1970
    }
    
    return false
}

class ClockTime {
    
    enum AmPm: Int {
        
        case am = 0
        case pm = 1
        
    }
    
    var hour: Int
    var minute: Int
    var ampm: AmPm
    
    var dateValue: Date? {
        get {
            let calendar = Calendar.autoupdatingCurrent
            var components = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: Date(timeIntervalSince1970: 0))
            
            if ampm == .am {
                components.hour = hour
            } else {
                components.hour = hour + 12
            }
            
            components.minute = minute
            
            return calendar.date(from: components)
        }
    }
    
    var stringValue: String {
        return String(format: "%d:%02d %@", hour == 0 ? 12 : hour, minute, ampm.rawValue == 0 ? "AM" : "PM")
    }
    
    init(date: Date) {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: date)
        hour = components.hour!
        minute = components.minute!
        
        if hour >= 12 {
            ampm = .pm
            hour -= 12
        } else {
            ampm = .am
        }
    }
    
    init?(hour: Int, minute: Int, ampm: AmPm) {
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: Date())
        
        if ampm == .am {
            components.hour = hour
        } else {
            components.hour = hour + 12
        }
        
        components.minute = minute
        
        if calendar.date(from: components) != nil {
            self.hour = hour
            self.minute = minute
            self.ampm = ampm
        } else {
            return nil
        }
    }
    
    convenience init?(string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:m a"
        
        if let date = formatter.date(from: string) {
            self.init(date: date)
        } else {
            return nil
        }
    }
    
    func fixedToDate(_ date: Date, overridingSeconds: Bool = true) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.second], from: date)
        
        if ampm == .am {
            components.hour = hour
        } else {
            components.hour = hour + 12
        }
        
        components.minute = minute
        
        if overridingSeconds {
            components.second = 0
        }
        
        return calendar.date(from: components)!
    }
    
    static func secondsBetween(_ time1: ClockTime, and time2: ClockTime) -> Int {
        let newTime1 = ClockTime(string: time1.stringValue)!
        let newTime2 = ClockTime(string: time2.stringValue)!
        let date1 = newTime1.dateValue!
        let date2 = newTime2.dateValue!
        
        return Int(abs(date1.timeIntervalSince(date2)))
    }
    
}
