//
//  RowView.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/19/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

@objc protocol RowViewDelegate: NSObjectProtocol {
    
    func numberOfRows(in rowView: RowView) -> Int
    func viewForRow(_ row: Int, in rowView: RowView) -> UIView
    
}

class RowView: UIView {
    
    @IBOutlet weak var delegate: (NSObject & RowViewDelegate)?
    
    private var views: [UIView] = []
    private var rows: [UIView] = []
    
    var numberOfRows: Int {
        get {
            return delegate?.numberOfRows(in: self) ?? 0
        }
    }
    
    func viewForRow(_ row: Int) -> UIView? {
        if row >= 0 && row < rows.count {
            return rows[row]
        }
        
        return nil
    }
    
    func reloadData() {
        while views.count > 0 {
            views.removeFirst().removeFromSuperview()
        }
        
        rows = []
        
        if delegate != nil {
            let numberOfRows = delegate!.numberOfRows(in: self)
            
            if numberOfRows > 0 {
                for i in 0 ..< numberOfRows {
                    let view = delegate!.viewForRow(i, in: self)
                    view.sizeToFit()
                    views.append(view)
                    rows.append(view)
                    addSubview(view)
                    
                    if i < numberOfRows - 1 {
                        let separator = RowViewSeparator()
                        views.append(separator)
                        addSubview(separator)
                    }
                }
            }
        }
    }
    
    override func sizeToFit() {
        arrangeViews()
    }
    
    func arrangeViews() {
        var totalHeight: CGFloat = 0
        
        for view in views {
            view.frame.origin.x = 0
            view.frame.size.width = frame.size.width
            view.sizeToFit()
            view.frame.origin.y = totalHeight
            totalHeight += view.frame.size.height
        }
        
        frame.size.height = totalHeight
    }
    
    private class RowViewSeparator: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor(white: 0.2, alpha: 1)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            backgroundColor = UIColor(white: 0.2, alpha: 1)
        }
        
        override func sizeToFit() {
            frame.size.height = 1 / UIScreen.main.scale
        }
        
    }
    
}
