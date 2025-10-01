//
//  SettingsViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 17.01.24.
//

import SwiftUI
import Combine

enum UserDefaultsKeys: String, CaseIterable {
    case firstWorkSettings = "userSettings"
    case secondWorkSettings = "secondUserSettings"
}

extension SettingsView {
    @MainActor class SettingsViewModel: ObservableObject {
        @Published var alert: CustomAlerts? = nil
        @Published var btnTitle: LocalizedStringKey = ""
        @Published var firstWorkSettings: UserSettings = UserSettings()
        @Published var secondWorkSettings: UserSettings = UserSettings()
        
        /// Private properties
        private var cancellables = Set<AnyCancellable>()
        private let notificationServices: NotificationCenterServices
        private let userDefaultsStore: UserDefaultsStore
        
        
        /// Pause properties array
        let pauseTime: [Int] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]
        
        
        // MARK: - Initialization
        
        init(_ servicesContainer: ServiceContainerProtocol) {
            self.userDefaultsStore = servicesContainer.userDefaultsService
            self.notificationServices = servicesContainer.notificationCenterServices
            setRetrievedData()
            debouncing()
            checkAuthorizationStatus()
        }
        
        
        // MARK: - Methods
        
        ///  Ask user for premission to send notifications
        func requestNotificationPermission() {
            Task {
                await notificationServices.requestNotificationPermission()
            }
        }
        
        /// Check if user allow, or denied to receive notifications
         func checkAuthorizationStatus() {
            Task {
                btnTitle =  await notificationServices.checkAuthorizationStatus()
            }
        }
        // MARK: - Private Methods
        
        /// Save user settings in to UserDefaults
        private func saveUserSettings() {
            do {
                try userDefaultsStore.set(firstWorkSettings, forKey: UserDefaultsKeys.firstWorkSettings.rawValue)
            } catch {
                print("Cannot encode your settings: \(error.localizedDescription).")
            }
        }

        /// Retrieve user settings from UserDefaults
        private func setRetrievedData() {
            let defaultData = UserSettings()
            do {
                let savedSettings =  try userDefaultsStore.get(UserSettings.self, forKey: UserDefaultsKeys.firstWorkSettings.rawValue, defaultData)
                firstWorkSettings = savedSettings
            } catch {
                print("UserSettings cannot be retrieve: \(error.localizedDescription).")
            }
        }
        
        /// Debouncing data, so after typing or changing data will be saved once after 2 seconds
        private func debouncing() {
            $firstWorkSettings
                .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.saveUserSettings()
                    print("User Company: \(self?.firstWorkSettings.companyName ?? "")")
                }
                .store(in: &cancellables)
        }
    }
}
