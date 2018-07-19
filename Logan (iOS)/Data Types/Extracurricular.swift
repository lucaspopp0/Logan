//
//  Extracurricular.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import CloudKit

class Extracurricular: CKEnabled, Commitment {
    
    static var NEXT_SAVE_ID: Int = 0
    var ID: Int = 0 {
        didSet {
            record["id"] = ID as CKRecordValue
        }
    }
    
    var name: String = "" {
        didSet {
            record["name"] = name as CKRecordValue
        }
    }
    
    var nickname: String = "" {
        didSet {
            record["nickname"] = nickname as CKRecordValue
        }
    }
    
    var color: UIColor = UIColor.black {
        didSet {
            record["color"] = color.hexString as CKRecordValue
        }
    }
    
    var events: [Event] = [] {
        didSet {
            var references: [CKReference] = []

            for event in events {
                references.append(CKReference(record: event.record, action: CKReferenceAction.none))
            }

            record["events"] = references as CKRecordValue
        }
    }
    
    var shorterName: String {
        get {
            return nickname.isEmpty ? name : nickname
        }
    }
    
    var longerName: String {
        get {
            return nickname.isEmpty ? nickname : name
        }
    }
    
    init(record: CKRecord, events: [Event]) {
        super.init(record: record)
        
        if let name = record["name"] as? String, let hexColor = record["color"] as? String, let id = record["id"] as? Int {
            self.name = name
            self.color = UIColor(hex: hexColor)
            self.ID = id
            
            self.nickname = record["nickname"] as? String ?? ""
            
            if let eventReferences = record["events"] as? [CKReference] {
                for reference in eventReferences {
                    for event in events {
                        if reference.recordID.isEqual(event.record.recordID) {
                            self.events.append(event)
                            event.extracurricular = self
                            break
                        }
                    }
                }
            }
        }
        
        Extracurricular.NEXT_SAVE_ID = max(self.ID + 1, Extracurricular.NEXT_SAVE_ID)
    }
    
    init() {
        let tempRecord = CKRecord(recordType: "Extracurricular")
        tempRecord["name"] = "" as CKRecordValue
        tempRecord["nickname"] = "" as CKRecordValue
        tempRecord["color"] = UIColor.black.hexString as CKRecordValue
        tempRecord["id"] = Extracurricular.NEXT_SAVE_ID as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
}

