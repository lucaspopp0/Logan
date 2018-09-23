//
//  BetterDatePicker.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/8/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class BetterDatePicker: UIControl {
    
    enum Style: Int {
        case dark = 0
        case light = 1
    }
    
    var dateValue: Date {
        get {
            return selectedDay.dateValue!
        }
    }
    
    var calendarDay: CalendarDay {
        get {
            return selectedDay
        }
        
        set {
            if let dateValue = newValue.dateValue {
                selectedDay = newValue
                currentYear = dateValue.year
                currentMonth = dateValue.month
                
                updateMonth()
            }
        }
    }
    
    var style: Style = Style.dark {
        didSet {
            adjustStyle()
        }
    }
    
    private static let maximumButtonSize: CGFloat = 35
    
    private var selectedDay: CalendarDay = CalendarDay(date: Date())
    
    private var monthLabel: UILabel = UILabel()
    private var lastMonthButton: UIButton = UIButton()
    private var nextMonthButton: UIButton = UIButton()
    private let dotwLabels: [UILabel] = [UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel(), UILabel()]
    private var dayButtons: [[DayButton]] = []
    
    private var currentMonth: Int = Date().month
    private var currentYear: Int = Date().year
    private var currentDay: CalendarDay {
        get {
            return CalendarDay(month: currentMonth, day: 1, year: currentYear)!
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            let columnWidth = frame.size.width / 7
            let buttonSize = min(columnWidth, BetterDatePicker.maximumButtonSize)
            
            let testMonthLabel = UILabel()
            testMonthLabel.text = "January 2018"
            testMonthLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
            testMonthLabel.sizeToFit()
            
            let testDayLabel = UILabel()
            testDayLabel.text = "W"
            testDayLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            testDayLabel.sizeToFit()
            
            return CGSize(width: buttonSize * 7, height: max(testMonthLabel.frame.size.height, 40) + 12 + testDayLabel.frame.size.height + 8 + (buttonSize * 6))
        }
    }
    
    private let dateFormatter: DateFormatter = DateFormatter()
    
    override func prepareForInterfaceBuilder() {
        unifiedInit()
    }
    
    private func unifiedInit() {
        dateFormatter.dateFormat = "MMMM yyyy"
        
        for (label, text) in zip(dotwLabels, ["S", "M", "T", "W", "T", "F", "S"]) {
            label.text = text
            label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: UIFont.Weight.semibold)
            label.textAlignment = NSTextAlignment.center
            
            addSubview(label)
        }
        
        monthLabel.text = dateFormatter.string(from: currentDay.dateValue!)
        monthLabel.textAlignment = NSTextAlignment.center
        monthLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        
        addSubview(monthLabel)
        
        lastMonthButton.setImage(#imageLiteral(resourceName: "Left Facing Arrow"), for: UIControlState.normal)
        nextMonthButton.setImage(#imageLiteral(resourceName: "Right Facing Arrow"), for: UIControlState.normal)
        
        lastMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.leading
        nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.trailing
        
        lastMonthButton.addTarget(self, action: #selector(self.lastMonth), for: UIControlEvents.touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(self.nextMonth), for: UIControlEvents.touchUpInside)
        
        addSubview(lastMonthButton)
        addSubview(nextMonthButton)
        
        for _ in 0 ..< 6 {
            var row: [DayButton] = []
            
            for _ in 0 ..< 7 {
                let newButton = DayButton()
                newButton.addTarget(self, action: #selector(self.buttonPressed(_:)), for: UIControlEvents.touchUpInside)
                
                addSubview(newButton)
                row.append(newButton)
            }
            
            dayButtons.append(row)
        }
        
        updateMonth()
        
        adjustStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    private func adjustStyle() {
        let styleColor = style == Style.dark ? UIColor.black : UIColor.white
        
        for label in dotwLabels {
            label.textColor = styleColor.withAlphaComponent(label.text! == "S" ? 0.6 : 1)
        }
        
        monthLabel.textColor = styleColor.withAlphaComponent(0.5)
        
        lastMonthButton.tintColor = styleColor.withAlphaComponent(0.5)
        nextMonthButton.tintColor = styleColor.withAlphaComponent(0.5)
        
        for row in dayButtons {
            for button in row {
                button.style = style
            }
        }
    }
    
    private func organize() {
        monthLabel.sizeToFit()
        
        let arrowSize: CGFloat = max(monthLabel.frame.size.height, 40)
        
        lastMonthButton.frame = CGRect(x: 0, y: 0, width: arrowSize, height: arrowSize)
        nextMonthButton.frame = CGRect(x: frame.size.width - arrowSize, y: 0, width: arrowSize, height: arrowSize)
        monthLabel.frame = CGRect(x: arrowSize, y: 0, width: nextMonthButton.frame.minX - lastMonthButton.frame.maxX, height: arrowSize)
        
        let columnWidth = frame.size.width / 7
        let buttonSize = min(columnWidth, BetterDatePicker.maximumButtonSize)
        let buttonSpacing = (frame.size.width - (7 * buttonSize)) / 6
        var maxHeight: CGFloat = 0
        
        for label in dotwLabels {
            label.sizeToFit()
            maxHeight = max(maxHeight, label.frame.size.height)
        }
        
        for (i, label) in dotwLabels.enumerated() {
            label.frame = CGRect(x: (buttonSize + buttonSpacing) * CGFloat(i), y: monthLabel.frame.maxY + 12, width: buttonSize, height: maxHeight)
        }
        
        for (i, row) in dayButtons.enumerated() {
            let r = CGFloat(i)
            for (j, button) in row.enumerated() {
                button.frame = CGRect(x: (buttonSize + buttonSpacing) * CGFloat(j), y: monthLabel.frame.maxY + 12 + maxHeight + 8 + (buttonSize * r), width: buttonSize, height: buttonSize)
            }
        }
    }
    
    private func updateMonth() {
        monthLabel.text = dateFormatter.string(from: currentDay.dateValue!)
        
        let monthToDisplay: Int = currentMonth
        var stepperDate = currentDay.dateValue!
        let firstDayOfWeek = DayOfWeek.forDate(stepperDate).rawValue
        
        stepperDate = stepperDate.addingTimeInterval(-Double(firstDayOfWeek) * 24 * 60 * 60)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        for i in 0 ..< dayButtons.count {
            for j in 0 ..< dayButtons[i].count {
                dayButtons[i][j].day = CalendarDay(date: stepperDate)
                
                stepperDate = stepperDate.addingTimeInterval(24 * 60 * 60)
                
                dayButtons[i][j].isCurrent = (dayButtons[i][j].day == selectedDay)
                dayButtons[i][j].isInBackground = (dayButtons[i][j].day.month != monthToDisplay)
            }
        }
        
        organize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        organize()
    }
    
    @objc fileprivate func lastMonth() {
        if currentMonth == 1 {
            currentMonth = 12
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
        
        updateMonth()
    }
    
    @objc fileprivate func nextMonth() {
        if currentMonth == 12 {
            currentMonth = 1
            currentYear += 1
        } else {
            currentMonth += 1
        }
        
        updateMonth()
    }
    
    @objc fileprivate func buttonPressed(_ sender: DayButton) {
        selectedDay = sender.day
        
        currentMonth = sender.day.month
        currentYear = sender.day.year
        
        updateMonth()
        
        sendActions(for: UIControlEvents.valueChanged)
    }
    
    override func sizeToFit() {
        let itcs = intrinsicContentSize
        if frame.size.width < itcs.width {
            frame.size.width = itcs.width
        }
        
        if frame.size.height < itcs.height {
            frame.size.height = itcs.height
        }
    }
    
}

fileprivate class DayButton: UIButton {
    
    var style: BetterDatePicker.Style = BetterDatePicker.Style.dark {
        didSet {
            updateAppearance()
        }
    }
    
    var day: CalendarDay!
    private let shapeLayer = CAShapeLayer()
    
    var isCurrent: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    var isInBackground: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    var isWeekend: Bool {
        get {
            if let date = day.dateValue {
                let dotw = DayOfWeek.forDate(date)
                
                return dotw == DayOfWeek.saturday || dotw == DayOfWeek.sunday
            }
            
            return false
        }
    }
    
    private func unifiedInit() {
        titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        layer.insertSublayer(shapeLayer, below: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        unifiedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        unifiedInit()
    }
    
    private func updateAppearance() {
        let primaryColor = (style == BetterDatePicker.Style.dark ? UIColor.black : UIColor.white)
        let secondaryColor = (style == BetterDatePicker.Style.dark ? UIColor.white : UIColor.black)
        
        setTitle("\(day.day)", for: UIControlState.normal)
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        if isCurrent {
            setTitleColor(secondaryColor, for: UIControlState.normal)
            
            if isInBackground {
                shapeLayer.fillColor = tintColor.withAlphaComponent(0.2).cgColor
            } else {
                shapeLayer.fillColor = tintColor.cgColor
            }
        } else {
            if day == CalendarDay(date: Date()) {
                setTitleColor(tintColor.withAlphaComponent(isInBackground ? 0.3 : 1), for: UIControlState.normal)
            } else {
                setTitleColor(primaryColor.withAlphaComponent((isInBackground ? 0.4 : 1) * (isWeekend ? 0.6 : 1)), for: UIControlState.normal)
            }
            
            shapeLayer.fillColor = nil
        }
        
        CATransaction.commit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let hairlineWidth = 1 / UIScreen.main.scale
        shapeLayer.path = CGPath(ellipseIn: bounds.insetBy(dx: hairlineWidth, dy: hairlineWidth), transform: nil)
    }
    
}
