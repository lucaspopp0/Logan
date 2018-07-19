//
//  OverviewExamTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/28/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class OverviewExamTableViewCell: UITableViewCell {
    
    var exam: Exam? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commitmentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configureCell() {
        guard let exam = exam else { return }
        
        titleLabel.text = exam.title
        commitmentLabel.text = exam.course.longerName
        commitmentLabel.textColor = exam.course.color
        dateLabel.text = BetterDateFormatter.autoFormatDate(exam.date.dateValue!)
    }
    
}
