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
    @ObservedObject var userStatusStore: UserStatusStore
    @StateObject var timerStore: TimerStore
    
    var body: some View {
        TabView {
            WorkDaysScreen(userStatusStore: userStatusStore, servicesContainer: servicesContainer)
                    .tabItem {
                        Label("List", systemImage: "list.bullet.circle")
                    }
            PauseTimerScreen(timerStore: timerStore)
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
    
    init(_ servicesContainer: ServicesContainer, userStatusStore: UserStatusStore) {
        self.servicesContainer = servicesContainer
        self._userStatusStore = ObservedObject(wrappedValue: userStatusStore)
        _timerStore = StateObject(wrappedValue: TimerStore(workingDaysQueryService: servicesContainer.workingDaysQueryService, workingDayPauseService: servicesContainer.workingDayPauseService, userDefaultsStore: servicesContainer.userDefaultsService, notificationCenterServices: servicesContainer.notificationCenterService))
    }
}

#Preview {
    WorkDaysTabView(ServicesContainer(persistenceController: PersistenceController.shared), userStatusStore: UserStatusStore(userDefaultsStore: UserDefaultsStore()))
        .environmentObject(SettingsView.SettingsViewModel(ServicesContainer(persistenceController: PersistenceController.shared), UserStatusStore(userDefaultsStore: UserDefaultsStore())))
}
