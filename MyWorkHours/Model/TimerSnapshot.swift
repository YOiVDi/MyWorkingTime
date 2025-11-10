//
//  TimerSnapshot.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 01.11.25.
//

import Foundation

struct TimerSnapshot: Codable {
    let beginPause: Date
    let duration: TimeInterval
    let isStarted: Bool
//    var version: Int = 1
}

