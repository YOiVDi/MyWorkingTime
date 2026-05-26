//
//  FilterByDate.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 21.12.25.
//

import Foundation

struct CollectionFilters {
    
    /// Filters `items` to those occurring on the same calendar day as `targetDate` (ignores time).
    static func filterByDate<T>(_ items: [T], targetDate: Date, dateKeyPath: KeyPath<T, Date>) -> [T] {
        let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
        return items.filter { item in
            let itemComponents = Calendar.current.dateComponents([.year, .month, .day], from: item[keyPath: dateKeyPath])
            return itemComponents == targetComponents
        }
    }
    
    static func groupedByMonthYear<T>(items: [T], dateKeyPath: KeyPath<T, Date>) -> [Date: [T]] {
        var grouped: [Date : [T]] = [:]
        let calendar = Calendar.current
        for item in items {
            let components = calendar.dateComponents([.year ,.month], from: item[keyPath: dateKeyPath])
            if let monthDate = calendar.date(from: components) {
                grouped[monthDate, default: []].append(item)
            }
        }
        return grouped
    }
}
