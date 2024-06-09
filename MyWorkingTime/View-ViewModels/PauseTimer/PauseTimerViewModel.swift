//
//  PauseTimerViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 22.01.24.
//

import UserNotifications
import SwiftUI

extension PauseTimerView {
    class PauseTimerViewModel: ObservableObject {
        // MARK: - Public propeties
        @Published var hours = 0
        @Published var minutes = 0
        @Published var seconds = 0
        @Published var alert: CustomAlerts? = nil
        
        let pauseTimes: [Int] = [5, 10, 15, 20, 25, 30] // at moment not in use
        
        // MARK: - Private Properties
        @Published private(set) var elapsedTimeFrom: Double = 0
        @Published private(set) var elapsedTime: TimeInterval = 0
        @Published private(set) var overElapsedTime: TimeInterval = 0
        @Published private(set) var isStopped = false
        @Published private(set) var isStarted = false
        
        /// Handle time in when app went into Background mode and went back in Active mode
        private(set) var dateInBackground: Date?
        private(set) var dateInActiveMode: Date?
        
        // Handle when pause start and finish of pause
        private(set) var beginPause: Date?
        private(set) var finishPause: Date? 
        
        private let persistenceController = PersistenceController.shared
        private let notificationManager = NotificationManager()
        private let pauseManager = PauseManager()
        private let scenePhaseHandler = ScenePhaseHandler()
        
        /// Timer property
        private var timer: Timer?
        
        
        // MARK: - Initialization
        
        init() {}
        
        // MARK: - Computed properties
        /// Trimming of circle is based on elapsedTime
        var trimProgress: CGFloat {
            return elapsedTime == 0 ?  (timer != nil && elapsedTime == 0 ? 1 : 0) : 1 - (elapsedTime / elapsedTimeFrom)
        }
        
        
        /// Changes the color of the timer circle depending on what state it is currently in
        var timerCircleColor: Color {
            if timer == nil {
                return Color.gray.opacity(0.5)
            } else if timer != nil && elapsedTime == 0 {
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
        
        /// Checks if the timer is currently running or not
        var isTimerRunning: Bool {
            return timer != nil
        }
        
        // MARK: - Public Methods
        
        /// Gives a initial value of timer and activate it
        func startTimer() {
            guard doesTodayExist() != nil else { return }
            setTimer()
            isStarted = true
            beginPause = Date()
            addNotification()
            activateTimer()
        }
        
        /// Setting the timer duration
        func setTimer() {
            let hourToSeconds = (hours * 60) * 60
            let minuteToSeconds = minutes * 60
            let seconds = seconds
            let pauseDuration = hourToSeconds + minuteToSeconds + seconds
            
            elapsedTimeFrom = Double(pauseDuration)
            print("set timer: \(elapsedTimeFrom)")
            elapsedTime = elapsedTimeFrom
        }
        
        ///  Invalidate timer
        func stopTimer() {
            isStopped = true
            isStarted = false
            timer?.invalidate()
            notificationManager.deleteNotification()
        }
        
        /// Reset the timer to its initial state
        func resetTimer() {
            timer?.invalidate()
            finishPauseTime()
            isStarted = false
            isStopped = false
            dateInBackground = nil
            dateInActiveMode = nil
            elapsedTime = elapsedTimeFrom
            timer = nil
            overElapsedTime = 0
            notificationManager.deleteNotification()
        }
        
        /// Allows the timer to resume from where it was last stopped
        func resumeTimer() {
            isStarted = true
            isStopped = false
            activateTimer()
            addNotification()
        }
        
        
        /// Formatting from timeInterval or Double into minutes, seconds.
        /// - Parameter timeInterval: take timeInterval or Double
        /// - Returns: return formatted time.
        func formatTime(_ timeInterval: TimeInterval) -> String {
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        func handleScenePhaseChange(_ newScenePhase: ScenePhase) {
            switch newScenePhase {
            case .active:
                scenePhaseHandler.handleActiveScenePhase(
                    timerRunning: isTimerRunning,
                    isStarted: isStarted,
                    dateInBackground: dateInBackground,
                    elapsedTime: elapsedTime,
                    resumeTimer: resumeTimer,
                    pauseTimeCalculate: pauseTimeCalculate,
                    setActiveDate: { self.dateInActiveMode = $0 }
                )
            case .background:
                scenePhaseHandler.handleBackgroundScenePhase(
                    timerRunning: isTimerRunning,
                    setBackgroundDate: { self.dateInBackground = $0 },
                    stopTimer: { self.timer?.invalidate() },
                    setStopped: { self.isStopped = $0 },
                    setStarted: { self.isStarted = $0 }
                )
            default:
                break
            }
         }
        
        
        // MARK: - Private Methods
        
        private func activateTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.elapsedTime == 0 {
                    self.overElapsedTime += 1
                } else {
                    self.elapsedTime -= 1
                }
            }
        }
        
        /// Calculate difference between start and stop pause to keep timer circle accurate.
        private func pauseTimeCalculate() {
            // Calculate the time difference
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: dateInBackground ?? Date.now, to: dateInActiveMode ?? Date.now)

            // Extract the components
            let minutes = components.minute ?? 0
            let seconds = components.second ?? 0
            
            // Calc minute in seconds
            let minInSeconds = minutes * 60
            // Add minute in seconds to seconds
            let calcSeconds = seconds + minInSeconds
            
            // Check if the calculated time difference exceeds elapsedTime
             if elapsedTime >= Double(calcSeconds) {
                 // Subtract the calculated time difference from elapsedTime
                 elapsedTime -= Double(calcSeconds)
             } else {
                 if elapsedTime != 0 { 
                     // If elapseTime is not equal to 0, subtract elapsedTime from calcSeconds
                     // Reminder add to overElapsedTime
                     overElapsedTime = Double(calcSeconds) - elapsedTime
                     elapsedTime = 0
                 } else {
                     overElapsedTime += Double(calcSeconds)
                 }
             }
        }
        
        private func doesTodayExist() -> WorkingDay? {
            let workingDaysList = PersistenceController.shared.fetchRequest(filter: nil, sortBy: nil)
            let date = Date()
            let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            
            guard let matchingDay = workingDaysList.first(where: { workingDay in
                let workingDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: workingDay.wrappedDate)
                return workingDayComponents == targetComponents
            }) else {
                alert = .pauseWillBeNotAdded
                return nil
            }
            return matchingDay
        }
        
       // Set finish pause time
        private func finishPauseTime() {
            finishPause = pauseManager.finishPauseTime(beginPause: beginPause, elapsedTimeFrom: elapsedTimeFrom, overElapsedTime: overElapsedTime, persistenceController: persistenceController, workingDay: doesTodayExist())
        }
        private func addNotification() {
            if elapsedTime != 0 {
                notificationManager.addNotification(elapsedTime)
                print("add Notification")
            }
        }
    }
}
