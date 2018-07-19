//
//  SingleEventTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SingleEventTableViewCell: UITableViewCell {
    
    var event: SingleEvent? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configureCell() {
        guard let event = event else { return }
        
        nameLabel.text = event.name
        dateLabel.text = BetterDateFormatter.autoFormatDate(event.date.dateValue!)
    }
    
}
