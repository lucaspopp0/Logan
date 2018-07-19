//
//  BetterDateFormatter.swift
//  Todo
//
//  Created by Lucas Popp on 12/24/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation

class BetterDateFormatter: DateFormatter {
    
    static func autoFormatDueDate(_ dueDate: DueDate) -> String {
        let formatter = BetterDateFormatter()
        
        switch dueDate {
            
        case .asap:
            return "Due ASAP"
            
        case .eventually:
            return "Due eventually"
            
        case .specificDay(let day):
            if let date = day.dateValue {
                let now = Date()
                let today = CalendarDay(date: now)
                let daysBetweenDates = Date.daysBetween(now, and: date)
                
                if today == day {
                    return "Due today"
                } else if daysBetweenDates == 1 {
                    return "Due tomorrow"
                } else if daysBetweenDates == -1 {
                    return "Due yesterday"
                } else if date.weekOfYear == now.weekOfYear && date.year == now.year {
                    formatter.dateFormat = "EEEE"
                    return "Due \(formatter.string(from: date))"
                } else {
                    let lastWeek = now.addingTimeInterval(-7 * 24 * 60 * 60)
                    let nextWeek = now.addingTimeInterval(7 * 24 * 60 * 60)
                    
                    if date.weekOfYear == lastWeek.weekOfYear && date.year == lastWeek.year {
                        formatter.dateFormat = "EEEE"
                        return "Due last \(formatter.string(from: date))"
                    } else if date.weekOfYear == nextWeek.weekOfYear && date.year == nextWeek.year {
                        formatter.dateFormat = "EEEE"
                        return "Due next \(formatter.string(from: date))"
                    } else {
                        if now.year != date.year {
                            formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                        } else {
                            formatter.dateFormat = "EEEE, MMMM dnn"
                        }
                        
                        return "Due \(formatter.string(from: date))"
                    }
                }
            }
            break
            
        case .specificDeadline(let deadline):
            if let date = deadline.dateValue {
                let now = Date()
                let today = CalendarDay(date: now)
                let daysBetweenDates = Date.daysBetween(now, and: date)
                
                if today == deadline.day {
                    return "Due today"
                } else if daysBetweenDates == 1 {
                    return "Due tomorrow"
                } else if daysBetweenDates == -1 {
                    return "Due yesterday"
                } else if date.weekOfYear == now.weekOfYear && date.year == now.year {
                    formatter.dateFormat = "EEEE"
                    return "Due \(formatter.string(from: date))"
                } else {
                    let lastWeek = now.addingTimeInterval(-7 * 24 * 60 * 60)
                    let nextWeek = now.addingTimeInterval(7 * 24 * 60 * 60)
                    
                    if date.weekOfYear == lastWeek.weekOfYear && date.year == lastWeek.year {
                        formatter.dateFormat = "EEEE"
                        return "Due last \(formatter.string(from: date))"
                    } else if date.weekOfYear == nextWeek.weekOfYear && date.year == nextWeek.year {
                        formatter.dateFormat = "EEEE"
                        return "Due next \(formatter.string(from: date))"
                    } else {
                        if now.year != date.year {
                            formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                        } else {
                            formatter.dateFormat = "EEEE, MMMM dnn"
                        }
                        
                        return "Due \(formatter.string(from: date))"
                    }
                }
            }
            break
            
        default: break
            
        }
        
        return "Invalid due date"
    }
    
    func shortFormatDate(_ date: Date) -> String {
        let tempFormat = self.dateFormat
        dateFormat = "M/d/yy"
        let out = string(from: date)
        dateFormat = tempFormat
        return out
    }
    
    static func autoFormatDate(_ date: Date, forSentence: Bool = false) -> String {
        let formatter = BetterDateFormatter()
        
        let day = CalendarDay(date: date)
        let now = Date()
        let today = CalendarDay(date: now)
        let daysBetweenDates = Date.daysBetween(now, and: date)
        
        if today == day {
            return !forSentence ? "Today" : "today"
        } else if daysBetweenDates == 1 {
            return !forSentence ? "Tomorrow" : "tomorrow"
        } else if daysBetweenDates == -1 {
            return !forSentence ? "Yesterday" : "yesterday"
        } else if date.weekOfYear == now.weekOfYear && date.year == now.year {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let lastWeek = now.addingTimeInterval(-7 * 24 * 60 * 60)
            let nextWeek = now.addingTimeInterval(7 * 24 * 60 * 60)
            
            if date.weekOfYear == lastWeek.weekOfYear && date.year == lastWeek.year {
                formatter.dateFormat = "EEEE"
                return "\(!forSentence ? "Last" : "last") \(formatter.string(from: date))"
            } else if date.weekOfYear == nextWeek.weekOfYear && date.year == nextWeek.year {
                formatter.dateFormat = "EEEE"
                return "\(!forSentence ? "Next" : "next") \(formatter.string(from: date))"
            } else {
                if now.year != date.year {
                    formatter.dateFormat = "EEEE, MMMM dnn, yyyy"
                } else {
                    formatter.dateFormat = "EEEE, MMMM dnn"
                }
                
                return formatter.string(from: date)
            }
        }
    }
    
    static func autoFormatTime(_ time: Date) -> String {
        let clockTime = ClockTime(date: time)
        let formatter = BetterDateFormatter()
        
        if clockTime.minute == 0 {
            formatter.dateFormat = "h a"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        
        return formatter.string(from: time)
    }
    
    override func string(from date: Date) -> String {
        let day = date.day
        super.dateFormat = super.dateFormat.replacingOccurrences(of: "nn", with: "__")
        super.dateFormat = super.dateFormat.replacingOccurrences(of: "NN", with: "--")
        let dateString = super.string(from: date)
        var suffix: String = ""
        
        if 10 <= day && day <= 20 {
            suffix = "th"
        } else if day % 10 == 1 {
            suffix = "st"
        } else if day % 10 == 2 {
            suffix = "nd"
        } else if day % 10 == 3 {
            suffix = "rd"
        } else {
            suffix = "th"
        }
        
        var output = dateString.replacingOccurrences(of: "__", with: suffix)
        output = output.replacingOccurrences(of: "--", with: suffix.uppercased())
        
        return output
    }
    
}
