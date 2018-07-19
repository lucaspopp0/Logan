//
//  Console.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/6/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

protocol ConsoleListener {
    
    func newOutput(in console: Console)
    
}

class Console: NSObject {
    
    static let shared: Console = Console()
    
    private var listeners: [ConsoleListener] = []
    
    var lines: [String] = []
    
    func print(_ obj: Any?) {
        lines.append("\(obj ?? "nil")")
        Swift.print(obj ?? "nil")
        
        DispatchQueue.main.async {
            for listener in self.listeners {
                listener.newOutput(in: self)
            }
        }
    }
    
    func addListener(_ listener: ConsoleListener) {
        listeners.append(listener)
    }
    
}
