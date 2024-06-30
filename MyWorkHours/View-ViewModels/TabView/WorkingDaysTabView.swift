//
//  TabView.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 20.03.24.
//

import CoreData
import SwiftUI

struct WorkingDaysTabView: View {
    
    let persistenceController: PersistenceController
    
    var body: some View {
        TabView {
            Group {
                WorkingDaysView(persistenceController: persistenceController)
                    .tabItem {
                        Label("List", systemImage: "list.bullet.circle")
                    }
                PauseTimerView()
                    .tabItem {
                        Label("Pause Timer", systemImage: "clock")
                    }
                NavigationView {
                    SettingsView()
                }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .toolbar(.visible, for: .tabBar)
        }
        .navigationViewStyle(.stack)
    }
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    return WorkingDaysTabView(persistenceController: persistenceController)
        .environmentObject(SettingsView.SettingsViewModel())
}
