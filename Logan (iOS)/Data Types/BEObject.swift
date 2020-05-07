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
    var idKey: String {
        return "id"
    }
    
    init(id: String) {
        self.id = id
    }
    
    init?(blob: Blob) {
        return nil
    }
    
    func jsonBlob() -> Blob {
        var blob = Blob()
        
        if let uid = DataManager.shared.currentUser?.id {
            blob["uid"] = uid
        }
        
        return blob
    }
    
    func jsonDeleteBlob() -> Blob {
        var blob = Blob()
        
        if let uid = DataManager.shared.currentUser?.id {
            blob["uid"] = uid
        }
        
        blob[idKey] = id
        
        return blob
    }
    
}
