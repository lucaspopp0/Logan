//
//  CKEnabled.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation
import CloudKit

class CKEnabled: NSObject {
    
    var record: CKRecord!
    
    init(record: CKRecord) {
        self.record = record
    }
    
}
