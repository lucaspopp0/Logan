//
//  DatetimeValue.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/21/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation

protocol DatetimeValue {
    
    init(date: Date)
    init?(stringValue dateString: String, format formatString: String)
    
    func format(_ format: String) -> String!
    
}
