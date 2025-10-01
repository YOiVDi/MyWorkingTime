//
//  WorkTimeAsInt.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 10.09.25.
//

import Foundation

extension Date {
    /// Convert Date into Int
    /// - Parameters:
    ///   - startShift: take date which represent start shift
    ///   - endShift: take date which represent end shift
    /// - Returns: Conver start and end shift into Int
    func returnWorkTimeAsInt(startShift: Date, endShift: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startShift, to: endShift)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        return hours * 60 + minutes
    }
}
