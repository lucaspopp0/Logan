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
            nameLabel.text = course.name
            
            if colorSwatch == nil {
                descriptorLabel!.textColor = course.color
            } else {
                descriptorLabel!.textColor = UIColor.black.withAlphaComponent(0.5)
                colorSwatch!.colorValue = course.color
            }

            descriptorLabel!.text = course.descriptor
            descriptorLabel!.isHidden = course.descriptor == nil || course.descriptor!.isEmpty
        } else {
            nameLabel.text = course.longerName
            nameLabel.textColor = course.color
        }
    }
    
}
