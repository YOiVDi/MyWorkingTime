//
//  SettingsModel.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 29.03.24.
//

import Foundation

struct UserSettings: Codable {
    var companyName: String = ""
    var workOnWeekend: Bool =  false
//    var workingHours: Date = Date()
    var workingHours: Int = 8
}
