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
    
    var correspondingCommitment: Commitment? {
        didSet {
            if correspondingCommitment == nil {
                var index: Int = -1
                
                for i in 0 ..< segmentedControl.numberOfSegments {
                    if segmentedControl.titleForSegment(at: i) == "Before class" {
                        index = i
                        break
                    }
                }
                
                if index >= 0 {
                    segmentedControl.removeSegment(at: index, animated: false)
                }
            } else {
                if segmentedControl.numberOfSegments == 3 {
                    segmentedControl.insertSegment(withTitle: "Before class", at: 1, animated: false)
                }
            }
            
            for i in 0 ..< segmentedControl.numberOfSegments {
                if segmentedControl.titleForSegment(at: i) == "Before class" {
                    segmentedControl.setEnabled(false, forSegmentAt: i)
                } else {
                    segmentedControl.setEnabled(true, forSegmentAt: i)
                }
            }
            
            classPicker?.course = (correspondingCommitment as? Course)
        }
    }

    private(set) var pickerOpen: Bool = false
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pickerContainer: UIStackView!
    @IBOutlet weak var datePicker: BetterDatePicker!
    @IBOutlet weak var classPicker: ClassPicker?
    
    var fittingHeight: CGFloat {
        get {
            if pickerOpen {
                if segmentedControl.selectedSegmentIndex == 0 {
                    return pickerContainer.frame.minY + datePicker.frame.maxY + 12
                } else if classPicker != nil && segmentedControl.selectedSegmentIndex == 1 && (segmentedControl.titleForSegment(at: 1) ?? "") == "Before class" {
                    return pickerContainer.frame.minY + classPicker!.frame.maxY + 12
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
            classPicker?.isHidden = true
        } else if sender.selectedSegmentIndex == 1 && (sender.titleForSegment(at: 1) ?? "") == "Before class" {
            datePicker.isHidden = true
            classPicker?.isHidden = false
        } else {
            datePicker.isHidden = true
            classPicker?.isHidden = true
        }
        
        datePicker.sizeToFit()
        classPicker?.sizeToFit()
        
        delegate?.dueDateTypeChanged?(in: self)
    }

}
