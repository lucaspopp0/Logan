//
//  DayOfWeek.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

// An enum representing a weekday
enum DayOfWeek: Int {
    
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    func shortName() -> String {
        switch self {
        case DayOfWeek.sunday:
            return "Sun"
        case DayOfWeek.monday:
            return "Mon"
        case DayOfWeek.tuesday:
            return "Tue"
        case DayOfWeek.wednesday:
            return "Wed"
        case DayOfWeek.thursday:
            return "Thu"
        case DayOfWeek.friday:
            return "Fri"
        case DayOfWeek.saturday:
            return "Sat"
        }
    }
    
    func longName() -> String {
        switch self {
        case DayOfWeek.sunday:
            return "Sunday"
        case DayOfWeek.monday:
            return "Monday"
        case DayOfWeek.tuesday:
            return "Tuesday"
        case DayOfWeek.wednesday:
            return "Wednesday"
        case DayOfWeek.thursday:
            return "Thursday"
        case DayOfWeek.friday:
            return "Friday"
        case DayOfWeek.saturday:
            return "Saturday"
        }
    }
    
    static func current() -> DayOfWeek {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([Calendar.Component.weekday], from: Date())
        return DayOfWeek.all()[components.weekday! - 1]
    }
    
    static func forDate(_ date: Date) -> DayOfWeek {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([Calendar.Component.weekday], from: date)
        return DayOfWeek.all()[components.weekday! - 1]
    }
    
    static func all() -> [DayOfWeek] {
        return [DayOfWeek.sunday, DayOfWeek.monday, DayOfWeek.tuesday, DayOfWeek.wednesday, DayOfWeek.thursday, DayOfWeek.friday, DayOfWeek.saturday]
    }
    
    static func arrayFromString(_ str: String) -> [DayOfWeek]? {
        var days: [DayOfWeek] = []
        
        for char in str {
            guard let d = Int("\(char)"), let dow = DayOfWeek(rawValue: d) else { return nil }
            days.append(dow)
        }
        
        return days
    }
    
}
