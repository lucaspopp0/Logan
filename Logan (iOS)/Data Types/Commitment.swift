//
//  Commitment.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

protocol Commitment {
    
    var color: UIColor { get set }
    var name: String { get set }
    var nickname: String { get set }
    
    var shorterName: String { get }
    var longerName: String { get }
    
}
