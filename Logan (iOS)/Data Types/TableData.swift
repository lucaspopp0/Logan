//
//  TableData.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 7/27/19.
//  Copyright © 2019 Lucas Popp. All rights reserved.
//

import Foundation

class TableData <T:NSObject> {
    
    class Section {
        var title: String
        var items: [T]
        
        init(title: String, items: [T] = []) {
            self.title = title
            self.items = items
        }
    }
    
    var sections: [Section] = []
    
    func add(item newItem: T, section sectionTitle: String) {
        for existingSection in sections {
            if existingSection.title == sectionTitle {
                existingSection.items.append(newItem)
                return
            }
        }
        
        let newSection = Section(title: sectionTitle)
        newSection.items.append(newItem)
        sections.append(newSection)
    }
    
    func addSection(_ section: Section) {
        sections.append(section)
    }
    
    func clear() {
        sections.removeAll()
    }
    
}

class AsyncTableData<T:NSObject>: TableData<T> {
    var isComplete: Bool = true
}
