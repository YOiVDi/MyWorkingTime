//
//  DateHelper.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 21.12.25.
//

import Foundation

struct DateHelper {
    
    static func weekday(from date: Date) -> Int {
        Calendar.current.component(.weekday, from: date)
    }
    
    static func isSunday(_ weekday: Int) -> Bool {
        weekday == 1
    }
    
    static func isSaturday(_ weekday: Int) -> Bool {
        weekday == 7
    }
    
    static func minutesToSeconds(_ time: Date?) -> Int {
        guard let time = time else { return 0 }
        let dateComponents = Calendar.current.dateComponents([.minute], from: time)
        let pauseToInt = Int(dateComponents.minute ?? 0)
        return (pauseToInt * 60)
    }
    
    static func yearMonthFormatter(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    static func defaultTime() -> Date {
        return Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 00, second: 0, of: .now) ?? Date()
    }
}
