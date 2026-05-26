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
    var workDaysService: WorkingDaysServicesProtocol { get }
    var workingDayPauseService: WorkingDayPauseProtocol { get }
    var workingDaysQueryService: WorkingDaysQueryServiceProtocol { get }
    var workDayCheckInOutService: WorkDayCheckInOutProtocol { get }
    var userSettingsStore: UserSettingsStore { get }
}

final class ServicesContainer: ServicesContainerProtocol {
    // MARK: - CoreDate controller
    let persistenceController: PersistenceController
    
    // MARK: -  Store's
    let userSettingsStore: UserSettingsStore
    
    // MARK: - Services
    let notificationCenterService: NotificationCenterServices
    let userDefaultsService: UserDefaultsStore
    let workDaysService: WorkingDaysServicesProtocol
    let workingDayPauseService: WorkingDayPauseProtocol
    let workingDaysQueryService: WorkingDaysQueryServiceProtocol
    let workDayCheckInOutService: WorkDayCheckInOutProtocol
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.notificationCenterService = NotificationCenterServices()
        self.userDefaultsService = UserDefaultsStore()
        self.workingDaysQueryService = WorkingDaysQueryService(persistenceController: persistenceController)
        self.workingDayPauseService = WorkingDayPauseService(persistenceController: persistenceController, workingDaysQueryServices: workingDaysQueryService)
        self.workDaysService = WorkingDaysService(queryService: workingDaysQueryService, persistenceController: persistenceController)
        self.workDayCheckInOutService = WorkDayCheckInOut(workingDaysQuery: workingDaysQueryService)
        self.userSettingsStore = UserSettingsStore(userDefaultsStore: userDefaultsService)
    }
}
