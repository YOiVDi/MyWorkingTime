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
    @StateObject var settings: SettingsView.SettingsViewModel
    private let servicesContainer: ServiceContainerProtocol
    
    var body: some Scene {
        WindowGroup {
            MainAppView(persistenceController: servicesContainer.persistenceController)
                .environmentObject(settings)
                .environment(\.managedObjectContext, servicesContainer.persistenceController.container.viewContext)
        }
    }
    
    init() {
        let services = ServiceContainer()
        self.servicesContainer = services
        _settings = StateObject(wrappedValue: SettingsView.SettingsViewModel(services))
    }
}
