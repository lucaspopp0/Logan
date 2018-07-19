//
//  CourseTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/6/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {
    
    var course: Course? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var colorSwatch: UIColorSwatch?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptorLabel: UILabel?
    
    func configureCell() {
        guard let course = course else { return }
        
        tintColor = course.color
        
        if descriptorLabel != nil {
            let name = course.name
            let descriptor = course.descriptor
            
            nameLabel.text = (name.isEmpty ? "Untitled Course" : name)
            
            if colorSwatch == nil {
                descriptorLabel!.textColor = course.color
            } else {
                descriptorLabel!.textColor = UIColor.black.withAlphaComponent(0.5)
                colorSwatch!.colorValue = course.color
            }
            
            if descriptor.isEmpty {
                descriptorLabel!.isHidden = true
                descriptorLabel!.text = descriptor
            } else {
                descriptorLabel!.isHidden = false
                descriptorLabel!.text = descriptor
            }
        } else {
            nameLabel.text = course.longerName
            nameLabel.textColor = course.color
        }
    }
    
}
