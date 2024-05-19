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
    var sunday: Bool =  false
    var holidays: Bool =  false
}
