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
        @Published var showPremiumView: Bool = false

        
        var userStatus: UserStatus {
            userStatusStore.userStatus
        }
        
        /// Private properties
        private var cancellables = Set<AnyCancellable>()
        private let notificationServices: NotificationCenterServices
        private let userDefaultsStore: UserDefaultsStore
        
        // Stores
        private let userStatusStore: UserStatusStore
        private let userSettingsStore: UserSettingsStore

        
        
        /// Pause properties array
        let pauseTime: [Int] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45]
        
        
        // MARK: - Initialization
        
        init(_ servicesContainer: ServicesContainer, _ userStatusStore: UserStatusStore) {
            self.userDefaultsStore = servicesContainer.userDefaultsService
            self.notificationServices = servicesContainer.notificationCenterService
            self.userStatusStore = userStatusStore
            self.userSettingsStore = servicesContainer.userSettingsStore
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
            userSettingsStore.saveUserSettings(firstWorkSettings, secondWorkSettings)
        }

        /// Retrieve user settings from UserDefaults
        private func setRetrievedData() {
            self.firstWorkSettings = userSettingsStore.firstWorkSettings
            self.secondWorkSettings = userSettingsStore.secondWorkSettings
        }
        
        /// Debouncing data, so after typing or changing data will be saved once after 2 seconds
        private func debouncing() {
            Publishers.CombineLatest($firstWorkSettings, $secondWorkSettings)
                .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.saveUserSettings()
                    print("User First Company: \(self?.firstWorkSettings.companyName ?? "")")
                    print("User Second Company: \(self?.secondWorkSettings.companyName ?? "")")
                }
                .store(in: &cancellables)
        }
    }
}
