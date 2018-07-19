//
//  Priority.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation
import UIKit.UIColor

enum Priority: Int {
    
    case low = 0
    case normal = 1
    case high = 2
    case reallyHigh = 3
    
    var color: UIColor {
        get {
            switch self {
            case .reallyHigh:
                return UIColor(red: 1.0, green: 0.3412, blue: 0.1333, alpha: 1)
                
            case .high:
                return UIColor(red: 1.0, green: 0.5961, blue: 0.0, alpha: 1)
                
            case .normal:
                return UIColor.black
                
            case .low:
                return UIColor(red: 0.2471, green: 0.3176, blue: 0.7098, alpha: 1)
            }
        }
    }
    
    var textColor: UIColor {
        get {
            switch self {
            case .reallyHigh:
                return UIColor(red: 1.0, green: 0.3412, blue: 0.1333, alpha: 1)
                
            case .high:
                return UIColor(red: 1.0, green: 0.5961, blue: 0.0, alpha: 1)
                
            case .normal:
                return UIColor.black.withAlphaComponent(0.5)
                
            case .low:
                return UIColor(red: 0.2471, green: 0.3176, blue: 0.7098, alpha: 1)
            }
        }
    }
    
}
