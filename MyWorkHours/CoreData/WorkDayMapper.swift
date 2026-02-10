//
//  WorkDayMapper.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 19.01.26.
//

import Foundation

struct WorkDayMapper {
    static func mapToDto(_ day: WorkingDay) -> WorkDay {
        let arrPause = (day.pauses as? Set<Pause> ?? [])
            .sorted { $0.wrappedStartPause < $1.wrappedStartPause }
        return WorkDay(id: day.id ?? UUID(), companyName: day.companyName ?? "", date: day.date ?? .now, workHours: Int(day.workingHours), checkIn: day.checkIn ?? nil, checkOut: day.checkOut ?? nil, pause: WorkDayPauseMapper.mapToDto(arrPause), workedTime: Int(day.workedTime))
    }
    
    static func mapToRepositoryObject(_ object: WorkDay) -> WorkingDay {
        let context = PersistenceController.shared.container.viewContext
        let entity: WorkingDay = WorkingDay(context: context)
        
        entity.id = object.id
        entity.date = object.date
        entity.companyName = object.companyName
        entity.checkIn = object.checkIn
        entity.checkOut = object.checkOut
        entity.workingHours = Int16(object.workHours)
        entity.workedTime = Int64(object.workedTime)
        entity.pauses = NSSet(array: WorkDayPauseMapper.mapToRepositoryObject(object.pause))
        
        return entity
    }
}
