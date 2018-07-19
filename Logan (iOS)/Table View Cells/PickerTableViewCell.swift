//
//  PickerTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {
    
    private(set) var pickerOpen: Bool = false
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var displayLabel: UILabel?
    @IBOutlet weak var picker: UIView!
    
    var fittingHeight: CGFloat {
        get {
            if pickerOpen {
                return picker.frame.maxY + 12
            } else {
                return label.frame.maxY + 12
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            pickerOpen = !pickerOpen
        }
    }

}
