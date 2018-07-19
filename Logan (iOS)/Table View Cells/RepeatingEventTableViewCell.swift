//
//  RepeatingEventTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class RepeatingEventTableViewCell: UITableViewCell {
    
    var event: RepeatingEvent? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configureCell() {
        guard let event = event else { return }
        
        nameLabel.text = event.name
        
        var days: [String] = []
        
        for day in event.daysOfWeek {
            days.append(day.shortName())
        }
        
        dateLabel.text = "\(days.joined(separator: ", ")) from \(BetterDateFormatter().shortFormatDate(event.startDate.dateValue!)) to \(BetterDateFormatter().shortFormatDate(event.endDate.dateValue!))"
    }
    
}

