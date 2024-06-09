//
//  SettingsViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 17.01.24.
//

import SwiftUI
import Combine

extension SettingsView {
    @MainActor class SettingsViewModel: ObservableObject {
        @Published var alert: CustomAlerts? = nil
        
        /// Settings properties
        @Published var companyName: String = ""
        @Published var workHours: Int = 0
        @Published var workOnWeekends: Bool = false {
            didSet {
                if !workOnWeekends {
                    workOnSaturday = false
                    workOnSunday = false
                    saturdayHours = 0
                    sundayHours = 0
                }
            }
        }
        @Published var workOnSaturday: Bool = false
        @Published var saturdayHours: Int = 0
        @Published var workOnSunday: Bool = false
        @Published var sundayHours: Int = 0
        @Published var workOnHolidays: Bool = false
        @Published var holidaysHours: Int = 0
        
        /// Private properties
        private var settings = UserDefaults.standard.data(forKey: "userSettings")
        private var cancellables = Set<AnyCancellable>()
        
        
        /// Pause properties array
        let pauseTime: [Int] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]
        
        /// Define defaultWorkingHours outside the property initializer
        //        private let defaultWorkingHours: Date
        
        // MARK: - Initialization
        
        init() {
            //            // Initialize defaultWorkingHours
            //            defaultWorkingHours = Calendar(identifier: .gregorian).date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
            
            // Initialize settings with default values or retrieved values from UserDefaults
            setRetrievedData()
            debouncing()
        }
        
        
        // MARK: - Methods
        
        /// Save data to UserDefaults
        private func saveSettingsToUserDefaults() {
            let settings = UserSettings(
                companyName: companyName,
                workingHours: workHours,
                workOnWeekend: workOnWeekends,
                saturday: workOnSaturday,
                saturdayHours: saturdayHours,
                sunday: workOnSunday,
                sundayHours: sundayHours,
                holidays: workOnHolidays,
                holidaysHours: holidaysHours)
            
            do {
                let data = try JSONEncoder().encode(settings)
                UserDefaults.standard.set(data, forKey: "userSettings")
                alert = .saved
            } catch {
                print("Cannot encode your settings: \(error.localizedDescription).")
            }
        }
        
        /// Retrieve saved date from UserDefaults
        private func retrieveSettingsFromUserDefaults() -> UserSettings {
            guard let userData = settings else {
                return UserSettings(
                    companyName: "",
                    workingHours: 0,
                    workOnWeekend: false,
                    saturday: false,
                    saturdayHours: 0,
                    sunday: false,
                    sundayHours: 0,
                    holidays: false,
                    holidaysHours: 0
                )
            }
            
            do {
                return try JSONDecoder().decode(UserSettings.self, from: userData)
            } catch {
                print("Cannot retrieve your data: \(error.localizedDescription).")
                return UserSettings(
                    companyName: "",
                    workingHours: 0,
                    workOnWeekend: false,
                    saturday: false,
                    saturdayHours: 0,
                    sunday: false,
                    sundayHours: 0,
                    holidays: false,
                    holidaysHours: 0
                )
            }
        }
        
        /// Set retrieved data from UserDefaults
        private func setRetrievedData() {
            let savedSettings = retrieveSettingsFromUserDefaults()
            companyName = savedSettings.companyName
            workHours = savedSettings.workingHours
            workOnWeekends = savedSettings.workOnWeekend
            workOnSaturday = savedSettings.saturday
            saturdayHours = savedSettings.saturdayHours
            workOnSunday = savedSettings.sunday
            sundayHours = savedSettings.sundayHours
            workOnHolidays = savedSettings.holidays
            holidaysHours = savedSettings.holidaysHours
        }
        
        /// Debouncing data, so after typing or changing data will be saved once after 2 seconds
        private func debouncing() {
            Publishers.CombineLatest4(
                $companyName,
                $workHours,
                $workOnWeekends,
                $workOnSaturday
            )
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _, _ in
                self?.saveSettingsToUserDefaults()
            }
            .store(in: &cancellables)
            
            Publishers.CombineLatest3(
                $saturdayHours,
                $workOnSunday,
                $sundayHours
            )
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                self?.saveSettingsToUserDefaults()
            }
            .store(in: &cancellables)
            
            $workOnHolidays
                .combineLatest($holidaysHours)
                .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
                .sink { [weak self] _, _ in
                    self?.saveSettingsToUserDefaults()
                }
                .store(in: &cancellables)
        }
    }
}
