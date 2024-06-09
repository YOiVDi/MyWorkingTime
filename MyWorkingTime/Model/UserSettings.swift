//
//  SettingsModel.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 29.03.24.
//

import Foundation

struct UserSettings: Codable {
    var companyName: String = ""
    var workingHours: Int = 8
    var workOnWeekend: Bool =  false
    var saturday: Bool =  false
    var saturdayHours: Int = 0
    var sunday: Bool =  false
    var sundayHours: Int = 0
    var holidays: Bool =  false
    var holidaysHours: Int = 0
}
