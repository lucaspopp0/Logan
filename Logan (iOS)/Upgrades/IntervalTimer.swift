//
//  IntervalTimer.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/30/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation

class BasicTimer: NSObject {
    
    var timeInterval: TimeInterval
    var completionBlock: ((Any?) -> Void)
    
    internal(set) var isOn: Bool = false
    
    internal var timer: Timer?
    
    init(timeInterval: TimeInterval, completionBlock: @escaping (_ userInfo: Any?) -> Void) {
        self.timeInterval = timeInterval
        self.completionBlock = completionBlock
    }
    
    func begin(_ info: Any? = nil) {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.execute), userInfo: info, repeats: false)
        isOn = true
    }
    
    @objc internal func execute(_ info: Any? = nil) {
        isOn = false
        completionBlock(info)
    }
    
    func cancel() {
        timer?.invalidate()
        timer = nil
        isOn = false
    }
    
}

class UpdateTimer: BasicTimer {
    
    func fire(_ userInfo: Any? = nil) {
        completionBlock(userInfo)
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.execute(_:)), userInfo: userInfo, repeats: true)
        isOn = true
    }
    
    override func execute(_ info: Any?) {
        completionBlock(info)
    }
    
    func reset() {
        timer?.invalidate()
        begin()
    }
    
}
