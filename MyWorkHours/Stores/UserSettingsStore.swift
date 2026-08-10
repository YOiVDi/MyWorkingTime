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
        firstWorkSettings = loadSettings(key: .firstWorkSettings)
        secondWorkSettings = loadSettings(key: .secondWorkSettings)
    }
    
    private func loadSettings(key: UserDefaultsKeys) -> UserSettings {
        do {
            return try userDefaultsStore.get(UserSettings.self, forKey: key.rawValue, UserSettings())
        } catch {
            print("Failed to load \(key.rawValue): \(error.localizedDescription)")
            return UserSettings()
        }
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
