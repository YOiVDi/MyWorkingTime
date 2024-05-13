//
//  TabView.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 20.03.24.
//

import SwiftUI

struct WorkingDaysTabView: View {
    var body: some View {
        TabView {
            WorkingDaysView()
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
    }
}

#Preview {
    WorkingDaysTabView()
}
