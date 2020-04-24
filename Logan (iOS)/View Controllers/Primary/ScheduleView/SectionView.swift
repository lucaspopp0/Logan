//
//  ClassView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SectionView: EventView {
    
    var sectionToDisplay: Section? {
        didSet {
            if let ctd = sectionToDisplay {
                title = ctd.course.longerName
                subtitle = ctd.name
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
