//
//  NotificationManager.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 06.06.24.
//

import Foundation
import UserNotificationsUI

class NotificationManager {
    
    /// Adding notification to NotificationCenter
    func addNotification(_ timeInterval: Double) {
        guard timeInterval > 60  else { return }
        let notificationTime = timeInterval - 60
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
//            content.title = timeInterval >= 120 ? "⏱️ Your break will end in one minute" : "⏱️ Your break is over"
            content.title = "⏱️ One minute left until you finish the break"
//            content.subtitle = timeInterval >= 120 ? "If you don't stop the timer, time will start to run in overtime" : "You are now on overtime break."
            content.subtitle = "If you don't stop the timer, time will start to run in overtime"
            content.sound = UNNotificationSound.default
            
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval >= 120 ? (timeInterval - 60) : timeInterval, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notificationTime, repeats: false)
            
            let request = UNNotificationRequest(identifier: "RunTimer", content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    /// Delete notification
    func deleteNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["RunTimer"])
    }
}
