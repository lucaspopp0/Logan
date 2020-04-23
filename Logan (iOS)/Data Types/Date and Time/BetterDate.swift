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

class BetterDate: DatetimeValue {
        
    var day: CalendarDay
    var time: ClockTime
    
    var dateValue: Date! {
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
    
    required init(date: Date) {
        day = CalendarDay(date: date)
        time = ClockTime(date: date)
    }
    
    init(day: CalendarDay, time: ClockTime) {
        self.day = day
        self.time = time
    }
    
    required init?(stringValue dateString: String, format formatString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        guard let formattedDate = formatter.date(from: dateString) else { return nil }
        day = CalendarDay(date: formattedDate)
        time = ClockTime(date: formattedDate)
    }
    
    func format(_ formatString: String) -> String! {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        guard let dateValue = dateValue else { return nil }
        return formatter.string(from: dateValue)
    }
    
}
