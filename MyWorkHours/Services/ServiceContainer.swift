//
//  ServiceContainer.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 30.09.25.
//

import Foundation

protocol ServiceContainerProtocol {
    var userDefaultsService: UserDefaultsStore { get }
    var persistenceController: PersistenceController { get }
    var notificationCenterServices: NotificationCenterServices { get }
}

final class ServiceContainer: ServiceContainerProtocol {
    let notificationCenterServices = NotificationCenterServices()
    let userDefaultsService = UserDefaultsStore()
    let persistenceController = PersistenceController.shared
}
