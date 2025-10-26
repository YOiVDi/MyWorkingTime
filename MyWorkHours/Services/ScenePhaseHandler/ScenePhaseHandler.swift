//
//  ScenePhaseHandler.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 06.06.24.
//

import Foundation

@MainActor
final class ScenePhaseHandler {
    func handleActiveScenePhase(timerRunning: Bool, isStarted: Bool, dateInBackground: Date?, elapsedTime: TimeInterval, resumeTimer: @escaping () -> Void, pauseTimeCalculate: @escaping () -> Void, setActiveDate: @escaping (Date) -> Void) {
        if dateInBackground != nil {
            setActiveDate(Date())
        }
        
        if timerRunning && !isStarted {
            resumeTimer()
            if dateInBackground != nil {
                pauseTimeCalculate()
            }
        }
    }
    
    func handleBackgroundScenePhase(timerRunning: Bool, setBackgroundDate: @escaping (Date) -> Void, stopTimer: @escaping () -> Void, setStopped: @escaping (Bool) -> Void, setStarted: @escaping (Bool) -> Void) {
        if timerRunning {
            setBackgroundDate(Date())
            stopTimer()
            setStopped(true)
            setStarted(false)
        }
    }
}
