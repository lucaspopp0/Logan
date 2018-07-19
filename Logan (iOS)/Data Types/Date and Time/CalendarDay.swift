//
//  CalendarDay.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

func == (_ left: CalendarDay, _ right: CalendarDay) -> Bool {
    return (left.month == right.month && left.day == right.day && left.year == right.year)
}

func != (_ left: CalendarDay, _ right: CalendarDay) -> Bool {
    return !(left == right)
}

func < (_ left: CalendarDay, _ right: CalendarDay) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 < rightDate.timeIntervalSince1970
    }
    
    return false
}

func <= (_ left: CalendarDay, _ right: CalendarDay) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 <= rightDate.timeIntervalSince1970
    }
    
    return false
}

func > (_ left: CalendarDay, _ right: CalendarDay) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 > rightDate.timeIntervalSince1970
    }
    
    return false
}

func >= (_ left: CalendarDay, _ right: CalendarDay) -> Bool {
    if let leftDate = left.dateValue, let rightDate = right.dateValue {
        return leftDate.timeIntervalSince1970 >= rightDate.timeIntervalSince1970
    }
    
    return false
}

class CalendarDay {
    
    var month: Int
    var day: Int
    var year: Int
    
    static var today: CalendarDay {
        get {
            return CalendarDay(date: Date())
        }
    }
    
    var dateValue: Date? {
        get {
            let calendar = Calendar.autoupdatingCurrent
            var components = calendar.dateComponents([Calendar.Component.month, Calendar.Component.day, Calendar.Component.year], from: Date())
            components.month = month
            components.day = day
            components.year = year
            
            return calendar.date(from: components)
        }
    }
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        
        if dateValue != nil {
            return formatter.string(from: dateValue!)
        } else {
            return formatter.string(from: Date())
        }
    }
    
    init(date: Date) {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([Calendar.Component.month, Calendar.Component.day, Calendar.Component.year], from: date)
        month = components.month!
        day = components.day!
        year = components.year!
    }
    
    init?(month: Int, day: Int, year: Int) {
        let calendar = Calendar.autoupdatingCurrent
        var components = calendar.dateComponents([Calendar.Component.month, Calendar.Component.day, Calendar.Component.year], from: Date())
        components.month = month
        components.day = day
        components.year = year
        
        if calendar.date(from: components) != nil {
            self.month = month
            self.day = day
            self.year = year
        } else {
            return nil
        }
    }
    
    convenience init?(string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy"
        
        if let date = formatter.date(from: string) {
            self.init(date: date)
        } else {
            return nil
        }
    }
    
}
