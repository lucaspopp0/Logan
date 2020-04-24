//
//  BEObject.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/20/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation

class BEObject: NSObject {
    
    var id: String
    
    init(id: String) {
        self.id = id
    }
    
    func jsonBlob() -> Blob {
        var blob = Blob()
        
        if let uid = DataManager.shared.currentUser?.id {
            blob["uid"] = uid
        }
        
        return blob
    }
    
}
