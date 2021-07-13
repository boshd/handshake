//
//  InAppNotificationManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-16.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import AudioToolbox
import SafariServices

class InAppNotificationManager: NSObject {
    
    fileprivate var notificationReference: CollectionReference!
    fileprivate var listener: ListenerRegistration?
    fileprivate var channels = [Channel]()
    fileprivate var individualChannelListenersDict: [String:ListenerRegistration] = [String:ListenerRegistration]()
    
    func updateChannels(to channels: [Channel]) {
        self.channels = channels
    }
    
//    @objc func handleChannelAdded(_ notification: Notification) {
//        guard let obj = notification.object as? [String: Any], let addedChannelID = obj["channelID"] as? String else { return }
        
//        if self.channels.map({ $0.id }).contains(removedChannelID) {
//        if individualChannelListenersDict[addedChannelID] == nil {
//            var first = true
//            notificationReference = Firestore.firestore().collection("channels").document(addedChannelID).collection("thread")
//            let listener = notificationReference.order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
//                guard let documents = querySnapshot?.documents else {
//                    print("error // ", error!)
//                    return
//                }
//
//                if documents.count > 0 { // if channel thread isn't empty
//                    let document = documents[0]
//
//                    if (first) {
//                        first = false
//                        return
//                    }
//
//                    let messageID = document.documentID
//
//                    var dictionary = document.data()
//                    dictionary.updateValue(messageID as AnyObject, forKey: "messageUID")
//
//                    let message = Message(dictionary: dictionary as [String : AnyObject])
//                    guard let uid = Auth.auth().currentUser?.uid, message.fromId != uid else { return }
//                    let tmpChannels = Array(self.channels)
////                    guard let channel = tmpChannels.first(where: { $0.id == addedChannelID }) else { return }
////
////
////                    self.handleInAppSoundPlaying(message: message, channel: channel, channels: self.channels)
//                }
//            }
//
//            individualChannelListenersDict[addedChannelID] = listener
//            print("\(individualChannelListenersDict.count) // \(addedChannelID) // listener added")
//        }
//        }
//    }
    
//    @objc func handleChannelRemovedDiff(_ notification: Notification) {
//        guard let obj = notification.object as? [String: Any], let removedChannelID = obj["channelID"] as? String else { return }
        
////        if self.channels.map({ $0.id }).contains(removedChannelID) {
//            if let _ = individualChannelListenersDict[removedChannelID] {
//                individualChannelListenersDict[removedChannelID]?.remove()
//                if let index = individualChannelListenersDict.firstIndex(where: { (k, v) -> Bool in
//                    return k == removedChannelID
//                }) {
//                    individualChannelListenersDict.remove(at: index)
//                }
//                print("\(individualChannelListenersDict.count) // \(removedChannelID) // listener removed")
//            }
//        }
//    }
   
    public func removeAllObservers() {
//        channels.removeAll()
        if !individualChannelListenersDict.isEmpty {
            for (_, listener) in individualChannelListenersDict {
                listener.remove()
            }
        }
    }
    
