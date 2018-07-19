//
//  BetterTextView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/7/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@IBDesignable class BetterTextView: UITextView {
    
    override var text: String! {
        didSet {
            textChanged()
        }
    }
    
    private let placeholderLabel: UILabel = UILabel()
    
    @IBInspectable var placeholderText: String = "" {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }
    
    @IBInspectable var paddingTop: CGFloat = 0 {
        didSet {
            textContainerInset = padding
        }
    }
    
    @IBInspectable var paddingBottom: CGFloat = 0 {
        didSet {
            textContainerInset = padding
        }
    }
    
    @IBInspectable var paddingLeft: CGFloat = 0 {
        didSet {
            textContainerInset = padding
        }
    }
    
    @IBInspectable var paddingRight: CGFloat = 0 {
        didSet {
            textContainerInset = padding
        }
    }
    
    private var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        }
    }
    
    private func unifiedInit() {
        addSubview(placeholderLabel)
        sendSubview(toBack: placeholderLabel)
        
        placeholderLabel.textColor = UIColor.black.withAlphaComponent(0.25)
        placeholderLabel.text = placeholderText
        placeholderLabel.font = font ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        textContainer.lineFragmentPadding = 0
        textContainerInset = padding
        
        placeholderLabel.isHidden = !text.isEmpty
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textChanged), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    override func prepareForInterfaceBuilder() {
        unifiedInit()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin.x = textContainerInset.left + textContainer.lineFragmentPadding
        placeholderLabel.frame.origin.y = textContainerInset.top + (1 / UIScreen.main.scale)
    }
    
    @objc private func textChanged() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
}
