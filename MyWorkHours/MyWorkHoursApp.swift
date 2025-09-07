//
//  MyWorkHoursApp.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 13.05.24.
//

import CoreData
import SwiftUI

@main
struct MyWorkHoursApp: App {
    @StateObject var settings = SettingsView.SettingsViewModel()
    private let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            MainAppView(persistenceController: persistenceController)
                .environmentObject(settings)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
