//
//  ExamTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ExamTableViewCell: UITableViewCell {
    
    var exam: Exam? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    func configureCell() {
        guard let exam = exam else { return }
        
        titleLabel.text = exam.title
        dateLabel.text = BetterDateFormatter.autoFormatDate(exam.date.dateValue!)
        
        if (exam.location ?? "").isEmpty {
            locationLabel.isHidden = true
        } else {
            locationLabel.isHidden = false
            locationLabel.text = exam.location!
        }
    }
    
}
