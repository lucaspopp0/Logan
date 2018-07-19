//
//  SemesterTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class SemesterTableViewCell: UITableViewCell {
    
    var semester: Semester? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel?
    @IBOutlet weak var coursesLabel: UILabel!
    
    func configureCell() {
        guard let semester = semester else { return }
        
        nameLabel.text = semester.name
        datesLabel?.text = "\(BetterDateFormatter().shortFormatDate(semester.startDate.dateValue!)) - \(BetterDateFormatter().shortFormatDate(semester.endDate.dateValue!))"
        
        if semester.courses.count == 1 {
            coursesLabel.text = "1 course"
        } else {
            coursesLabel.text = "\(semester.courses.count) courses"
        }
    }
    
}

