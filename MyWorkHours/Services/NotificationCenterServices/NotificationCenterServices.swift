//
//  NotificationManager.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 06.06.24.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationCenterServices {
    
    private let center = UNUserNotificationCenter.current()
    
    /// Schedules a local notification after a given time interval.
    /// - Parameters:
    ///   - timeInterval: Delay in seconds before the notification is delivered.
    ///   - title: The main title of the notification.
    ///   - subtitle: The subtitle of the notification.
    ///   - identifier: Unique identifier for this notification request.
    func addNotification(timeInterval: Double, title: String, subtitle: String, identifier: String) {
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            self.center.add(request)
        }
        
        self.center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    /// Deletes pending notifications with the given identifiers.
    /// - Parameter identifier: An array of notification identifiers to remove.
    func deleteNotification(identifier: [String]) {
        self.center.removePendingNotificationRequests(withIdentifiers: identifier)
        print("Notification with ID: \(identifier) has been delete.")
    }
    
    
    /// Requests notification permission from the user.
    /// - If the current status is `.notDetermined`, the system prompt will be shown.
    /// - For all other cases, the user is redirected to the app's Settings page
    ///   so they can review or change their notification preferences.
    ///
    /// - Note: This approach ensures users always have a way to change their decision
    ///   even after initially granting or denying permissions.
    func requestNotificationPermission() async {
        let settings = await self.center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                try await self.center.requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                print("Requsting notification permission failed: \(error.localizedDescription)")
            }
        default:
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    
    /// Checks the current notification authorization status.
    /// - Returns: A string label describing the status (for use as a button title).
    func checkAuthorizationStatus() async -> LocalizedStringKey {
        var status: LocalizedStringKey = ""
        let settings = await self.center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized:
            status = LocalizedStringKey("Turn off")
        case .denied:
            status = LocalizedStringKey("Turn on") 
        default:
            status = LocalizedStringKey("Turn on") 
        }
        print("Status : \(status)")
        return status
    }
}