    func observersForNotifications(channels: [Channel]) {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelRemovedDiff), name: .channelRemoved, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelAdded), name: .channelAdded, object: nil)
        removeAllObservers()
        updateChannels(to: channels)
        for channel in self.channels {
            guard let currentUserID = Auth.auth().currentUser?.uid, let channelID = channel.id else { continue }
            
            guard channel.participantIds.contains(currentUserID) else { return }
            
            var first = true
            notificationReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID).collection("messageIds")
            let listener = notificationReference.addSnapshotListener { (querySnapshot, error) in
                guard error == nil else {
                    print("error // ", error!)
                    return
                }
                
                // if the snapshot is older than current session
                
                if (first) {
                    first = false
                    return
                }
                
                guard let changes = querySnapshot?.documentChanges else { return }
                changes.forEach { (diff) in
                    if diff.type == .added {
                        let messageID = diff.document.documentID
                        
                        Firestore.firestore().collection("messages").document(messageID).getDocument { (snapshot, error) in
                            guard error == nil else { return }
                            
                            guard var dictionary = snapshot?.data() else { return }
                            dictionary.updateValue(messageID as AnyObject, forKey: "messageUID")
                            let message = Message(dictionary: dictionary as [String : AnyObject])
                            
                            guard let uid = Auth.auth().currentUser?.uid, message.fromId != uid else { return }
                            
//                            if let notified = message.notified.value, !notified {
                            self.handleInAppSoundPlaying(message: message, channel: channel, channels: self.channels)
//                            }
                        }
                    }
                }
            }
            
            individualChannelListenersDict[channelID] = listener
        }
    }
    
    func handleInAppSoundPlaying(message: Message, channel: Channel, channels: [Channel]) {
        if UIApplication.topViewController() is SFSafariViewController ||
        UIApplication.topViewController() is ChannelLogController { return }
        
        if let index = channels.firstIndex(where: { (chan) -> Bool in
            return chan.id == channel.id
        }) {
            
            if let channelName = channels[index].name {
                self.playNotificationSound()
                if userDefaults.currentBoolObjectState(for: userDefaults.inAppNotifications) {
                    var title = ""
                    if message.historicSenderName != nil {
                        title = "\(message.historicSenderName ?? "") @ \(channelName)"
                    } else {
                        title = channelName
                    }
                    self.showInAppNotification(channel: channels[index], title: title, subtitle: self.subtitleForMessage(message: message), resource: channelAvatar(resource: channels[index].thumbnailImageUrl), placeholder: channelPlaceholder() )
                }
            }
            
//            if let muted = channels[index].isMuted.value, !muted, let channelName = channels[index].name {
//                self.playNotificationSound()
//                if userDefaults.currentBoolObjectState(for: userDefaults.inAppNotifications) {
//                    var title = ""
//                    if message.historicSenderName != nil {
//                        title = "\(message.historicSenderName ?? "") @ \(channelName)"
//                    } else {
//                        title = channelName
//                    }
//                    self.showInAppNotification(channel: channels[index], title: title, subtitle: self.subtitleForMessage(message: message), resource: channelAvatar(resource: channels[index].thumbnailImageUrl), placeholder: channelPlaceholder() )
//                }
//            } else if let channelName = channels[index].name, channels[index].isMuted.value == nil {
//                self.playNotificationSound()
//                if userDefaults.currentBoolObjectState(for: userDefaults.inAppNotifications) {
//                    var title = ""
//                    if message.historicSenderName != nil {
//                        title = "\(message.historicSenderName ?? "") @ \(channelName)"
//                    } else {
//                        title = channelName
//                    }
//                    self.showInAppNotification(channel: channels[index], title: title, subtitle: self.subtitleForMessage(message: message), resource: channelAvatar(resource: channels[index].thumbnailImageUrl), placeholder: channelPlaceholder())
//                }
//            }
        }
    }
    
    fileprivate func channelAvatar(resource: String?) -> Any {
        let placeHolderImage = UIImage(named: "GroupIcon")
        guard let imageURL = resource, imageURL != "" else { return placeHolderImage! }
        return URL(string: imageURL)!
    }
    
    fileprivate func channelPlaceholder() -> Data? {
        let placeHolderImage = UIImage(named: "GroupIcon")
        guard let data = placeHolderImage?.asJPEGData else {
            return nil
        }
        return data
    }
    
    fileprivate func subtitleForMessage(message: Message) -> String {
            return message.text ?? ""
    }
    
    fileprivate func conversationAvatar(resource: String?, isGroupChat: Bool) -> Any {
        let placeHolderImage = UIImage(named: "GroupIcon")
        guard let imageURL = resource, imageURL != "" else { return placeHolderImage! }
        return URL(string: imageURL)!
    }

    fileprivate func conversationPlaceholder(isGroupChat: Bool) -> Data? {
        let placeHolderImage = UIImage(named: "GroupIcon")
        guard let data = placeHolderImage?.asJPEGData else {
            return nil
        }
        return data
    }

    fileprivate func showInAppNotification(channel: Channel, title: String, subtitle: String, resource: Any?, placeholder: Data?) {
        
        let notification: InAppNotification = InAppNotification(resource: resource, title: title, subtitle: subtitle, data: placeholder)
        InAppNotificationDispatcher.shared.show(notification: notification) { (_) in
            guard let controller = UIApplication.shared.keyWindow?.rootViewController else { return }
            guard let id = channel.id, let realmChannel = RealmKeychain.defaultRealm.objects(Channel.self).filter("id == %@", id).first else {
                channelLogPresenter.open(channel, controller: controller)
                return
            }
            channelLogPresenter.open(realmChannel, controller: controller)
        }
    }

    fileprivate func playNotificationSound() {        
        if userDefaults.currentBoolObjectState(for: userDefaults.inAppSounds) {
            let systemSoundID: SystemSoundID = 1007
            AudioServicesPlaySystemSound (systemSoundID)
//            SystemSoundID.playFileNamed(fileName: "notification", withExtenstion: "caf")
        }
        if userDefaults.currentBoolObjectState(for: userDefaults.inAppVibration) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
}
