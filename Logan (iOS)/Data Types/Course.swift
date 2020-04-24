//
//  Course.swift
//  Todo
//
//  Created by Lucas Popp on 10/13/17.
//  Copyright © 2017 Lucas Popp. All rights reserved.
//

import Foundation
import UIKit

class Course: BEObject {
    
    var name: String
    var nickname: String?
    var descriptor: String?
    var color: UIColor
    var semester: Semester!
    var sections: [Section] = []
    
    var formalName: String {
        get {
            return name
        }
    }
    
    var longerName: String {
        get {
            return nickname ?? name
        }
    }
    
    var shorterName: String {
        get {
            return descriptor ?? nickname ?? name
        }
    }
    
    init(id: String, name: String, nickname: String? = nil, descriptor: String? = nil, color: UIColor, semester: Semester) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.descriptor = descriptor
        self.color = color
        self.semester = semester
    }
    
    override init?(blob: Blob) {
        guard let cid = blob["cid"] as? String,
            let name = blob["name"] as? String,
            let colorString = blob["color"] as? String
            else { return nil }
        
        self.id = cid
        self.name = name
        self.color = UIColor(hex: colorString)
        self.nickname = blob["nickname"] as? String
        self.descriptor = blob["descriptor"] as? String
    }
    
    override func jsonBlob() -> Blob {
        var blob = super.jsonBlob()
        blob["sid"] = semester.id
        blob["cid"] = id
        blob["name"] = name
        blob["color"] = color.hexString
        
        if nickname != nil { blob["nickname"] = nickname! }
        if descriptor != nil { blob["descriptor"] = descriptor! }
        
        return blob
    }
    
}
