//
//  ClassView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ClassView: EventView {
    
    var classToDisplay: Section? {
        didSet {
            if let ctd = classToDisplay {
                title = ctd.course.longerName
                subtitle = ctd.title
                location = ctd.location ?? ""
                startTime = ctd.startTime
                endTime = ctd.endTime
                tintColor = ctd.course.color
            } else {
                title = ""
                subtitle = ""
                location = ""
            }
            
            layoutSubviews()
        }
    }
    
}
