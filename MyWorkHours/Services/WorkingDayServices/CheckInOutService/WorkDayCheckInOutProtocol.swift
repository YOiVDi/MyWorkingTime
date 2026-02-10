//
//  WorkDayCheckInOutProtocol.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 25.01.26.
//

import Foundation

protocol WorkDayCheckInOutProtocol {
    func handleCheckIn(_ day: inout WorkDay, workingDaysList: inout [WorkDay])
    func handleCheckOut(_ day: inout WorkDay, workingDaysList: inout [WorkDay])
    func assingDayForCheckInCheckOut(for workChoice: UserDefaultsKeys, _ userSettings: UserSettings) -> WorkDay?
}
