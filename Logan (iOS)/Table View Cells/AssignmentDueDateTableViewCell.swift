//
//  AssignmentDueDateTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/14/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@objc protocol AssignmentDueDatePickerDelegate: NSObjectProtocol {
    
    @objc optional func dueDateTypeChanged(in cell: AssignmentDueDateTableViewCell)
    
}

class AssignmentDueDateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var delegate: (NSObject & AssignmentDueDatePickerDelegate)?

    private(set) var pickerOpen: Bool = false
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickerContainer: UIStackView!
    @IBOutlet weak var datePicker: BetterDatePicker!
    
    var fittingHeight: CGFloat {
        get {
            if pickerOpen {
                if segmentedControl.selectedSegmentIndex == 0 {
                    return pickerContainer.frame.minY + datePicker.frame.maxY + 12
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
        
        segmentSelected(segmentedControl)
    }
    
    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            datePicker.isHidden = false
        } else {
            datePicker.isHidden = true
        }
        
        datePicker.sizeToFit()

        delegate?.dueDateTypeChanged?(in: self)
    }

}
