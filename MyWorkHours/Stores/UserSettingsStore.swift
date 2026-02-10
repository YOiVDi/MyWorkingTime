//
//  UserSettings.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 09.02.26.
//

import Foundation

final class UserSettingsStore: ObservableObject {
    @Published private(set) var firstWorkSettings: UserSettings = .init()
    @Published private(set) var secondWorkSettings: UserSettings = .init()
    
    private let userDefaultsStore: UserDefaultsStore
    
    init(userDefaultsStore: UserDefaultsStore) {
        self.userDefaultsStore = userDefaultsStore
        fetchUserSettings()
    }
    
    
    private func fetchUserSettings() {
        guard let userSettings = UserDefaults.standard.data(forKey: UserDefaultsKeys.firstWorkSettings.rawValue) else { return }
        guard let secondUserSettings = UserDefaults.standard.data(forKey: UserDefaultsKeys.secondWorkSettings.rawValue) else { return }
        
        do {
            self.firstWorkSettings = try JSONDecoder().decode(UserSettings.self, from: userSettings)
            self.secondWorkSettings = try JSONDecoder().decode(UserSettings.self, from: secondUserSettings)
        } catch {
            print("Failed to decode user settings data:", error.localizedDescription)
            return
        }
        
        print("fetch usersettings")
    }
    
    
    func saveUserSettings(_ firstWorkSettings: UserSettings, _ secondWorkSettings: UserSettings) {
        do {
            try userDefaultsStore.set(firstWorkSettings, forKey: UserDefaultsKeys.firstWorkSettings.rawValue)
            try userDefaultsStore.set(secondWorkSettings, forKey: UserDefaultsKeys.secondWorkSettings.rawValue)
        } catch {
            print("Cannot encode your settings: \(error.localizedDescription).")
        }
        fetchUserSettings()
    }
}
