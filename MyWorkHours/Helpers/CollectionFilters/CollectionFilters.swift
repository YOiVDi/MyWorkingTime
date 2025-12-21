//
//  FilterByDate.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 21.12.25.
//

import Foundation

struct CollectionFilters {
    
    /// Filters `items` to those occurring on the same calendar day as `targetDate` (ignores time).
    static func filterByDate<T>( _items: [T], targetDate: Date, dateKeyPath: KeyPath<T, Date>) -> [T] {
        let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
        return _items.filter { item in
            let itemComponents = Calendar.current.dateComponents([.year, .month, .day], from: item[keyPath: dateKeyPath])
            return itemComponents == targetComponents
        }
    }
}
