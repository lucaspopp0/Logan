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
    
    case reallyLow = -2
    case low = -1
    case normal = 0
    case high = 1
    case reallyHigh = 2
    
    var color: UIColor {
        get {
            switch self {
            case .reallyHigh:
                return UIColor(red: 1.0, green: 0.3412, blue: 0.1333, alpha: 1)
                
            case .high:
                return UIColor(red: 1.0, green: 0.5961, blue: 0.0, alpha: 1)
                
            case .normal:
                if #available(iOS 13.0, *) {
                    return UIColor.white
                } else {
                    return UIColor.black
                }
                
            case .low:
                return UIColor(red: 0.2471, green: 0.3176, blue: 0.7098, alpha: 1)
                    
            case .reallyLow:
                // TODO: Make different from low later
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
                    
            case .reallyLow:
                // TODO: Make different from low later
                return UIColor(red: 0.2471, green: 0.3176, blue: 0.7098, alpha: 1)
            }
        }
    }
    
}
