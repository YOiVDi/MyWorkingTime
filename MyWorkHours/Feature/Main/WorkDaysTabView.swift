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
    @ObservedObject var userStatusManager: UserStatusStore
    @StateObject var timerManager: TimerManager
    
    var body: some View {
        TabView {
            WorkDaysScreen(userStatusManager: userStatusManager, servicesContainer: servicesContainer)
                    .tabItem {
                        Label("List", systemImage: "list.bullet.circle")
                    }
            PauseTimerScreen(timerManager: timerManager)
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
    
    init(_ servicesContainer: ServicesContainer, userStatusManager: UserStatusStore) {
        self.servicesContainer = servicesContainer
        self._userStatusManager = ObservedObject(wrappedValue: userStatusManager)
        _timerManager = StateObject(wrappedValue: TimerManager(workingDaysQueryService: servicesContainer.workingDaysQueryService, workingDayPauseService: servicesContainer.workingDayPauseService, userDefaultsStore: servicesContainer.userDefaultsService, notificationCenterServices: servicesContainer.notificationCenterService))
    }
}

#Preview {
    WorkDaysTabView(ServicesContainer(persistenceController: PersistenceController.shared), userStatusManager: UserStatusStore(userDefaultsStore: UserDefaultsStore()))
        .environmentObject(SettingsView.SettingsViewModel(ServicesContainer(persistenceController: PersistenceController.shared), UserStatusStore(userDefaultsStore: UserDefaultsStore())))
}
