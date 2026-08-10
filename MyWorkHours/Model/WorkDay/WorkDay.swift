//
//  WorkDay.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 19.01.26.
//

import Foundation

struct WorkDay: Identifiable, Equatable, Hashable {
    let id: UUID
    var companyName: String
    let date: Date
    var workHours: Int
    var checkIn: Date?
    var checkOut: Date?
    var pause: [WorkDayPause]
    var workedTime: Int
    
    
    
    
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(checkIn)
    }
    
    static let mock = WorkDay(id: UUID(), companyName: "YourCompany", date: Date(), workHours: 5, pause: [WorkDayPause(id: UUID().uuidString, startPause: .now, finishPause: .now)], workedTime: 9)
}
