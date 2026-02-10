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
    @StateObject var userStatusManager: UserStatusStore
    @StateObject private var purchaseViewModel: PurchaseViewModel
    private let persistenceController: PersistenceController = PersistenceController.shared
    private let servicesContainer: ServicesContainer
    
    var body: some Scene {
        WindowGroup {
            MainAppView(servicesContainer, userStatusManager)
                .environmentObject(settings)
                .environmentObject(purchaseViewModel)
                .environment(\.managedObjectContext, servicesContainer.persistenceController.container.viewContext)
        }
    }
    
    init() {
        let services = ServicesContainer(persistenceController: persistenceController)
        self.servicesContainer = services
        let userStatusManager = UserStatusStore(userDefaultsStore: services.userDefaultsService)
        self._userStatusManager = StateObject(wrappedValue: userStatusManager)
        self._purchaseViewModel = StateObject(wrappedValue: PurchaseViewModel(userStatusManager: userStatusManager))
        _settings = StateObject(wrappedValue: SettingsView.SettingsViewModel(services, userStatusManager))
    }
}
