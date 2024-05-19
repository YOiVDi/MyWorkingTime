//
//  SettingsViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 17.01.24.
//

import SwiftUI

extension SettingsView {
    @MainActor class SettingsViewModel: ObservableObject {
        @Published var userSettings = UserSettings()
        @Published var alert: CustomAlerts? = nil
        var settings = UserDefaults.standard.data(forKey: "userSettings")
        
        
        /// Pause properties array
        let pauseTime: [Int] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]
        
        /// Define defaultWorkingHours outside the property initializer
        private let defaultWorkingHours: Date
        
        func workOnWeekend() {
            if userSettings.workOnWeekend == false {
                userSettings.sunday = false
                userSettings.saturday = false
                userSettings.holidays = false
            }
        }
        
        // MARK: - Initialization
        
        init() {
            // Initialize defaultWorkingHours
            defaultWorkingHours = Calendar(identifier: .gregorian).date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
            
            // Initialize settings with default values or retrieved values from UserDefaults
            
            retrieveSettingsFromUserDefaults()
        }
        
        
        // MARK: - Methods
        
        func saveSettingsToUserDefaults() {
            guard !userSettings.companyName.isEmpty else {
                alert = .emptyCompanyName
                return
            }
            
            do {
                let data = try JSONEncoder().encode(userSettings)
                settings = data
                UserDefaults.standard.set(settings, forKey: "userSettings")
                alert = .saved
            } catch {
                print("Cannot encode your settings: \(error.localizedDescription).")
            }
        }
        
        func retrieveSettingsFromUserDefaults() {
            guard let userData = settings else { return }
//            guard let userData = settings else { return }
            do {
                userSettings = try JSONDecoder().decode(UserSettings.self, from: userData)
            } catch {
                print("Cannot retrieve your data: \(error.localizedDescription).")
            }
        }
        
        func trimWhiteSpace() {
            userSettings.companyName = userSettings.companyName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
    }
}
