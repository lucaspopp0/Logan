//
//  User.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/20/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation

class User: BEObject {
    
    var name: String
    var email: String
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    override init?(blob: Blob) {
        guard let id = blob["id"] as? String,
            let name = blob["name"] as? String,
            let email = blob["email"] as? String
            else { return nil }
        
        self.id = id
        self.name = name
        self.email = email
    }
    
    override func jsonBlob() -> Blob {
        return ["id": id,
                "name": name,
                "email": email]
    }
    
}
