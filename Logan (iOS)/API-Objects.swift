//
//  API-Objects.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 9/14/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

protocol APIObject {
    
    var user: String { get set }
    var id: String { get set }
    
}

protocol APISource: APIObject {}

class APISemester: APIObject {
    var user: String
    var id: String
    var name: String
    var startDate: CalendarDay
    var endDate: CalendarDay
    var courses: [APICourse]
    
    init(user: String, id: String, name: String, startDate: CalendarDay, endDate: CalendarDay, courses: [APICourse]) {
        self.user = user
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.courses = courses
    }
    
    convenience init?(dict: [String: Any]) {
        if let user = dict["user"] as? String, let id = dict["id"] as? String, let name = dict["name"] as? String, let start_date = dict["start_date"] as? String, let end_date = dict["end_date"] as? String {
            let f = DateFormatter()
            f.dateFormat = "M-d-yyyy"
            self.init(user: user, id: id, name: name, startDate: CalendarDay(date: f.date(from: start_date)!), endDate: CalendarDay(date: f.date(from: end_date)!), courses: [])
        } else {
            return nil
        }
    }
}

class APICourse: APIObject, APISource {
    var user: String
    var id: String
    var name: String
    var descriptor: String
    var color: String
    var semester: APISemester
    var sections: [APISection]
    
    init(user: String, id: String, name: String, descriptor: String, color: String, semester: APISemester, sections: [APISection]) {
        self.user = user
        self.id = id
        self.name = name
        self.descriptor = descriptor
        self.color = color
        self.semester = semester
        self.sections = sections
    }
    
    convenience init?(dict: [String: Any], semester: APISemester) {
        if let user = dict["user"] as? String, let id = dict["id"] as? String, let name = dict["name"] as? String, let color = dict["color"] as? String {
            let descriptor = (dict["descriptor"] as? String) ?? ""
            
            self.init(user: user, id: id, name: name, descriptor: descriptor, color: color, semester: semester, sections: [])
        } else {
            return nil
        }
    }
}

class APISection: APIObject {
    var user: String
    var id: String
    var name: String
    var location: String
    var startDate: CalendarDay
    var startTime: ClockTime
    var endDate: CalendarDay
    var endTime: ClockTime
    var course: APICourse
    
    init(user: String, id: String, name: String, location: String, startDate: CalendarDay, startTime: ClockTime, endDate: CalendarDay, endTime: ClockTime, course: APICourse) {
        self.user = user
        self.id = id
        self.name = name
        self.location = location
        self.startDate = startDate
        self.startTime = startTime
        self.endDate = endDate
        self.endTime = endTime
        self.course = course
    }
    
    convenience init?(dict: [String: Any], course: APICourse) {
        let df = DateFormatter()
        let tf = DateFormatter()
        df.dateFormat = "M-d-yyyy"
        tf.dateFormat = "h:mm a"
        
        if let user = dict["user"] as? String, let id = dict["id"] as? String, let name = dict["name"] as? String, let start_date = dict["start_date"] as? String, let startDate = df.date(from: start_date), let start_time = dict["start_time"] as? String, let startTime = tf.date(from: start_time), let end_date = dict["end_date"] as? String, let endDate = df.date(from: end_date), let end_time = dict["end_time"] as? String, let endTime = tf.date(from: end_time) {
            let location = dict["location"] as? String ?? ""
            
            self.init(user: user, id: id, name: name, location: location, startDate: CalendarDay(date: startDate), startTime: ClockTime(date: startTime), endDate: CalendarDay(date: endDate), endTime: ClockTime(date: endTime), course: course)
        } else {
            return nil
        }
    }
}

class APITag: APIObject, APISource {
    var user: String
    var id: String
    var text: String
    var color: String
    
    init(user: String, id: String, text: String, color: String) {
        self.user = user
        self.id = id
        self.text = text
        self.color = color
    }
    
    convenience init?(dict: [String: Any]) {
        if let user = dict["user"] as? String, let id = dict["id"] as? String, let text = dict["text"] as? String, let color = dict["color"] as? String {
            self.init(user: user, id: id, text: text, color: color)
        } else {
            return nil
        }
    }
}

class APIAssessment: APIObject {
    var user: String
    var id: String
    var name: String
    var location: String
    var date: CalendarDay
    var startTime: ClockTime
    var endTime: ClockTime
    var source: APISource?
    
