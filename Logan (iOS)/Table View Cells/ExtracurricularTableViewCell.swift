//
//  ExtracurricularTableViewCell.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ExtracurricularTableViewCell: UITableViewCell {
    
    var extracurricular: Extracurricular? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet weak var colorSwatch: UIColorSwatch?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var nicknameLabel: UILabel!
    
    func configureCell() {
        guard let extracurricular = extracurricular else { return }
        
        tintColor = extracurricular.color
        
        nameLabel?.text = (extracurricular.name.isEmpty ? "Untitled Extracurricular" : extracurricular.name)
        
        if colorSwatch == nil {
            nicknameLabel.textColor = extracurricular.color
        } else {
            nicknameLabel.textColor = UIColor.black.withAlphaComponent(0.5)
            colorSwatch!.colorValue = extracurricular.color
        }
        
        if extracurricular.nickname.isEmpty {
            nicknameLabel.isHidden = true
        } else {
            nicknameLabel.isHidden = false
            nicknameLabel.text = extracurricular.nickname
        }
    }
    
}

