//
//  ShowMoreView.swift
//  Tasks
//
//  Created by Lucas Popp on 3/12/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import NotificationCenter

class ShowMoreView: UIView {
    
    var extraCount: Int = 0 {
        didSet {
            button.setTitle("See \(extraCount) more", for: UIControlState.normal)
        }
    }
    
    static var estimatedHeight: CGFloat {
        get {
            let tempView = ShowMoreView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
            tempView.extraCount = 8
            tempView.sizeToFit()
            return tempView.frame.size.height
        }
    }
    
    private let blurView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    private let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffectStyle.dark)))
    private let button: UIButton = UIButton()
    
    var extensionContext: NSExtensionContext?
    
    private func unifiedInit() {
        blurView.alpha = 0.5
        addSubview(blurView)
        blurView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(button)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        backgroundColor = UIColor.clear
        
        button.addTarget(self, action: #selector(self.openApp), for: UIControlEvents.touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    override func sizeToFit() {
        let testLabel = UILabel()
        testLabel.text = "See \(extraCount) more"
        testLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        testLabel.sizeToFit()
        
        frame.size.height = testLabel.frame.size.height + 16
        blurView.frame = bounds
        vibrancyView.frame = bounds
        button.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        sizeToFit()
    }
    
    @objc private func openApp() {
        if let url = URL(string: "logan://tasks") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
    
}
