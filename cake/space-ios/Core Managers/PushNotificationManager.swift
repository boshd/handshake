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
                print("NOTIFICATIONS PRESMISSION GRANTED")
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
        guard let currentUserID = Auth.auth().currentUser?.uid, Messaging.messaging().fcmToken != userDefaults.currentStringObjectState(for: userDefaults.fcmToken) else { print("stuck in between return"); return }
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
//
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        userDefaults.updateObject(for: userDefaults.fcmToken, with: fcmToken)
        updateFirestorePushTokenIfNeeded()
    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        handleResponse(response)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//        let userInfo = notification.request.content.userInfo
//        guard let messageDict = userInfo["message"] as? [String : AnyObject] else { return }
//        let message = Message(dictionary: messageDict)
//        switch UIApplication.shared.applicationState {
//        case .active:
//            completionHandler([])
//        case .background:
//            if let fromId = message.fromId  {
//                if fromId == currentUserID {
//                    completionHandler([])
//                } else {
//                    completionHandler([.list, .banner, .sound])
//                }
//            } else {
//                completionHandler([.list, .banner, .sound])
//            }
//        case .inactive:
//            if let fromId = message.fromId  {
//                if fromId == currentUserID {
//                    completionHandler([])
//                } else {
//                    completionHandler([.list, .banner, .sound])
//                }
//            } else {
//                completionHandler([.list, .banner, .sound])
//            }
//
//        }
//
////        if UIApplication.shared.applicationState == .active {
////            completionHandler([])
////        }
////
////        if let fromId = message.fromId  {
////            print("current \(currentUserID)")
////            print("from \(fromId)")
////
////            if fromId == currentUserID {
////                completionHandler([])
////            } else {
////                completionHandler([.alert, .badge, .sound])
////            }
////        }
//    }
//
//    fileprivate func handleResponse(_ response: UNNotificationResponse) {
//
//        print("NOTIFICATIONS ARRIVED WHILE CLOSED, HERE'S WHAT YOU MISSED: ")
//        print("response", response)
//        print("response.notification", response.notification)
//        print("response.actionIdentifier", response.actionIdentifier)
//
////        switch response.actionIdentifier {
////        case UNNotificationDismissActionIdentifier: // Notification was dismissed by user
////            break
////        case UNNotificationDefaultActionIdentifier: // App was opened from notification
//////            print(response.notification.request.content.userInfo)
////            let info = response.notification.request.content.userInfo
//////            if let messageDictionary = info["message"] as? [String: AnyObject] {
//////                let message = Message(dictionary: messageDictionary)
//////                if tabBarController != nil {
//////                    guard let channelID = message.toId,
//////                          let realmChannels = channelsController?.theRealmChannels,
//////                          let channel = RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: channelID),
//////                          UIApplication.topViewController() is ChannelsController
//////                    else { return }
//////
//////                    var indexPath_: IndexPath
//////                    if realmChannels.contains(channel) {
//////                        if let index = realmChannels.firstIndex(where: {$0 === channel}) {
//////                            indexPath_ = IndexPath(row: index, section: 0)
//////                            pushToChannel(indexPath: indexPath_)
//////                        }
//////                    } else {
//////                        return
//////                    }
//////
//////                }
//////
//////            }
////
////        case "ReplyAction":
////            if let textResponse = response as? UNTextInputNotificationResponse {
////                let replyText = textResponse.userText
////                let userInfo = response.notification.request.content.userInfo
////                if let channelId = userInfo["channelID"] {
////                    let channel = RealmKeychain.defaultRealm.objects(Channel.self).filter("id = '\(channelId)'").first
////                    let messageSender = MessageSender(channel, text: replyText)
////                    messageSender.sendMessage()
////                }
////            }
////        default:
////            break
////        }
//    }
//
//    func pushToChannel(indexPath: IndexPath) {
//        //channelsController?.channelsContainerView.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//        //channelsController?.channelsContainerView.tableView.delegate?.tableView!((channelsController?.channelsContainerView.tableView)!, didSelectRowAt: indexPath)
//    }
//
//    func handleNotification(notification: [AnyHashable : Any]) {
//        print("jermlgemrer/qn/n/\n\n\n\n")
//        //guard let aps = notification["aps"] else { return }
//        //print(aps)
//    }
    
}
