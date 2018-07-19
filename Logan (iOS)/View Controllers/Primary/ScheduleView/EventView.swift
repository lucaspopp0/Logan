//
//  EventView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class EventView: UIView {
    
    var event: Event? = nil {
        didSet {
            if let evt = event {
                title = evt.extracurricular.shorterName
                subtitle = evt.name
                location = evt.location ?? ""
                startTime = evt.startTime
                endTime = evt.endTime
                tintColor = evt.extracurricular.color
            } else {
                title = ""
                subtitle = ""
                location = ""
            }
            
            layoutSubviews()
        }
    }
    
    private let accent = UIView()
    private let stackView = UIStackView()
    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let locationLabel = UILabel()
    
    override var intrinsicContentSize: CGSize {
        get {
            var oldSize = super.intrinsicContentSize
            oldSize.height = stackView.frame.size.height + 12
            
            return oldSize
        }
    }
    
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subtitle = "" {
        didSet {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle.isEmpty
        }
    }
    
    var location = "" {
        didSet {
            locationLabel.text = location
            locationLabel.isHidden = location.isEmpty
        }
    }
    
    var startTime = ClockTime(date: Date()) {
        didSet {
            timeLabel.text = "\(BetterDateFormatter.autoFormatTime(startTime.dateValue!)) - \(BetterDateFormatter.autoFormatTime(endTime.dateValue!))"
        }
    }
    
    var endTime = ClockTime(date: Date()) {
        didSet {
            timeLabel.text = "\(BetterDateFormatter.autoFormatTime(startTime.dateValue!)) - \(BetterDateFormatter.autoFormatTime(endTime.dateValue!))"
        }
    }
    
    var dayOfWeek: DayOfWeek?
    
    override var tintColor: UIColor! {
        didSet {
            backgroundColor = tintColor.withAlphaComponent(0.5)
            accent.backgroundColor = tintColor
            
            timeLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
            titleLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
            subtitleLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
            locationLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
        }
    }
    
    private func unifiedInit() {
        backgroundColor = tintColor.withAlphaComponent(0.5)
        accent.backgroundColor = tintColor
        
        clipsToBounds = true
        layer.masksToBounds = true
        layer.cornerRadius = 2
        
        addSubview(accent)
        addSubview(stackView)
        
        stackView.axis = UILayoutConstraintAxis.vertical
        stackView.spacing = 0
        stackView.alignment = UIStackViewAlignment.leading
        stackView.distribution = UIStackViewDistribution.equalSpacing
        
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(locationLabel)
        
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        timeLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.bold)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        locationLabel.font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        timeLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
        titleLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
        subtitleLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
        locationLabel.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        accent.frame.origin = CGPoint.zero
        accent.frame.size.width = 2
        accent.frame.size.height = frame.size.height
        
        timeLabel.frame.size = timeLabel.sizeThatFits(bounds.size)
        titleLabel.frame.size = titleLabel.sizeThatFits(bounds.size)
        subtitleLabel.frame.size = subtitleLabel.sizeThatFits(bounds.size)
        locationLabel.frame.size = locationLabel.sizeThatFits(bounds.size)
        
        var stackViewHeight: CGFloat = timeLabel.frame.size.height + titleLabel.frame.size.height
        
        if !subtitleLabel.isHidden {
            stackViewHeight += subtitleLabel.frame.size.height
        }
        
        if !locationLabel.isHidden {
            stackViewHeight += locationLabel.frame.size.height
        }
        
        stackView.frame.size.width = bounds.size.width - 16
        stackView.frame.size.height = stackViewHeight
        stackView.frame.origin.x = 8
        stackView.frame.origin.y = 6
    }
    
}