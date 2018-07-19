//
//  Reminder.swift
//  Todo
//
//  Created by Lucas Popp on 10/21/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import UserNotifications
import CloudKit

class Reminder: CKEnabled {
    
    static var NEXT_SAVE_ID: Int = 0
    var ID: Int = 0 {
        didSet {
            record["id"] = ID as CKRecordValue
        }
    }
    
    var assignment: Assignment?
    var task: Task?
    
    var message: String = "" {
        didSet {
            record["message"] = message as CKRecordValue
        }
    }
    
    var triggerDate: BetterDate = BetterDate(date: Date(timeIntervalSinceNow: 24 * 60 * 60)) {
        didSet {
            record["triggerDate"] = triggerDate.stringValue as CKRecordValue
        }
    }
    
    var identifier: String {
        get {
            return "LocalNotification.\(record!.recordID.recordName)"
        }
    }
    
    func notificationRequest() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()

        if let a = assignment {
            content.title = a.title
            content.userInfo = ["Assignment Record Name" : a.record.recordID.recordName]
        } else if let t = task {
            content.title = "Reminder for \(t.title)"
            content.userInfo = ["Task Record Name" : t.record.recordID.recordName]
        }

        content.body = message
        content.sound = UNNotificationSound.default()

        let components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: triggerDate.dateValue!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }
    
    override init(record: CKRecord) {
        super.init(record: record)
        
        if let message = record["message"] as? String, let triggerDate = record["triggerDate"] as? String, let id = record["id"] as? Int {
            self.message = message
            
            if let actualTriggerDate = BetterDate(string: triggerDate) {
                self.triggerDate = actualTriggerDate
            }
            
            self.ID = id
        }
        
        Reminder.NEXT_SAVE_ID = max(self.ID + 1, Reminder.NEXT_SAVE_ID)
    }
    
    convenience init() {
        let tempRecord = CKRecord(recordType: "Reminder")
        tempRecord["message"] = "" as CKRecordValue
        tempRecord["triggerDate"] = BetterDate(date: Date(timeIntervalSinceNow: 24 * 60 * 60)).stringValue as CKRecordValue
        tempRecord["id"] = Reminder.NEXT_SAVE_ID as CKRecordValue
        
        self.init(record: tempRecord)
    }
    
}
