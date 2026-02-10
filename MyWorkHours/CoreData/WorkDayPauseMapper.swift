//
//  File.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 19.01.26.
//

import Foundation

struct WorkDayPauseMapper {
    
    static func mapToDto(_ pauses: [Pause]) -> [WorkDayPause] {
        var pauseArr: [WorkDayPause] = []
        for pause in pauses {
            pauseArr.append(WorkDayPause(id: pause.identifier ?? "", startPause: pause.startPause ?? .distantFuture, finishPause: pause.finishPause ?? .distantFuture))
        }
        return pauseArr
    }
    
    static func mapToRepositoryObject(_ pauses: [WorkDayPause]) -> [Pause] {
        let context = PersistenceController.shared.container.viewContext
        let entity: Pause = Pause(context: context)
        var convertedPauses: [Pause] = []
        
        for pause in pauses {
            entity.identifier = pause.id
            entity.startPause = pause.startPause
            entity.finishPause = pause.finishPause
            convertedPauses.append(entity)
        }
        return convertedPauses
    }
 }
