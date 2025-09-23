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
    
    let persistenceController: PersistenceController
    
    var body: some View {
        TabView {
                WorkingDaysView(persistenceController: persistenceController)
                    .tabItem {
                        Label("List", systemImage: "list.bullet.circle")
                    }
                PauseTimerView()
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
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    return WorkDaysTabView(persistenceController: persistenceController)
        .environmentObject(SettingsView.SettingsViewModel())
}
