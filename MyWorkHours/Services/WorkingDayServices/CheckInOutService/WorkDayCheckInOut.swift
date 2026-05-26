//
//  WorkDayCheckInOut.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 25.01.26.
//

import Foundation

final class WorkDayCheckInOut: WorkDayCheckInOutProtocol {
    
    private let workingDaysQuery: WorkingDaysQueryServiceProtocol
    
    init(workingDaysQuery: WorkingDaysQueryServiceProtocol) {
        self.workingDaysQuery = workingDaysQuery
    }
    
    func handleCheckIn(_ day: inout WorkDay, workingDaysList: inout [WorkDay]) {
        day.checkIn = Date.now
        workingDaysQuery.update(day)
        if let index = workingDaysList.firstIndex(where: {$0.id == day.id}) {
            workingDaysList[index] = day
        }
    }
    
    func handleCheckOut(_ day: inout WorkDay, workingDaysList: inout [WorkDay]) {
        day.checkOut = Date.now
        day.workedTime = Int(day.checkOut?.timeIntervalSince(day.checkIn!) ?? 0)
        workingDaysQuery.update(day)
        if let index = workingDaysList.firstIndex(where: {$0.id == day.id}) {
            workingDaysList[index] = day
        }
    }
    
    
    func assingDayForCheckInCheckOut(for workChoice: UserDefaultsKeys, _ userSettings: UserSettings) -> WorkDay? {
        guard workChoice == .firstWorkSettings || workChoice == .secondWorkSettings else {
            return nil
        }
        
        return isExistDaysWithTodayDate().first {
            $0.companyName == userSettings.companyName
        }
    }
    
    private func isExistDaysWithTodayDate() -> [WorkDay] {
        var mappedWorkDay: [WorkDay] = []
        let days = workingDaysQuery.fetchOnDate(on: Date.now)
        for day in days {
            let mapDay = WorkDayMapper.mapToDto(day)
            mappedWorkDay.append(mapDay)
        }
        return mappedWorkDay
   }
}
