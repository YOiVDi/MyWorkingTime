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
        @Published private(set) var finishOnboarding = UserDefaults.standard.bool(forKey: "isOnboarding")
//        @Published private(set) var finishOnboarding = false // for test purpose
        @Published var tabBarSelection = 0
        
        
        init() {
            load()
        }
        
        func isOnboarding() {
            finishOnboarding = true
            UserDefaults.standard.set(finishOnboarding, forKey: "isOnboarding")
        }
        
        func nextPage() {
            if tabBarSelection < onboardItems.count - 1 {
                    tabBarSelection += 1
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
