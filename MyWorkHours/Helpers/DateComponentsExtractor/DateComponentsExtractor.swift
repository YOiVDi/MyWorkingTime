//
//  SetHourAndMinute.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 21.12.25.
//

import Foundation

struct DateComponentsExtractor {
    
    // Returns today's date with the time (hour/minute/second) stored in settings.
    static func settingTime(from time: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        let today = Date()
        return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                             minute: timeComponents.minute ?? 0,
                             second: timeComponents.second ?? 0,
                             of: today) ?? today
    }
    
}
