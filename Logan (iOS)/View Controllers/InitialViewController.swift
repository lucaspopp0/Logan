//
//  InitialViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let introCompleted = UserDefaults.standard.bool(forKey: "Introduction Completed")
        
        if introCompleted {
            performSegue(withIdentifier: "Show Main Interface", sender: self)
        } else {
            performSegue(withIdentifier: "Welcome User", sender: self)
        }
    }
    
}
