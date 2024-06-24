//
//  PauseManager.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 06.06.24.
//

import Foundation

import Foundation
import CoreData

class PauseManager {
    
    private let persistenceController = PersistenceController.shared
    
    private func addPause(beginPause: Date?, finishPause: Date?, workingDay: WorkingDay) {
        guard let beginPause = beginPause, let finishPause = finishPause else { return }
        let dayPause = Pause(context: persistenceController.container.viewContext)
        dayPause.identifier = String(Date().formatted(date: .omitted, time: .standard))
        dayPause.startPause = beginPause
        dayPause.finishPause = finishPause
        workingDay.addToPauses(dayPause)
        persistenceController.save()
    }
    
    func finishPauseTime(beginPause: Date?, elapsedTimeFrom: Double, overElapsedTime: Double, persistenceController: PersistenceController, workingDay: WorkingDay?) -> Date? {
        guard let beginPause = beginPause else { return nil }
        let finishPause = beginPause.addingTimeInterval(elapsedTimeFrom + overElapsedTime)
        if workingDay != nil {
            addPause(beginPause: beginPause, finishPause: finishPause, workingDay: workingDay!)
        }
        return finishPause
    }
}
