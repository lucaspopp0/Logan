//
//  ClassTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SectionTableViewCell: UITableViewCell {
    
    var sectionToDisplay: Section? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dayOfWeekIndicator: DayOfWeekIndicator!
    
    func configureCell() {
        guard let sectionToDisplay = sectionToDisplay else { return }
        
        nameLabel.text = sectionToDisplay.name
        dayOfWeekIndicator.daysOfWeek = sectionToDisplay.daysOfWeek
    }
    
}
