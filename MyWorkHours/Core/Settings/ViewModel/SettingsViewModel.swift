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
        @Published var btnTitle: LocalizedStringKey = ""
        
        /// Settings properties
        @Published var companyName: String = ""
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
        @Published var startInSaturday: Date = Date()
        @Published var endInSaturday: Date = Date()
        @Published var workOnSunday: Bool = false
        @Published var startInSunday: Date = Date()
        @Published var endInSunday: Date = Date()
        
        /// Private properties
        private var settings = UserDefaults.standard.data(forKey: "userSettings")
        private var cancellables = Set<AnyCancellable>()
        private var notificationCenter = NotificationCenter()
        
        
        /// Pause properties array
        let pauseTime: [Int] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]
        
        
        // MARK: - Initialization
        
        init() {
            setRetrievedData()
            debouncing()
            checkAuthorizationStatus()
        }
        
        
        // MARK: - Methods
        
        /// Save user settings into userdefaults.
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
                endInSunday: endInSunday)
            
            do {
                let data = try JSONEncoder().encode(settings)
                UserDefaults.standard.set(data, forKey: "userSettings")
                alert = .saved
            } catch {
                print("Cannot encode your settings: \(error.localizedDescription).")
            }
        }
        
        /// Retrieve saved settings from UserDefaults
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
                    endInSunday: Date()
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
                    endInSunday: Date()
                )
            }
        }
        
        /// Set retrieved settings from UserDefaults
        private func setRetrievedData() {
            let savedSettings = decodeUserSettings()
            companyName = savedSettings.companyName
            startShift = savedSettings.startShift
            endShift = savedSettings.endShift
            workOnWeekends = savedSettings.workOnWeekend
            workOnSaturday = savedSettings.saturday
            startInSaturday = savedSettings.startInSaturday
            endInSaturday = savedSettings.endInSaturday
            workOnSunday = savedSettings.sunday
            startInSunday = savedSettings.startInSunday
            endInSunday = savedSettings.endInSunday
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
        }
        
        func requestNotificationPermission() {
            Task {
                await notificationCenter.requestNotificationPermission()
            }
        }
        
         func checkAuthorizationStatus() {
            Task {
                btnTitle =  await notificationCenter.checkAuthorizationStatus()
            }
        }
    }
}
