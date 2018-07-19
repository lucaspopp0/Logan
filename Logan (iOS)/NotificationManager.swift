//
//  NotificationManager.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/13/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import Foundation
import UserNotifications
import NotificationCenter

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    func requestAuthorization(_ completionHandler: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: completionHandler)
    }
    
    func confirmAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                self.requestAuthorization({ (authorizationGranted, error) in
                    DispatchQueue.main.async {
                        if let authorizationError = error {
                            Console.shared.print("Error authorizing notifications: \(authorizationError.localizedDescription)")
                        }
                    }
                })
            }
        }
    }
    
    func scheduleAllReminders() {
        cancelAllNotifications()
        
        var allReminders: [Reminder] = []
        
        for assignment in DataManager.shared.assignments {
            allReminders.append(contentsOf: assignment.reminders)
        }
        
        addNotificationsForReminders(allReminders)
    }
    
    func addNotificationForReminder(_ reminder: Reminder) {
        scheduleNotificationRequest(reminder.notificationRequest())
    }
    
    func addNotificationsForReminders(_ reminders: [Reminder]) {
        for reminder in reminders {
            addNotificationForReminder(reminder)
        }
    }
    
    func cancelNotificationsForReminders(_ reminders: [Reminder]) {
        var identifiers: [String] = []
        
        for reminder in reminders {
            identifiers.append(reminder.identifier)
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func scheduleNotificationRequest(_ request: UNNotificationRequest) {
        UNUserNotificationCenter.current().add(request) { (error) in
            if let notificationError = error {
                Console.shared.print("Error scheduling notification.\nTitle: \(request.content.title)\nMessage: \(request.content.body)\nError: \(notificationError.localizedDescription)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let responseInfo = response.notification.request.content.userInfo
            
            if let assignmentRecordName = responseInfo["Assignment Record Name"] as? String {
                Swift.print(assignmentRecordName)
            }
        }
        
        completionHandler()
    }
    
}
