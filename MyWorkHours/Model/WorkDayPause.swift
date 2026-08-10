//
//  WorkDayPause.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 31.05.26.
//

import Foundation

struct WorkDayPause: Identifiable, Equatable, Hashable {
    let id: String
    var startPause: Date
    var finishPause: Date
}
