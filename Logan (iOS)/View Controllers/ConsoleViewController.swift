//
//  ConsoleViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/6/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ConsoleViewController: UIViewController, ConsoleListener {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Console.shared.addListener(self)
        constructLines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.layoutIfNeeded()
        textView.scrollRectToVisible(CGRect(x: 0, y: textView.contentSize.height - 1, width: 1, height: 1), animated: false)
    }
    
    func constructLines() {
        textView.text = Console.shared.lines.joined(separator: "\n\n")
    }
    
    // MARK: ConsoleListener
    
    func newOutput(in console: Console) {
        constructLines()
    }
    
}
