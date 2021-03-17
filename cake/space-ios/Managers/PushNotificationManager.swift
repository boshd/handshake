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

        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    
    func updateFirestorePushTokenIfNeeded() {
        print(Messaging.messaging().fcmToken)
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

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleResponse(response)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userInfo = notification.request.content.userInfo
        guard let messageDict = userInfo["message"] as? [String : AnyObject] else { return }
        let message = Message(dictionary: messageDict)
        switch UIApplication.shared.applicationState {
        case .active:
            completionHandler([])
        case .background:
            if let fromId = message.fromId  {
                if fromId == currentUserID {
                    completionHandler([])
                } else {
                    completionHandler([.list, .banner, .sound])
                }
            } else {
                completionHandler([.list, .banner, .sound])
            }
        case .inactive:
            if let fromId = message.fromId  {
                if fromId == currentUserID {
                    completionHandler([])
                } else {
                    completionHandler([.list, .banner, .sound])
                }
            } else {
                completionHandler([.list, .banner, .sound])
            }
            
        }
        
//        if UIApplication.shared.applicationState == .active {
//            completionHandler([])
//        }
//
//        if let fromId = message.fromId  {
//            print("current \(currentUserID)")
//            print("from \(fromId)")
//
//            if fromId == currentUserID {
//                completionHandler([])
//            } else {
//                completionHandler([.alert, .badge, .sound])
//            }
//        }
    }
    
    fileprivate func handleResponse(_ response: UNNotificationResponse) {
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier: // Notification was dismissed by user
            break
        case UNNotificationDefaultActionIdentifier: // App was opened from notification
//            print(response.notification.request.content.userInfo)
            let info = response.notification.request.content.userInfo
            if let messageDictionary = info["message"] as? [String: AnyObject] {
                let message = Message(dictionary: messageDictionary)
                if channelsController != nil {
                    guard let channelID = message.toId,
                          let realmChannels = channelsController?.theRealmChannels,
                          let channel = RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: channelID),
                          UIApplication.topViewController() is ChannelsController
                    else { return }
                    
                    var indexPath_: IndexPath
                    if realmChannels.contains(channel) {
                        if let index = realmChannels.firstIndex(where: {$0 === channel}) {
                            indexPath_ = IndexPath(row: index, section: 0)
                            pushToChannel(indexPath: indexPath_)
                        }
                    } else {
                        return
                    }
                
                }
                
            }
            
        case "ReplyAction":
            if let textResponse = response as? UNTextInputNotificationResponse {
                let replyText = textResponse.userText
                let userInfo = response.notification.request.content.userInfo
                if let channelId = userInfo["channelID"] {
                    let channel = RealmKeychain.defaultRealm.objects(Channel.self).filter("id = '\(channelId)'").first
                    let messageSender = MessageSender(channel, text: replyText)
                    messageSender.sendMessage()
                }
            }
        default:
            break
        }
    }
    
    func pushToChannel(indexPath: IndexPath) {
        channelsController?.channelsContainerView.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        channelsController?.channelsContainerView.tableView.delegate?.tableView!((channelsController?.channelsContainerView.tableView)!, didSelectRowAt: indexPath)
    }
    
    func handleNotification(notification: [AnyHashable : Any]) {
        //guard let aps = notification["aps"] else { return }
        //print(aps)
    }
    
}
