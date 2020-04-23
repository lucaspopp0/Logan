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

class CalendarDay: DatetimeValue {
    
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
    
    required init(date: Date) {
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
    
    required init?(stringValue dateString: String, format formatString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        guard let formattedDate = formatter.date(from: dateString) else { return nil }
        month = Calendar.autoupdatingCurrent.component(.month, from: formattedDate)
        day = Calendar.autoupdatingCurrent.component(.day, from: formattedDate)
        year = Calendar.autoupdatingCurrent.component(.year, from: formattedDate)
    }
    
    func format(_ formatString: String) -> String! {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        guard let dateValue = dateValue else { return nil }
        return formatter.string(from: dateValue)
    }
    
}
