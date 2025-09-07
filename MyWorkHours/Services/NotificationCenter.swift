//
//  NotificationManager.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 06.06.24.
//

import Foundation
import UserNotificationsUI
import SwiftUI

class NotificationCenter {
    
    /// Adding notification to NotificationCenter
    func addNotification(timeInterval: Double, title: String, subtitle: String, identifier: String) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = title            
            content.subtitle = subtitle
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
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
    func deleteNotification(identifier: [String]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifier)
    }
    
//    func checkNotificationExists(identifier: String, completion: @escaping (Bool) -> Void) {
//        UNUserNotificationCenter.current().getDeliveredNotifications { requests in
//            let exists = requests.contains(where: {$0.request.identifier == identifier})
//            completion(exists)
//        }
//    }
}
