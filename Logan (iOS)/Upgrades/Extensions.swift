//
//  Extensions.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/5/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

extension UIDevice {
    
    var isSimulator: Bool {
        get {
            #if arch(i386) || arch(x86_64)
                return true
            #else
                return false
            #endif
        }
    }
    
}

extension UIColor {
    
    // MARK: Material colors
    static let red500 = UIColor(red: 0.9569, green: 0.2627, blue: 0.2118, alpha: 1)
    static let red900 = UIColor(red: 0.7176, green: 0.1098, blue: 0.1098, alpha: 1)
    static let pink500 = UIColor(red: 0.9137, green: 0.1176, blue: 0.3882, alpha: 1)
    static let purple500 = UIColor(red: 0.6118, green: 0.1529, blue: 0.6902, alpha: 1)
    static let deepPurple500 = UIColor(red: 0.4039, green: 0.2275, blue: 0.7176, alpha: 1)
    static let indigo500 = UIColor(red: 0.2471, green: 0.3176, blue: 0.7098, alpha: 1)
    static let blue500 = UIColor(red: 0.1294, green: 0.5882, blue: 0.9529, alpha: 1)
    static let lightBlue500 = UIColor(red: 0.0118, green: 0.6627, blue: 0.9569, alpha: 1)
    static let cyan500 = UIColor(red: 0.0, green: 0.7373, blue: 0.8314, alpha: 1)
    static let teal500 = UIColor(red: 0.0, green: 0.5882, blue: 0.5333, alpha: 1)
    static let green500 = UIColor(red: 0.298, green: 0.6863, blue: 0.3137, alpha: 1)
    static let lightGreen500 = UIColor(red: 0.5451, green: 0.7647, blue: 0.2902, alpha: 1)
    static let lime500 = UIColor(red: 0.8039, green: 0.8627, blue: 0.2235, alpha: 1)
    static let yellow500 = UIColor(red: 1.0, green: 0.9216, blue: 0.2314, alpha: 1)
    static let amber500 = UIColor(red: 1.0, green: 0.7569, blue: 0.0275, alpha: 1)
    static let orange500 = UIColor(red: 1.0, green: 0.5961, blue: 0.0, alpha: 1)
    static let orange900 = UIColor(red: 0.902, green: 0.3176, blue: 0.0, alpha: 1)
    static let deepOrange500 = UIColor(red: 1.0, green: 0.3412, blue: 0.1333, alpha: 1)
    static let brown500 = UIColor(red: 0.4745, green: 0.3333, blue: 0.2824, alpha: 1)
    static let grey500 = UIColor(red: 0.6196, green: 0.6196, blue: 0.6196, alpha: 1)
    static let blueGray500 = UIColor(red: 0.3765, green: 0.4902, blue: 0.5451, alpha: 1)
    
    var hexString: String {
        get {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            
            self.getRed(&r, green: &g, blue: &b, alpha: nil)
            
            return String(format: "%02X%02X%02X", Int(r * 0xff), Int(g * 0xff), Int(b * 0xff))
        }
    }
    
    public convenience init(hex: String) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        
        var str: String = hex
        
        str = str.lowercased()
        
        if str.hasPrefix("#") {
            str = str.substring(from: 1)
        }
        
        if str.length == 8 {
            let scanner: Scanner = Scanner(string: str)
            var num: UInt64 = 0
            
            if scanner.scanHexInt64(&num) {
                r = CGFloat((num & 0xff000000) >> 24) / 255
                g = CGFloat((num & 0x00ff0000) >> 16) / 255
                b = CGFloat((num & 0x0000ff00) >> 8) / 255
                a = CGFloat(num & 0x000000ff) / 255
            }
        } else if str.length == 6 {
            let scanner: Scanner = Scanner(string: str)
            var num: UInt64 = 0
            
            if scanner.scanHexInt64(&num) {
                r = CGFloat((num & 0xff0000) >> 16) / 255
                g = CGFloat((num & 0x00ff00) >> 8) / 255
                b = CGFloat((num & 0x0000ff)) / 255
                a = 1
            }
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func blendedWith(percent f: CGFloat, of otherColor: UIColor) -> UIColor {
        var originalRed: CGFloat = 0
        var originalGreen: CGFloat = 0
        var originalBlue: CGFloat = 0
        var originalAlpha: CGFloat = 0
        var otherRed: CGFloat = 0
        var otherGreen: CGFloat = 0
        var otherBlue: CGFloat = 0
        var otherAlpha: CGFloat = 0
        
        self.getRed(&originalRed, green: &originalGreen, blue: &originalBlue, alpha: &originalAlpha)
        otherColor.getRed(&otherRed, green: &otherGreen, blue: &otherBlue, alpha: &otherAlpha)
        
        let blendedRed = (originalRed * (1 - f)) + (otherRed * f)
        let blendedGreen = (originalGreen * (1 - f)) + (otherGreen * f)
        let blendedBlue = (originalBlue * (1 - f)) + (otherBlue * f)
        let blendedAlpha = (originalAlpha * (1 - f)) + (otherAlpha * f)
        
        return UIColor(red: blendedRed, green: blendedGreen, blue: blendedBlue, alpha: blendedAlpha)
    }
    
}

extension String {
    
    var length: Int {
        get {
            return count
        }
    }
    
    func substring(from: Int, to: Int) -> String {
        return String(self[index(startIndex, offsetBy: from) ..< index(startIndex, offsetBy: to)])
    }
    
    func substring(from: Int) -> String {
        return substring(from: from, to: length)
    }
    
    func substring(to: Int) -> String {
        return substring(from: 0, to: to)
    }
    
    func substring(start: Int, length: Int) -> String {
        return substring(from: start, to: start + length)
    }
    
    func characterAt(index: Int) -> String {
        return substring(start: index, length: 1)
    }
    
    func size(withAttributes attributes: [NSAttributedStringKey: Any]?) -> CGSize {
        let text: NSAttributedString = NSAttributedString(string: self, attributes: attributes)
        
        return text.size()
    }
    
}

extension Date {
    
    static func dateWith(date day: Date, time: Date) -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents(in: TimeZone.current, from: day)
        let timeComponents = calendar.dateComponents([.timeZone, .hour, .minute, .second], from: time)
        
        dateComponents.timeZone = timeComponents.timeZone
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        
        return calendar.date(from: dateComponents)!
    }
    
    var hour: Int {
        get {
            return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([Calendar.Component.hour], from: self).hour!
        }
    }
    
    var minute: Int {
        get {
            return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([Calendar.Component.minute], from: self).minute!
        }
    }
    
    var weekday: Int {
        get {
            return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([Calendar.Component.weekday], from: self).weekday!
        }
    }
    
    var weekOfYear: Int {
        get {
            return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([Calendar.Component.weekOfYear], from: self).weekOfYear!
        }
    }
    
    var day: Int {
        get {
            return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([Calendar.Component.day], from: self).day!
        }
    }
    
    var month: Int {
        get {
            return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([Calendar.Component.month], from: self).month!
        }
    }
    
    var year: Int {
        get {
            return Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([Calendar.Component.year], from: self).year!
        }
    }
    
    static func daysBetween(_ date1: Date, and date2: Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        if let firstDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date1),
            let secondDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date2) {
            
            return Int(secondDate.timeIntervalSince(firstDate) / 86400)
        }
        
        return 0
    }
    
    static func minutesBetween(_ date1: Date, and date2: Date) -> Int {
        return Int(floor(abs(date1.timeIntervalSince(date2)) / 60))
    }
    
}
