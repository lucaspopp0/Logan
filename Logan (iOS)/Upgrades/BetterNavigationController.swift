//
//  BetterNavigationController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class BetterNavigationController: UINavigationController {
    
    @IBInspectable var barColor: UIColor = UIColor.teal500 {
        didSet {
            navigationBar.barTintColor = barColor
        }
    }
    
    @IBInspectable var titleColor: UIColor = UIColor.white {
        didSet {
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : titleColor]
            navigationBar.tintColor = titleColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = false
        navigationBar.barTintColor = barColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : titleColor]
        navigationBar.tintColor = titleColor
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
