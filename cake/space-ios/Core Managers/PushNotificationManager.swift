//
//  PushNotificationManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-12.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (granted, error) in
                guard granted else { return }
                let replyAction = UNTextInputNotificationAction(identifier: "ReplyAction", title: "Reply", options: [])
                let openAppAction = UNNotificationAction(identifier: "OpenAppAction", title: "Open app", options: [.foreground])
                let quickReplyCategory = UNNotificationCategory(identifier: "QuickReply", actions: [replyAction, openAppAction], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([quickReplyCategory])

                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    
                }
            })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
    }
    
    
    // deprecated ios 10
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("CALLED application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler")
    }
    
    // reprecated ios 10
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("CALLED application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]")
    }
    
    // post ios 10 (include ios10), requires delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("CALLED userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification")
        
        // should not notify in-app
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("CALLED userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse")
    }
    
    /*
     
     - app open, recieves message: willPresent
     
     - app running in background, recieves message: didReceive
     
     - app running in background, receives message, quick reply: didReceive
     
     - app killed, push arrived, in app notification still received
     
     */
    
//    func registerForPushNotifications() {
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().delegate = self
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (granted, error) in
//                guard granted else { return }
//                let replyAction = UNTextInputNotificationAction(identifier: "ReplyAction", title: "Reply", options: [])
//                let openAppAction = UNNotificationAction(identifier: "OpenAppAction", title: "Open app", options: [.foreground])
//                let quickReplyCategory = UNNotificationCategory(identifier: "QuickReply", actions: [replyAction, openAppAction], intentIdentifiers: [], options: [])
//                UNUserNotificationCenter.current().setNotificationCategories([quickReplyCategory])
//
//                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//                    print("notification settings: ", settings)
//                }
//            })
//            // For iOS 10 data message (sent via FCM)
//            Messaging.messaging().delegate = self
//        } else {
//            let settings: UIUserNotificationSettings =
//            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            UIApplication.shared.registerUserNotificationSettings(settings)
//        }
//
//        UIApplication.shared.registerForRemoteNotifications()
//        updateFirestorePushTokenIfNeeded()
//    }
//
    func updateFirestorePushTokenIfNeeded() {
        guard let currentUserID = Auth.auth().currentUser?.uid, Messaging.messaging().fcmToken != userDefaults.currentStringObjectState(for: userDefaults.fcmToken) else { return }
        if let token = Messaging.messaging().fcmToken {
            userDefaults.updateObject(for: userDefaults.fcmToken, with: token)
            let fcmTokensCurrentUserReference = Firestore.firestore().collection("fcmTokens").document(currentUserID)
            let batch = Firestore.firestore().batch()
            batch.setData(["fcmToken":token], forDocument: fcmTokensCurrentUserReference, merge: true)
            batch.commit { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    return
                }
            }
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        userDefaults.updateObject(for: userDefaults.fcmToken, with: fcmToken)
        updateFirestorePushTokenIfNeeded()
    }
    
}
