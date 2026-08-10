//
//  WorkTimeServices.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 22.10.25.
//

import Foundation


struct WorkTimeConverter {
    
    // Convert seconds in time and return as string in HH:MM:SS format.
    static func convertSecondToTime(_ seconds: Int, _ showSeconds: Bool) -> String {
        let sign = seconds < 0 ? "-" : ""
        let total = abs(seconds)
        
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        let strTime = showSeconds ? String(format: "\(sign)%02d:%02d:%02d", hours, minutes, secs) : String(format: "\(sign)%02d:%02d", hours, minutes)
        return strTime
    }
    
    // Calculate all pause and return as Int
    static func calculatePauseInSeconds(_ workDay: WorkingDay) -> Int {
        var pauseInterval = 0 // Initialize a variable to accumulate the total pause duration
        
        // Check if there are any pauses recorded in the model's array of pauses
        if workDay.arrPause.count != 0 {
            
            // Iterate over each pause in the array
            for pause in workDay.arrPause {
                
                // Calculate the duration of the current pause
                let pauseTime = pause.wrappedFinishPause.timeIntervalSince(pause.wrappedStartPause)
                
                // Add the rounded duration of the current pause to the total pause interval
                pauseInterval += Int(round(pauseTime))
            }
        }
        
        // Return the total duration of all pauses in seconds
        return pauseInterval
    }
}
