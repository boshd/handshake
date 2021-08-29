//
//  MessageSender.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-19.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

protocol MessageSenderDelegate: class {
    func update(with values: [String: AnyObject])
    func update(mediaSending progress: Double, animated: Bool)
}

class MessageSender: NSObject {
    
    fileprivate var channel: Channel?
    fileprivate var text: String?
    fileprivate var currentUserName: String?
    
    fileprivate let DBreference = Firestore.firestore()
    fileprivate var attachedMedia = [String]()
    
    fileprivate var dataToUpdate = [[String: AnyObject]]()
    
    weak var delegate: MessageSenderDelegate?
    
    init(_ channel: Channel?, text: String?) {
        self.channel = channel
        self.text = text
        
    }
    
    public func sendMessage() {
        sendMessagePlease()
    }
    
    
    fileprivate var mediaUploadGroup = DispatchGroup()
    fileprivate var localUpdateGroup = DispatchGroup()
    fileprivate var mediaCount = CGFloat()
    fileprivate var mediaToSend = [(values: [String: AnyObject], reference: DocumentReference)]()
    fileprivate var progress = [UploadProgress]()
    
    fileprivate func sendMessagePlease() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let messageSendingGroup = DispatchGroup()
        let delegateGroup = DispatchGroup()
        
        messageSendingGroup.enter()
        delegateGroup.enter()
        
        guard let toID = channel?.id, let fromID = Auth.auth().currentUser?.uid, let text = self.text else {
            messageSendingGroup.leave()
            delegateGroup.leave()
            return
        }
        guard text != "" else {
            messageSendingGroup.leave()
            delegateGroup.leave()
            return
        }
        
        let newMessageReference = Firestore.firestore().collection("messages").document()

        let messageUID = newMessageReference.documentID
        let messageStatus = messageStatusDelivered
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        var fcmDict = [String:String]()
        
        channel?.fcmTokens.forEach({ (token) in
            if fcmDict[token.userId] != currentUserID {
                fcmDict[token.userId] = token.fcmToken
            }
        })
        
        let defaultData: [String: AnyObject] = ["messageUID": messageUID as AnyObject,
                                                "toId": toID as AnyObject,
                                                "status": messageStatus as AnyObject,
                                                "seen": false as AnyObject,
                                                "notified": false as AnyObject,
                                                "fromId": fromID as AnyObject,
                                                "timestamp": timestamp as AnyObject,
                                                "text": text.trimmingCharacters(in: .whitespaces) as AnyObject,
                                                "channelName": channel?.name as AnyObject,
                                                "senderName": userDefaults.currentStringObjectState(for: userDefaults.currentUserName) as AnyObject,
                                                "historicSenderName": userDefaults.currentStringObjectState(for: userDefaults.currentUserName) as AnyObject,
                                                "historicChannelName": channel?.name as AnyObject,
                                                "fcmTokens": fcmDict as AnyObject
        ]
        
        newMessageReference.setData(defaultData) { (error) in
            if error != nil {
                print("error // ", error?.localizedDescription ?? "")
                return
            }
            messageSendingGroup.leave()
            delegateGroup.leave()
        }

        self.delegate?.update(with: defaultData)
        
        delegateGroup.notify(queue: .main) {
            // why was self.delegate?.update(with: defaultData) in here?
        }
        
        messageSendingGroup.notify(queue: .global(qos: .background), execute: {
            self.updateDatabase(at: newMessageReference, with: defaultData, toID: toID, fromID: fromID)
        })
    }
    
    fileprivate func updateDatabase(at reference: DocumentReference, with values: [String: AnyObject], toID: String, fromID: String ) {
        
//        reference.setData(values) { (error) in
//            guard error == nil else { print(error?.localizedDescription ?? "error"); return }
            
            let batch = Firestore.firestore().batch()
            
            batch.setData([
                "fromId": fromID,
                "timestamp": values["timstamp"] ?? NSNumber(value: Int(Date().timeIntervalSince1970))
            ], forDocument: Firestore.firestore().collection("channels").document(toID).collection("messageIds").document(reference.documentID), merge: true)
            
            
//            self.channel?.participantIds.forEach({ id in
                batch.setData([
                    "fromId": fromID,
                    "timestamp": values["timstamp"] ?? NSNumber(value: Int(Date().timeIntervalSince1970))
                ], forDocument: Firestore.firestore().collection("users").document(fromID).collection("channelIds").document(toID).collection("messageIds").document(reference.documentID), merge: true)
//            })
            
            
            
            
            batch.commit() { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    return
                }
                self.updateLastMessage(with: reference.documentID)
            }
//        }
        
    }

    
    fileprivate func updateLastMessage(with messageID: String) {
        // updates only for current user
        // for other users this update handled by Backend to reduce write operations on device
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channel?.id
        else { return }
        
        // diff between channels being updated or not
        
        let ref = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID)
        ref.setData([
            "lastMessageId": messageID as Any
        ], merge: true)
        
//        let ref = Firestore.firestore().collection("channels").document(channelID)
//        ref.setData([
//            "lastMessageId": messageID as Any
//        ], merge: true)
    }
}
