//
//  TaskDueDatePickerTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/8/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class TaskDueDatePickerTableViewCell: UITableViewCell {
    
    private(set) var pickerOpen: Bool = false
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var dueTodayButton: UIButton!
    @IBOutlet weak var nextConvenientDateButton: UIButton!
    @IBOutlet weak var datePicker: BetterDatePicker!
    
    var fittingHeight: CGFloat {
        get {
            if pickerOpen {
                if segmentedControl.selectedSegmentIndex == 0 {
                    return datePicker.frame.maxY + 12
                } else {
                    return segmentedControl.frame.maxY + 12
                }
            } else {
                return label.frame.maxY + 12
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            pickerOpen = !pickerOpen
        }
    }
    
}
