//
//  ClassTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    
    var classToDisplay: Class? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayOfWeekIndicator: DayOfWeekIndicator!
    
    func configureCell() {
        guard let classToDisplay = classToDisplay else { return }
        
        titleLabel.text = classToDisplay.title
        dayOfWeekIndicator.daysOfWeek = classToDisplay.daysOfWeek
    }
    
}
