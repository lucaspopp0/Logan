//
//  EventView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import EventKit

class EventView: UIView {
    
    var calendarEvent: EKEvent? = nil {
        didSet {
            if let evt = calendarEvent {
                title = evt.title
                subtitle = evt.notes ?? ""
                location = evt.location ?? ""
                startTime = ClockTime(date: evt.startDate)
                endTime = ClockTime(date: evt.endDate)
                tintColor = UIColor(cgColor: evt.calendar.cgColor)
            }
            
            layoutSubviews()
        }
    }
    
    private let accent = UIView()
    private let stackView = UIStackView()
    private let substacks: [UIStackView] = [UIStackView(), UIStackView()]
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
            
            for label in [timeLabel, titleLabel, subtitleLabel, locationLabel] {
                label.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
            }
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
        stackView.alignment = UIStackViewAlignment.fill
        stackView.distribution = UIStackViewDistribution.equalSpacing
        
        for substack in substacks {
            substack.axis = UILayoutConstraintAxis.horizontal
            substack.spacing = 4
            substack.alignment = UIStackViewAlignment.firstBaseline
            substack.distribution = UIStackViewDistribution.equalSpacing
            stackView.addArrangedSubview(substack)
        }
        
        substacks[0].addArrangedSubview(titleLabel)
        substacks[0].addArrangedSubview(timeLabel)
        
        substacks[1].addArrangedSubview(subtitleLabel)
        substacks[1].addArrangedSubview(locationLabel)
        
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        timeLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.bold)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        locationLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        for label in [timeLabel, titleLabel, subtitleLabel, locationLabel] {
            label.textColor = tintColor.blendedWith(percent: 0.4, of: UIColor.black)
        }
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
        
        stackView.frame.size.width = bounds.size.width - 16
        
        for substack in substacks {
            substack.frame.size.height = substack.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        }
        
        stackView.frame.size.height = stackView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        stackView.frame.origin.x = 8
        stackView.frame.origin.y = 6
    }
    
}
