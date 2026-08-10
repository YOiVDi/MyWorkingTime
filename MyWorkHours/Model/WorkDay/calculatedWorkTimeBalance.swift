//
//  calculatedOvertimeBalance.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 31.05.26.
//

import Foundation

extension WorkDay {
    
    func calculateWorktimeBlance(_ firstSettings: UserSettings, _ secondWorkSettings: UserSettings) -> String {
        
        let matchingSettings = (self.companyName == firstSettings.companyName) ? firstSettings : secondWorkSettings
        
        // User-defined working hours in settings.
        let workTimeDefinedInSettings = workingHoursAtTheDay(userSettings: matchingSettings)
        // Calculation of the time between check-in and check-out, if available.
        let timeIntervalSinceCheckIn = timeIntervalSinceCheckIn()
        // Subtracting the actual time worked for the day from the user's predefined working hours in the settings.
        let finalCalc = timeIntervalSinceCheckIn - workTimeDefinedInSettings
        
        print("Since Check In \(timeIntervalSinceCheckIn), Work Time in Settings \(workTimeDefinedInSettings), Difference: \(finalCalc)")
        // Return result as String.
        return WorkTimeConverter.convertSecondToTime(finalCalc, true)
        
    }
    
    // Checking for working time either is weekend or work day base on date of the day.
    private func workingHoursAtTheDay(userSettings: UserSettings) -> Int {
        let weekday = DateHelper.weekday(from: self.date)
        var dayWorkingHours = 0.0
        
        if DateHelper.isSunday(weekday) {
            let timeIntervalSinceCheckIn = userSettings.endInSunday.timeIntervalSince(userSettings.startInSunday)
            let pause = DateHelper.minuteComponentInSeconds(userSettings.pauseSunday)
            dayWorkingHours = timeIntervalSinceCheckIn - Double(pause)
        } else if DateHelper.isSaturday(weekday) {
            let timeIntervalSinceCheckIn = userSettings.endInSaturday.timeIntervalSince(userSettings.startInSaturday)
            let pause = DateHelper.minuteComponentInSeconds(userSettings.pauseSaturday)
            dayWorkingHours = timeIntervalSinceCheckIn - Double(pause)
        } else {
            let timeIntervalSinceCheckIn = userSettings.endShift.timeIntervalSince(userSettings.startShift)
            let pause = DateHelper.minuteComponentInSeconds(userSettings.pause)
            dayWorkingHours = timeIntervalSinceCheckIn - Double(pause)
        }
        
        print("WorkingHours: \(Int(dayWorkingHours))")
        return Int(dayWorkingHours)
   }
    
    // Checking timeinterval since check-out and check-in, then return as Int
    private func timeIntervalSinceCheckIn() -> Int {
        guard let checkIn = self.checkIn, let checkOut = self.checkOut else { return 0}
        let timeIntervalSinceCheckIn = Int(checkOut.timeIntervalSince(checkIn))
        let timeIntervalSinceCheckInAndPauses = timeIntervalSinceCheckIn - pausesInterval()
        return timeIntervalSinceCheckInAndPauses
    }
    
    // Iterate over all pauses add them together in defined property, and return as Int
    private func pausesInterval() -> Int {
        var pausesInterval = 0
        for pause in self.pause {
            pausesInterval += Int(pause.finishPause.timeIntervalSince(pause.startPause))
        }
        
        return pausesInterval
    }
}
