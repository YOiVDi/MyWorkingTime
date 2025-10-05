//
//  ServicesContainer.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 30.09.25.
//

import Foundation

// do something in future
protocol ServicesContainerProtocol {
    var userDefaultsService: UserDefaultsStore { get }
    var persistenceController: PersistenceController { get }
    var notificationCenterService: NotificationCenterServices { get }
}

final class ServicesContainer: ServicesContainerProtocol {
    let notificationCenterService = NotificationCenterServices()
    let userDefaultsService = UserDefaultsStore()
    let persistenceController = PersistenceController.shared
}
