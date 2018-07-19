//
//  InterfaceManager.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

class InterfaceManager: NSObject {
    
    static let shared = InterfaceManager()
    
    var tasksController: TasksViewController!
    var assignmentsController: AssignmentsViewController!
    var semestersController: SemestersTableViewController!
    
}
