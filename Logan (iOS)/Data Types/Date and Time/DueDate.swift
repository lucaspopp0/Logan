//
//  DueDate.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

enum DueDate {
    
    case eventually
    case asap
    case beforeClass(course: Course, onDate: CalendarDay)
    case specificDay(day: CalendarDay)
    case specificDeadline(deadline: BetterDate)
    
    var dbValue: String! {
        get {
            switch self {
            case .eventually:
                return "eventually"
            case .asap:
                return "asap"
            case .specificDay(let day):
                return day.format(API.DB_DATE_FORMAT)
            case .specificDeadline(let deadline):
                return deadline.format(API.DB_DATETIME_FORMAT)
            default:
                return nil
            }
        }
    }
    
}
