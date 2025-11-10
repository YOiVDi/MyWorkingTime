//
//  SettingsModel.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 29.03.24.
//

import Foundation

struct UserSettings: Codable {
    var secondWork: Bool = false
    var companyName: String = ""
    var startShift: Date = Date()
    var endShift: Date = Date()
    var pause: Date = Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 00, second: 0, of: Date()) ?? .now
    var workOnWeekend: Bool =  false
    var saturday: Bool =  false
    var startInSaturday: Date = Date()
    var endInSaturday: Date = Date()
    var sunday: Bool =  false
    var startInSunday: Date = Date()
    var endInSunday: Date = Date()
}
