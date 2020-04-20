//
//  Course.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import UIKit
import CloudKit

class Course: BEObject, Commitment {
    
    var name: String
    var nickname: String
    var descriptor: String
    var color: UIColor
    var sid: String
    var sections: [Section] = []
    
    var formalName: String {
        get {
            return name
        }
    }
    
    var longerName: String {
        get {
            return nickname.isEmpty ? name : nickname
        }
    }
    
    var shorterName: String {
        get {
            return nickname.isEmpty ? (descriptor.isEmpty ? name : descriptor) : nickname
        }
    }
    
    var shortestName: String {
        get {
            return descriptor
        }
    }
    
    init(id: String, name: String, nickname: String = "", descriptor: String = "", color: UIColor, sid: String) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.descriptor = descriptor
        self.color = color
        self.sid = sid
    }
    
    init?(blob: Blob) {
        guard let cid = blob["cid"] as? String, let name = blob["name"] as? String, let colorString = blob["color"] as? String, let sid = blob["sid"] as? String else { return nil }
        
        self.id = cid
        self.sid = sid
        self.name = name
    }
    
    init(record: CKRecord, classes: [Section], exams: [Exam]) {
        super.init(record: record)
        
        if let name = record["name"] as? String, let descriptor = record["descriptor"] as? String, let hexColor = record["color"] as? String, let id = record["id"] as? Int {
            self.name = name
            self.descriptor = descriptor
            self.color = UIColor(hex: hexColor)
            self.nickname = (record["nickname"] as? String) ?? ""
            
            if let classReferences = record["classes"] as? [CKReference] {
                for reference in classReferences {
                    for providedClass in classes {
                        if reference.recordID.isEqual(providedClass.record.recordID) {
                            self.classes.append(providedClass)
                            providedClass.course = self
                            break
                        }
                    }
                }
            }
            
            if let examReferences = record["exams"] as? [CKReference] {
                for reference in examReferences {
                    for providedExam in exams {
                        if reference.recordID.isEqual(providedExam.record.recordID) {
                            self.exams.append(providedExam)
                            providedExam.course = self
                            break
                        }
                    }
                }
            }
            
            self.ID = id

            Course.NEXT_SAVE_ID = max(self.ID + 1, Course.NEXT_SAVE_ID)
        }
    }
    
    init() {
        let tempRecord = CKRecord(recordType: "Course")
        tempRecord["name"] = "" as CKRecordValue
        tempRecord["descriptor"] = "" as CKRecordValue
        tempRecord["hexColor"] = UIColor.black.hexString as CKRecordValue
        tempRecord["id"] = Course.NEXT_SAVE_ID as CKRecordValue
        
        super.init(record: tempRecord)
    }
    
    func getValueForStorage() -> Any {
        var dict: [String: Any] = ["Name" : name,
                                   "Descriptor" : descriptor,
                                   "Color" : NSKeyedArchiver.archivedData(withRootObject: color),
                                   "ID" : ID]
        
        var storableClasses: [Any] = []
        
        for c in classes {
            storableClasses.append(c.getValueForStorage())
        }
        
        dict["Classes"] = storableClasses
        
        return dict
    }
    
}
