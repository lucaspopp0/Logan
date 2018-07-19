//
//  DueDate.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

enum DueDate {
    
    static let eventuallyIntValue: Int = 0
    static let asapIntValue: Int = 1
    static let beforeClassIntValue: Int = 2
    static let specificDayIntValue: Int = 3
    static let specificDeadlineIntValue: Int = 4
    
    case eventually
    case asap
    case beforeClass(course: Course, onDate: CalendarDay)
    case specificDay(day: CalendarDay)
    case specificDeadline(deadline: BetterDate)
    
    var intValue: Int {
        get {
            switch self {
            case .eventually:
                return 0
                
            case .asap:
                return 1
                
            case .beforeClass(_, _):
                return 2
                
            case .specificDay(_):
                return 3
                
            case .specificDeadline(_):
                return 4
            }
        }
    }
    
}
