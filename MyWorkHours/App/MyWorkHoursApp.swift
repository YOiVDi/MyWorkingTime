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
    @StateObject var userStatusStore: UserStatusStore
    @StateObject private var purchaseViewModel: PurchaseViewModel
    private let persistenceController: PersistenceController = PersistenceController.shared
    private let servicesContainer: ServicesContainer
    
    var body: some Scene {
        WindowGroup {
            MainAppView(servicesContainer, userStatusStore)
                .environmentObject(settings)
                .environmentObject(purchaseViewModel)
                .environment(\.managedObjectContext, servicesContainer.persistenceController.container.viewContext)
        }
    }
    
    init() {
        let services = ServicesContainer(persistenceController: persistenceController)
        self.servicesContainer = services
        let userStatusStore = UserStatusStore(userDefaultsStore: services.userDefaultsService)
        self._userStatusStore = StateObject(wrappedValue: userStatusStore)
        self._purchaseViewModel = StateObject(wrappedValue: PurchaseViewModel(userStatusStore: userStatusStore))
        _settings = StateObject(wrappedValue: SettingsView.SettingsViewModel(services, userStatusStore))
    }
}
