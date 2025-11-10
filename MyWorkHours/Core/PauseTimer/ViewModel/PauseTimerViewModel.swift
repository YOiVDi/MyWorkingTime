//
//  PauseTimerViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 22.01.24.
//

import Combine
import SwiftUI
import CoreData

enum PredefinedTimer: Int, CaseIterable {
    case zero = 0
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case twentyMinutes = 20
    case twentyFiveMinutes = 25
    case thirtyMinutes = 30
}

extension PauseTimerScreen {
    @MainActor
    class PauseTimerViewModel: ObservableObject {
        // MARK: - Public Propeties
        @Published var hours = 0
        @Published var minutes = 0
        @Published var seconds = 0
        @Published var predefinedTimer: PredefinedTimer = .zero
        @Published var alert: CustomAlerts? = nil
        
        // MARK: - Only Readable Properties Private(set)
        @Published private(set) var elapsedTime: TimeInterval = 0
        @Published private(set) var overElapsedTime: TimeInterval = 0
        @Published private(set) var isStarted = false
        @Published private(set) var isStopped = false
        @Published private(set) var isTimerRunning = false
        
        
        
        
        // MARK: - Private Properties
        private let persistenceController: PersistenceController
        private let scenePhaseHandler = ScenePhaseHandler()
        private let timerManager: TimerManager
        private var cancellables: Set<AnyCancellable> = []
        private var scenePhase: ScenePhase
        
        // MARK: - Initialization
        init(timerManager: TimerManager, persistenceController: PersistenceController = .shared) {
            self.persistenceController = persistenceController
            self.timerManager = timerManager
            self.scenePhase = .active
            self.subscribeToTimerManager()
        }
        
        // MARK: - UI Computed Properties
        /// Trimming of circle is based on elapsedTime
        var trimProgress: CGFloat {
            return timerManager.elapsedTime == 0 ?  (timerManager.timer != nil && timerManager.elapsedTime == 0 ? 1 : 0) : 1 - (timerManager.elapsedTime / timerManager.elapsedTimeFrom)
        }
        
        
        /// Changes the color of the timer circle depending on what state it is currently in
        var timerCircleColor: Color {
            if timerManager.timer == nil {
                return Color.gray.opacity(0.5)
            } else if timerManager.timer != nil && timerManager.elapsedTime == 0 {
                return Color.red
            }
            return Color.blue
        }
        
        
        /// Start button is disabled in certain conditions
        var disableStart: Bool {
            if hours == 0 && minutes == 0 && seconds == 0 {
                return true
            }
            return false
        }
        
        // MARK: - UI Methods
        
        /// Formatting from timeInterval or Double into minutes, seconds.
        /// - Parameter timeInterval: take timeInterval or Double
        /// - Returns: return formatted time.
        func formatTime(_ timeInterval: TimeInterval) -> String {
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        func predifenedTimerSelected() {
            switch predefinedTimer {
            case .zero: hours = 0; minutes = 0; seconds = 0
            case .fiveMinutes: hours = 0; minutes = 5; seconds = 0
            case .tenMinutes: hours = 0; minutes = 10; seconds = 0
            case .fifteenMinutes: hours = 0; minutes = 15; seconds = 0
            case .twentyMinutes: hours = 0; minutes = 20; seconds = 0
            case .twentyFiveMinutes: hours = 0; minutes = 25; seconds = 0
            case .thirtyMinutes: hours = 0; minutes = 30; seconds = 0
            }
            timerManager.setTimer(hours, minutes, seconds)
        }
        
        // MARK: - App State
        func handleScenePhaseChange(_ newScenePhase: ScenePhase) {
            switch newScenePhase {
            case .active:
                scenePhaseHandler.handleActiveScenePhase(
                    timerRunning: isTimerRunning,
                    isStarted: timerManager.isStarted,
                    dateInBackground: timerManager.dateInBackground,
                    elapsedTime: timerManager.elapsedTime,
                    resumeTimer: { [weak self] in self?.resumeTimer() },
                    pauseTimeCalculate: { [weak self] in self?.timerManager.pauseTimeCalculate() },
                    setActiveDate: { [weak self] in self?.timerManager.dateInActiveMode = $0 }
                )
                print("ScenePhase: Active")
            case .background:
                scenePhaseHandler.handleBackgroundScenePhase(
                    timerRunning: isTimerRunning,
                    setBackgroundDate: { [weak self] in self?.timerManager.dateInBackground = $0 },
                    stopTimer: { [weak self] in self?.stopTimer(.lifecycle) },
                    setStopped: { [weak self] in self?.timerManager.isStopped = $0 },
                    setStarted: { [weak self] in self?.timerManager.isStarted = $0 }
                )
                print("ScenePhase: Background")
            default:
                break
            }
         }
        
        
        // MARK: - Timer Methods
        
        func startTimer() {
            timerManager.startTimer(hours, minutes, seconds)
        }
        func stopTimer(_ stopIntention: StopIntention) {
            timerManager.stopTimer(stopIntention)
        }
        func resetTimer() {
            timerManager.resetTimer()
        }
        func resumeTimer() {
            timerManager.resumeTimer()
        }
        
        private func subscribeToTimerManager() {
            // mirror manager's @Published values
            timerManager.$elapsedTime
                .assign(to: &$elapsedTime)
            timerManager.$overElapsedTime
                .assign(to: &$overElapsedTime)
            timerManager.$isStarted
                .assign(to: &$isStarted)
            timerManager.$isStopped
                .assign(to: &$isStopped)
            timerManager.$alert
                .assign(to: &$alert)
            
            // computed example
            timerManager.$timer
                .map { $0 != nil }
                .assign(to: &$isTimerRunning)
        }
    }
}
