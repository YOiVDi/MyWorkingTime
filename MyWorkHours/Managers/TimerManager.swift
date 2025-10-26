//
//  TimerServices.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 25.09.25.
//

import Foundation

class TimerManager: ObservableObject {
    
    // MARK: - Publish Properties
    @Published var isStopped = false
    @Published var isStarted = false
    
    /// Handle time in when app went into Background mode and went back in Active mode
    var dateInActiveMode: Date?
    var dateInBackground: Date?
    
    // MARK: - Private Properties
    @Published private(set) var timer: Timer?
    @Published private(set) var elapsedTimeFrom: Double = 0
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var overElapsedTime: TimeInterval = 0
    @Published private(set) var alert: CustomAlerts? = nil
    
    // Handle when pause start and finish of pause
    private(set) var beginPause: Date?
    private(set) var finishPause: Date?
    
    private var timerNotificationSet = false
    private let notification = NotificationCenterServices()
    private let persistenceController: PersistenceController
    
    
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    // MARK: - Public Methods
    
    /// Gives a initial value of timer and activate it
    func startTimer(_ hours: Int, _ minutes: Int, _ seconds: Int) {
        guard !isExistDaysWithTodayDate().isEmpty else {
            alert = .pauseWillBeNotAdded
            return
        }
        setTimer(hours, minutes, seconds)
        isStarted = true
        beginPause = Date()
        activateTimer()
    }
    
    /// Setting the timer duration
    func setTimer(_ hours: Int, _ minutes: Int, _ seconds: Int) {
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
        var processCompletedCount = UserDefaults.standard.integer(forKey: "processCompletedCount")
        isStopped = true
        isStarted = false
        finishPause = .now
        timer?.invalidate()
        notification.deleteNotification(identifier: ["timer"])
        processCompletedCount += 1
        UserDefaults.standard.set(processCompletedCount, forKey: "processCompletedCount")
        print("CountUsage: \(processCompletedCount)")
    }
    
    /// Reset the timer to its initial state
    func resetTimer() {
        timer?.invalidate()
        addPause()
        isStarted = false
        isStopped = false
        dateInBackground = nil
        dateInActiveMode = nil
        elapsedTime = elapsedTimeFrom
        timer = nil
        overElapsedTime = 0
        notification.deleteNotification(identifier: ["timer"])
        timerNotificationSet = false
    }
    
    /// Allows the timer to resume from where it was last stopped
    func resumeTimer() {
        isStarted = true
        isStopped = false
        activateTimer()
    }
    
    /// Calculate difference between start and stop pause to keep timer circle accurate.
    func pauseTimeCalculate() {
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
                 overElapsedTime = Double(calcSeconds) - elapsedTime
                 elapsedTime = 0
             } else {
                 // add background time to overElapsedTime
                 overElapsedTime += Double(calcSeconds)
             }
         }
    }
    
    // MARK: - Private Methods
    
    private func activateTimer() {
        scheduleBreakNotification()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.elapsedTime == 0 {
                self.overElapsedTime += 1
            } else {
                self.elapsedTime -= 1
            }
        }
    }
    
    /// If a working day exists, a pause will be added
     private func addPause() {
         if let workDay = determinatedWhichWork() {
             guard let beginPause = beginPause, let finishPause = finishPause else { return }
             persistenceController.addPause(workingDay: workDay, identifier: String(Date().formatted(date: .omitted, time: .standard)), beginPause, finishPause)
         }
     }
    
    /// Search for a workday/workdays whose date is equal to today's date, and return them as array of WorkingDays
    private func isExistDaysWithTodayDate() -> [WorkingDay] {
        let workingDaysList = PersistenceController.shared.fetchRequest(sortBy: nil)
       let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
       var workDays: [WorkingDay] = []
       for day in workingDaysList {
           let workDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: day.wrappedDate)
           if targetComponents == workDayComponents {
               workDays.append(day)
           }
       }
       return workDays
   }
    
    /// Check which work has CheckIn time, and doesn't have CheckOut time. Base on those requirements determined to which day must be add pause from current timer.
    private func determinatedWhichWork() -> WorkingDay? {
        var workDay: WorkingDay?
        for day in isExistDaysWithTodayDate() {
            if day.checkIn != nil && day.checkOut == nil {
                workDay = day
            }
        }
        return workDay
    }
    
    /// Schedules a notification one minute before the break ends when the user starts the timer.
    private func scheduleBreakNotification() {
        guard !timerNotificationSet && elapsedTimeFrom >= 120 else { return }
        if elapsedTime != 0 {
            notification.addNotification(timeInterval: elapsedTimeFrom - 60, title: String(localized: "⏱️ One minute left until your break ends❗️"), subtitle: String(localized: "If you don't stop the timer, overtime will begin."), identifier: "timer")
            print("add Notification")
            timerNotificationSet = true
        }
    }
}
