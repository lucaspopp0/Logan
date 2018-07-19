//
//  ReminderTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/22/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    var reminder: Reminder? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private lazy var reminderIcon: UIImageView = {
        let icon = UIImageView(image: #imageLiteral(resourceName: "Reminder"))
        icon.frame.size.width = 20
        icon.frame.size.height = 20
        
        return icon
    }()
    
    func configureCell() {
        guard let reminder = reminder else { return }
        
        accessoryView = reminderIcon
        
        if reminder.triggerDate.dateValue! < Date() {
            reminderIcon.tintColor = UIColor.black.withAlphaComponent(0.2)
        } else {
            reminderIcon.tintColor = UIColor.blue500
        }
        
        dateLabel.text = BetterDateFormatter.autoFormatDate(reminder.triggerDate.dateValue!)
        messageLabel.text = reminder.message
    }
    
}
