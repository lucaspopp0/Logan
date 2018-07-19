//
//  File.swift
//  Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

class File: NSObject {
    
    static var NEXT_SAVE_ID: Int = 0
    var ID: Int = 0
    
    var number: Int
    var name: String
    
    init(number: Int, name: String) {
        self.number = number
        self.name = name
        
        ID = File.NEXT_SAVE_ID
        File.NEXT_SAVE_ID += 1
    }
    
}
