//
//  MyWorkHoursApp.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 13.05.24.
//

import SwiftUI

@main
struct MyWorkHoursApp: App {
    @StateObject var settings = SettingsView.SettingsViewModel()
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(settings)
        }
    }
}
