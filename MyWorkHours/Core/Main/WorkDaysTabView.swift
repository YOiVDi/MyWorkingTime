//
//  TabView.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 20.03.24.
//

import CoreData
import SwiftUI
import StoreKit

struct WorkDaysTabView: View {
    
    let servicesContainer: ServicesContainer
    @ObservedObject var userStatusManager: UserStatusManager
    @StateObject var timerManager: TimerManager
    
    var body: some View {
        TabView {
            WorkDaysScreen(persistenceController: servicesContainer.persistenceController, userStatusManager: userStatusManager)
                    .tabItem {
                        Label("List", systemImage: "list.bullet.circle")
                    }
            PauseTimerView(timerManager: timerManager, persistenceController: servicesContainer.persistenceController)
                    .tabItem {
                        Label("Pause Timer", systemImage: "clock")
                    }
                    SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
        }
        .navigationViewStyle(.stack)
    }
    
    init(_ servicesContainer: ServicesContainer, userStatusManager: UserStatusManager) {
        self.servicesContainer = servicesContainer
        self._userStatusManager = ObservedObject(wrappedValue: userStatusManager)
        _timerManager = StateObject(wrappedValue: TimerManager(persistenceController: servicesContainer.persistenceController))
    }
}

#Preview {
    let servicesContainer = ServicesContainer()
    let userStatusManager = UserStatusManager()
    WorkDaysTabView(servicesContainer, userStatusManager: userStatusManager)
        .environmentObject(SettingsView.SettingsViewModel(servicesContainer, userStatusManager))
}
