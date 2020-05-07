//
//  CreationController.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 5/7/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import UIKit

class CreationController: UITableViewController {
    
    internal var isSending: Bool = false
    internal var alreadyOpened: Bool = false
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    internal func lock() {
        isModalInPresentation = true
        navigationController?.navigationBar.topItem?.leftBarButtonItem?.isEnabled = false
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
    }
    
    @IBAction func done(_ sender: Any) {
        isSending = true
        lock()
    }
    
}
