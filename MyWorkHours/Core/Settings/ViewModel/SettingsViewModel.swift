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
//        @Published var workHours: Int = 0
        @Published var startShift: Date = Date()
        @Published var endShift: Date = Date()
        @Published var workOnWeekends: Bool = false {
            didSet {
                if !workOnWeekends {
                    workOnSaturday = false
                    workOnSunday = false
                    startInSaturday = Date()
                    endInSaturday = Date()
                    startInSunday = Date()
                    endInSunday = Date()
                }
            }
        }
        @Published var workOnSaturday: Bool = false
//        @Published var saturdayHours: Int = 0
        @Published var startInSaturday: Date = Date()
        @Published var endInSaturday: Date = Date()
        @Published var workOnSunday: Bool = false
//        @Published var sundayHours: Int = 0
        @Published var startInSunday: Date = Date()
        @Published var endInSunday: Date = Date()
        @Published var workOnHolidays: Bool = false
//        @Published var holidaysHours: Int = 0
        
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
        private func encodeUserSettings() {
            let settings = UserSettings(
                companyName: companyName,
                startShift: startShift,
                endShift: endShift,
                workOnWeekend: workOnWeekends,
                saturday: workOnSaturday,
                startInSaturday: startInSaturday,
                endInSaturday: endInSaturday,
                sunday: workOnSunday,
                startInSunday: startInSunday,
                endInSunday: endInSunday,
                holidays: workOnHolidays)
//                holidaysHours: holidaysHours)
            
            do {
                let data = try JSONEncoder().encode(settings)
                UserDefaults.standard.set(data, forKey: "userSettings")
                alert = .saved
            } catch {
                print("Cannot encode your settings: \(error.localizedDescription).")
            }
        }
        
        /// Retrieve saved date from UserDefaults
        private func decodeUserSettings() -> UserSettings {
            guard let userData = settings else {
                return UserSettings(
                    companyName: "",

                    startShift: Date(),
                    endShift: Date(),
                    workOnWeekend: false,
                    saturday: false,

                    startInSaturday: Date(),
                    endInSaturday: Date(),
                    sunday: false,
                    startInSunday: Date(),
                    endInSunday: Date(),
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
                    startShift: Date(),
                    endShift: Date(),
                    workOnWeekend: false,
                    saturday: false,
                    startInSaturday: Date(),
                    endInSaturday: Date(),
                    sunday: false,
                    startInSunday: Date(),
                    endInSunday: Date(),
                    holidays: false,
                    holidaysHours: 0
                )
            }
        }
        
        /// Set retrieved data from UserDefaults
        private func setRetrievedData() {
            let savedSettings = decodeUserSettings()
            companyName = savedSettings.companyName
//            workHours = savedSettings.workingHours
            startShift = savedSettings.startShift
            endShift = savedSettings.endShift
            workOnWeekends = savedSettings.workOnWeekend
            workOnSaturday = savedSettings.saturday
//            saturdayHours = savedSettings.saturdayHours
            startInSaturday = savedSettings.startInSaturday
            endInSaturday = savedSettings.endInSaturday
            workOnSunday = savedSettings.sunday
//            sundayHours = savedSettings.sundayHours
            startInSunday = savedSettings.startInSunday
            endInSunday = savedSettings.endInSunday
            workOnHolidays = savedSettings.holidays
//            holidaysHours = savedSettings.holidaysHours
        }
        
        /// Debouncing data, so after typing or changing data will be saved once after 2 seconds
        private func debouncing() {
            Publishers.CombineLatest4(
                $companyName,
//                $workHours,
                $workOnSunday,
                $workOnWeekends,
                $workOnSaturday
            )
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _, _ in
                self?.encodeUserSettings()
            }
            .store(in: &cancellables)
            
            Publishers.CombineLatest(
                $startShift,
                $endShift
            )
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.encodeUserSettings()
            }
            .store(in: &cancellables)
            
            Publishers.CombineLatest4(
                $startInSunday,
                $endInSunday,
//                $workOnSunday,
                $startInSunday,
                $endInSunday
            )
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _, _ in
                self?.encodeUserSettings()
            }
            .store(in: &cancellables)
            
//            $workOnHolidays
//                .combineLatest($holidaysHours)
//                .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
//                .sink { [weak self] _, _ in
//                    self?.encodeUserSettings()
//                }
//                .store(in: &cancellables)
        }
    }
}