    init(user: String, id: String, name: String, location: String, date: CalendarDay, startTime: ClockTime, endTime: ClockTime, source: APISource?) {
        self.user = user
        self.id = id
        self.name = name
        self.location = location
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.source = source
    }
    
    convenience init?(dict: [String: Any], source: APISource?) {
        let df = DateFormatter()
        let tf = DateFormatter()
        df.dateFormat = "M-d-yyyy"
        tf.dateFormat = "h:mm a"
        
        if let user = dict["user"] as? String, let id = dict["id"] as? String, let name = dict["name"] as? String, let date_string = dict["date"] as? String, let date = df.date(from: date_string), let start_time = dict["start_time"] as? String, let startTime = tf.date(from: start_time), let end_time = dict["end_time"] as? String, let endTime = tf.date(from: end_time) {
            self.init(user: user, id: id, name: name, location: (dict["location"] as? String) ?? "", date: CalendarDay(date: date), startTime: ClockTime(date: startTime), endTime: ClockTime(date: endTime), source: source)
        } else {
            return nil
        }
    }
}

protocol APIFinishable: APIObject {
    
    var finished: Bool { get set }
    var dateFinished: CalendarDay? { get set }
    
}

class APIAssignment: APIObject, APISource, APIFinishable {
    var user: String
    var id: String
    var name: String
    var userDescription: String
    var dueDate: DueDate
    var sources: [APISource]
    var finished: Bool
    var dateFinished: CalendarDay?
    
    init(user: String, id: String, name: String, userDescription: String, dueDate: DueDate, sources: [APISource], finished: Bool, dateFinished: CalendarDay?) {
        self.user = user
        self.id = id
        self.name = name
        self.userDescription = userDescription
        self.dueDate = dueDate
        self.sources = sources
        self.finished = finished
        self.dateFinished = dateFinished
    }
    
    convenience init?(dict: [String: Any], sources: [APISource]) {
        let f = DateFormatter()
        f.dateFormat = "M-d-yyyy h:mm a"
        
        if let user = dict["user"] as? String, let id = dict["id"] as? String, let name = dict["name"] as? String, let due_date = dict["due_date"] as? String, let dueDate = f.date(from: due_date) {
            let finished = (dict["finished"] as? Bool) ?? false
            f.dateFormat = "M-d-yyyy"
            
            var dateFinished: CalendarDay?
            if let date_finished = dict["date_finished"] as? String, let df = f.date(from: date_finished) {
                dateFinished = CalendarDay(date: df)
            }
            
            self.init(user: user, id: id, name: name, userDescription: (dict["description"] as? String) ?? "", dueDate: DueDate.specificDeadline(deadline: BetterDate(date: dueDate)), sources: sources, finished: finished, dateFinished: dateFinished)
        } else {
            return nil
        }
    }
}

class APITask: APIObject, APIFinishable {
    var user: String
    var id: String
    var name: String
    var userDescription: String
    var doDate: DueDate
    var priority: Int
    var sources: [APISource]
    var finished: Bool
    var dateFinished: CalendarDay?
    
    init(user: String, id: String, name: String, userDescription: String, doDate: DueDate, priority: Int, sources: [APISource], finished: Bool, dateFinished: CalendarDay?) {
        self.user = user
        self.id = id
        self.name = name
        self.userDescription = userDescription
        self.doDate = doDate
        self.priority = priority
        self.sources = sources
        self.finished = finished
        self.dateFinished = dateFinished
    }
    
    convenience init?(dict: [String: Any], sources: [APISource]) {
        let f = DateFormatter()
        f.dateFormat = "M-d-yyyy"
        
        if let user = dict["user"] as? String, let id = dict["id"] as? String, let name = dict["name"] as? String, let do_date = dict["do_date"] as? String, let priority = dict["priority"] as? Int {
            let finished = (dict["finished"] as? Bool) ?? false
            var dateFinished: CalendarDay?
            
            if let date_finished = dict["date_finished"] as? String, let df = f.date(from: date_finished) {
                dateFinished = CalendarDay(date: df)
            }
            
            var doDate: DueDate!
            
            if do_date == "asap" {
                doDate = DueDate.asap
            } else if do_date == "eventually" {
                doDate = DueDate.eventually
            } else if let date = f.date(from: do_date) {
                doDate = DueDate.specificDay(day: CalendarDay(date: date))
            }
            
            self.init(user: user, id: id, name: name, userDescription: (dict["description"] as? String) ?? "", doDate: doDate, priority: priority, sources: sources, finished: finished, dateFinished: dateFinished)
        } else {
            return nil
        }
    }
}
