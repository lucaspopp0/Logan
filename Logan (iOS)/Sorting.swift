//
//  Sorting.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 7/27/19.
//  Copyright © 2019 Lucas Popp. All rights reserved.
//

import Foundation

class Sorting {
    
    static func initialSortAlgorithm(showingCompletedTasks: Bool) -> ((Task, Task) -> Bool) {
        if !showingCompletedTasks {
            return self.initialSortIncompleteTasks(_:_:)
        } else {
            return self.initialSortCompleteTasks(_:_:)
        }
    }
    
    static func initialSortIncompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        switch task1.dueDate {
        case .asap:
            switch task2.dueDate {
            case .asap:
                return task1.title < task2.title
                
            default:
                return true
            }
            
        case .eventually:
            switch task2.dueDate {
            case .eventually:
                return task1.title < task2.title
                
            default:
                return false
            }
            
        case .specificDay(let day1):
            switch task2.dueDate {
            case .asap:
                return false
                
            case .eventually:
                return true
                
            case .specificDay(let day2):
                return day1 < day2
                
            default:
                return task1.title < task2.title
            }
            
        default:
            return task1.title < task2.title
        }
    }
    
    static func initialSortCompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        if let completion1 = task1.completionDate, let completion2 = task2.completionDate {
            return completion1 > completion2
        }
        
        return true
    }
    
    static func sectionSortAlgorithm(showingCompletedTasks: Bool) -> ((Task, Task) -> Bool) {
        if !showingCompletedTasks {
            return self.sectionSortIncompleteTasks(_:_:)
        } else {
            return self.sectionSortCompleteTasks(_:_:)
        }
    }
    
    static func sectionSortIncompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        if task1.priority.rawValue != task2.priority.rawValue {
            return task1.priority.rawValue > task2.priority.rawValue
        }
        
        if task1.commitment != nil && task2.commitment == nil {
            return true
        } else if task1.commitment == nil && task2.commitment != nil {
            return false
        } else if task1.commitment != nil && task2.commitment != nil && !task1.commitment!.isEqual(task2.commitment!) {
            return task1.commitment!.name < task2.commitment!.name
        }
        
        if task1.relatedAssignment != nil && task2.relatedAssignment == nil {
            return true
        } else if task1.relatedAssignment == nil && task2.relatedAssignment != nil {
            return false
        } else if task1.relatedAssignment != nil && task2.relatedAssignment != nil && !task1.relatedAssignment!.isEqual(task2.relatedAssignment!) {
            return task1.relatedAssignment!.title < task2.relatedAssignment!.title
        }
        
        if let creationDate1 = task1.record.creationDate, let creationDate2 = task2.record.creationDate {
            return creationDate1 < creationDate2
        }
        
        return task1.title < task2.title
    }
    
    static func sectionSortCompleteTasks(_ task1: Task, _ task2: Task) -> Bool {
        if task1.priority.rawValue != task2.priority.rawValue {
            return task1.priority.rawValue > task2.priority.rawValue
        }
        
        if task1.commitment != nil && task2.commitment == nil {
            return true
        } else if task2.commitment == nil && task2.commitment != nil {
            return false
        } else if task1.commitment != nil && task2.commitment != nil && !task1.commitment!.isEqual(task2.commitment!) {
            return task1.commitment!.name < task2.commitment!.name
        }
        
        if task1.relatedAssignment != nil && task2.relatedAssignment == nil {
            return true
        } else if task1.relatedAssignment == nil && task2.relatedAssignment != nil {
            return false
        } else if task1.relatedAssignment != nil && task2.relatedAssignment != nil && !task1.relatedAssignment!.isEqual(task2.relatedAssignment!) {
            return task1.relatedAssignment!.title < task2.relatedAssignment!.title
        }
        
        if let creationDate1 = task1.record.creationDate, let creationDate2 = task2.record.creationDate {
            return creationDate1 > creationDate2
        }
        
        return task1.title < task2.title
    }
    
    static func sortTasksForAssignment(_ task1: Task, _ task2: Task) -> Bool {
        switch task1.dueDate {
        case .asap:
            switch task2.dueDate {
            case .asap:
                return task1.title < task2.title
                
            default:
                return true
            }
            
        case .eventually:
            switch task2.dueDate {
            case .eventually:
                return task1.title < task2.title
                
            default:
                return false
            }
            
        case .specificDay(let day1):
            switch task2.dueDate {
            case .asap:
                return false
                
            case .eventually:
                return true
                
            case .specificDay(let day2):
                return day1 < day2
                
            default:
                break
            }
            
        default:
            break
        }
        
        if !task1.completed && task2.completed {
            return true
        } else if task1.completed && !task2.completed {
            return false
        }
        
        if task1.priority.rawValue != task2.priority.rawValue {
            return task1.priority.rawValue > task2.priority.rawValue
        }
        
        if task1.commitment != nil && task2.commitment == nil {
            return true
        } else if task2.commitment == nil && task2.commitment != nil {
            return false
        } else if task1.commitment != nil && task2.commitment != nil && !task1.commitment!.isEqual(task2.commitment!) {
            return task1.commitment!.name < task2.commitment!.name
        }
        
        if task1.relatedAssignment != nil && task2.relatedAssignment == nil {
            return true
        } else if task1.relatedAssignment == nil && task2.relatedAssignment != nil {
            return false
        } else if task1.relatedAssignment != nil && task2.relatedAssignment != nil && !task1.relatedAssignment!.isEqual(task2.relatedAssignment!) {
            return task1.relatedAssignment!.title < task2.relatedAssignment!.title
        }
        
        if let creationDate1 = task1.record.creationDate, let creationDate2 = task2.record.creationDate {
            return creationDate1 < creationDate2
        }
        
        return task1.title < task2.title
    }
    
}
