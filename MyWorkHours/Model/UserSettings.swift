//
//  SettingsModel.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 29.03.24.
//

import Foundation

struct UserSettings: Codable {
    var companyName: String = ""
//    var workingHours: Int = 0
    var startShift: Date = Date()
    var endShift: Date = Date()
    var workOnWeekend: Bool =  false
    var saturday: Bool =  false
//    var saturdayHours: Int = 0
    var startInSaturday: Date = Date()
    var endInSaturday: Date = Date()
    var sunday: Bool =  false
//    var sundayHours: Int = 0
    var startInSunday: Date = Date()
    var endInSunday: Date = Date()
}
