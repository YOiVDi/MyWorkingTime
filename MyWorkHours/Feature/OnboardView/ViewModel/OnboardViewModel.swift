//
//  OnboardViewModel.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 10.06.24.
//

import Foundation
import SwiftUI

    @MainActor class OnboardViewModel: ObservableObject {
        
        @Published private(set) var onboardItems: [OnboardItem] = []
        @Published var tabBarSelection = 0
        @Published private(set) var finishOnboarding = false
        @Published private(set) var isAlreadySetup: Bool = UserDefaults.standard.bool(forKey: "isAlreadySetup")
        @Published var initSettings: UserSettings = UserSettings()
//        
        private let initSecondWork: UserSettings = .init()
        
        private let userDefaultsStore: UserDefaultsStore
        private let userSettingsStore: UserSettingsStore
        
        
        init(userDefaultsStore: UserDefaultsStore, userSettingsStore: UserSettingsStore) {
            self.userDefaultsStore = userDefaultsStore
            self.userSettingsStore = userSettingsStore
            setDefaultTime()
            checkAndSetOnbordingStatus()
//            load()
        }
        
        func finishOnBording() {
            finishOnboarding = true
            try? userDefaultsStore.set(finishOnboarding, forKey: "isOnboarding")
            userSettingsStore.saveUserSettings(initSettings, initSecondWork)
        }
        
        private func setDefaultTime() {
            if !isAlreadySetup {
                var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
                dateComponents.hour = 7
                dateComponents.minute = 0
                initSettings.startShift = Calendar.current.date(from: dateComponents) ?? Date()
                dateComponents.hour = 15
                dateComponents.minute = 15
                initSettings.endShift = Calendar.current.date(from: dateComponents) ?? Date()
                dateComponents.hour = 0
                dateComponents.minute = 30
                initSettings.pause = Calendar.current.date(from: dateComponents) ?? Date()
            }
        }
        
        
        
        
        // MARK: - This is for old Onboarding
        
        func nextPage() {
            if tabBarSelection < onboardItems.count - 1 {
                    tabBarSelection += 1
            }
        }
        
        private func checkAndSetOnbordingStatus() {
            do {
                finishOnboarding = try userDefaultsStore.get(Bool.self, forKey: "isOnboarding", false)
                print("Do: \(finishOnboarding)")
            } catch {
                finishOnboarding = false
                print("catch: \(finishOnboarding)")
            }
        }
        
        private func load() {
            onboardItems = [
                .init(image: Image(systemName: "pencil.and.list.clipboard"), title: "Just One Click", content: "Easily log today as a working day or choose a specific date, all with just a few clicks on your smartphone."),
                .init(image: Image(systemName: "timer"), title: "Pause Timer", content: "Set your timer durations and enjoy your pauses. Just before your pause ends, you'll receive a notification. If you accidentally extend your pause by talking or getting distracted, no worries—the application will track and report this extra time."),
                .init(image: Image(systemName: "gear"), title: "Work On Weekends", content: "Need to work on weekends? No problem. You can choose different working hours for the weekend. Whether you need to adjust the schedule for Saturday, Sunday, or both days, we've got you covered."),
            ]
        }
    }
