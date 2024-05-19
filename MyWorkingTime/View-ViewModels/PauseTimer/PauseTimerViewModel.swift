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
        @Published private(set) var elapsedTimeFrom: Double = 0
        @Published private(set) var elapsedTime: TimeInterval = 0
        @Published var hours = 0
        @Published var minutes = 0
        @Published var seconds = 0
        @Published var isStopped = false
        @Published var isStarted = false
        
        let pauseTimes: [Int] = [5, 10, 15, 20, 25, 30] // at moment not in use
        let persistenceController = PersistenceController.shared
        
        private var timer: Timer?
        
        private(set) var dateInBackground: Date?
        private(set) var dateInActiveMode: Date?
        
        private(set) var beginPause: Date?
        private(set) var finishPause: Date?
        
        // MARK: - Computed properties
        // trimming of circle is based on elapsedTime
        var trimProgress: CGFloat {
            return elapsedTime == 0 ?  (timer != nil && elapsedTime == 0 ? 1 : 0) : 1 - (elapsedTime / elapsedTimeFrom)
        }
        
        
        /// changes the color of the timer circle depending on what state it is currently in
        var timerCircleColor: Color {
            if timer == nil {
                return Color.gray.opacity(0.5)
            } else if timer != nil && elapsedTime == 0 {
                return Color.red
            }
            return Color.blue
        }
        
        
        /// start button is disabled in certain conditions
        var disableStart: Bool {
            if hours == 0 && minutes == 0 && seconds == 0 {
                return true
            }
            return false
        }
         
        // MARK: - Init
        
        init() {
            
        }
        
        // MARK: - Methods
        
        /// checks if the timer is currently running or not
        func isTimerRunning() -> Bool {
            return timer != nil
        }
        
        /// gives a initial value of timer and activate it
        func startTimer() {
            self.isStarted = true
            self.beginPause = Date()
            addNotification()
            DispatchQueue.main.asyncAfter(deadline: .now() + elapsedTimeFrom, execute: finishPauseTime)
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if elapsedTime == 0 {
                    stopTimer()
                } else {
                    self.elapsedTime -= 1
                }
            }
        }
        
        ///  invalidate timer
        func stopTimer() {
            isStopped = true
            isStarted = false
            timer?.invalidate()
            deleteNotification()
        }
        
        /// reset the timer to its initial state
        func resetTimer() {
            stopTimer()
            isStarted = false
            isStopped = false
            dateInBackground = nil
            dateInActiveMode = nil
            elapsedTime = elapsedTimeFrom
            timer = nil
            deleteNotification()
        }
        /// allows the timer to resume from where it was last stopped
        func resumeTimer() {
            isStarted = true
            isStopped = false
            guard elapsedTime != 0 else { return }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if elapsedTime == 0 {
                    stopTimer()
                } else {
                    self.elapsedTime -= 1
                }
            }
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
        
        
        /// Calculate difference between start and stop pause to keep timer circle accurate.
        func pauseTimeCalculate() {
            // Calculate the time difference
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute, .second], from: dateInBackground ?? Date.now, to: dateInActiveMode ?? Date.now)

            // Extract the components
            let minutes = components.minute ?? 0
            let seconds = components.second ?? 0
            
            // calc minute in seconds
            let minInSeconds = minutes * 60
            // add minute in seconds to seconds
            let calcSeconds = seconds + minInSeconds
            
            // Check if the calculated time difference exceeds elapsedTime
             if elapsedTime >= Double(calcSeconds) {
                 // Subtract the calculated time difference from elapsedTime
                 elapsedTime -= Double(calcSeconds)
             } else {
                 elapsedTime = 0
             }
        }
        
        /// Setting the timer duration
        func setTimer() {
            let hourToSeconds = (hours * 60) * 60
            let minuteToSeconds = minutes * 60
            let seconds = seconds
            let pauseDuration = hourToSeconds + minuteToSeconds + seconds
            
            elapsedTimeFrom = Double(pauseDuration)
            elapsedTime = elapsedTimeFrom
        }
        
        // Add pause to day if exist.
        func addPause() {
            let workingDaysList = PersistenceController.shared.fetchRequest(filter: nil, sortBy: nil)
            let date = Date()
            let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)

            // Find the first WorkingDay object with the specified date
            if let matchingDay = workingDaysList.first(where: { workingDay in
                let workingDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: workingDay.wrappedDate)
                return workingDayComponents.year == targetComponents.year &&
                       workingDayComponents.month == targetComponents.month &&
                       workingDayComponents.day == targetComponents.day
            }) {
                guard let beginPause, let finishPause else { return }
                let dayPause = Pause(context: persistenceController.container.viewContext)
                dayPause.startPause = beginPause
                dayPause.finishPause = finishPause
                matchingDay.addToPause(dayPause)
                // for test purpose
                print("\(matchingDay.arrPause)")
            } else {
                // for test purpose
                // No matching object found
                print("No WorkingDay object found for \(date).")
            }
        }
        
        // Set finish pause time
        func finishPauseTime() {
            guard let beginPause else { return }
            finishPause = beginPause.addingTimeInterval(elapsedTimeFrom)
            // for test purpose
            print("start: \(beginPause), finish: \(String(describing: self.finishPause))")
            if timer != nil {
                addPause()
                persistenceController.save()
            }
        }
        
        
        /// Adding notification to NotificationCenter
        func addNotification() {
            let center = UNUserNotificationCenter.current()
            
            // setup notification
            let addRequest = {
                let content = UNMutableNotificationContent()
                content.title = "🤯 Pause is over"
                content.subtitle = "Your break started at \(String(describing: self.beginPause?.formatted(date: .abbreviated, time: .shortened))), and ended now \(String(describing: self.finishPause?.formatted(date: .abbreviated, time: .shortened))) total break time  \(self.formatTime(self.elapsedTimeFrom))"
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: self.elapsedTimeFrom, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
            // check if permission is granted
            center.getNotificationSettings { settings in
                // if permission is granted, then call addRequest() - set notification
                if settings.authorizationStatus == .authorized {
                    addRequest()
                } else { // else asking for premision.
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            addRequest()
                        } else if let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        /// if timer doesn't work or is on pause remove notification request
        func deleteNotification() {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
        
        /// it's handle logic for Active scene phase
        func handleActiveScenePhase() {
            if dateInBackground != nil {
                dateInActiveMode = Date()
            }
            
            // for test purpose
            print("Background: stopPause: \(String(describing: dateInActiveMode))")
            
            // If the timer is running, elapsedTime is greater than 0, and isStart == false, resume the timer.
            // If we have captured the date when the app goes into the background (i.e., it is not nil),
            // run pauseTimeCalculate, which calculates the time between when we went into the background
            // and returned to active mode, then subtract that from elapsedTime.
            
            if (isTimerRunning() && elapsedTime > 0) && isStarted == false {
                resumeTimer()
                if dateInBackground != nil {
                    pauseTimeCalculate()
                }
            }
        }
        
        
        ///  it's handle logic for Background scene phase
        func handleBackgroundScenePhase() {
            
            if isTimerRunning() {
                dateInBackground = Date()
                timer?.invalidate()
                isStopped = true
                isStarted = false
                
                // for test purpose
                print("Background: startPause: \(String(describing: dateInBackground))")
            }
        }
    }
}
