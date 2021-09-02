//
//  InformationMessageSender.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-22.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class InformationMessageSender: NSObject {
    
    let channelsReference = Firestore.firestore().collection("channels")
    
    func sendInformationMessage(channelID: String, channelName: String, participantIDs: [String], text: String, channel: Channel?) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let newInformationMessageReference = Firestore.firestore().collection("messages").document()
        
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let defaultMessageStatus = messageStatusDelivered
        let fromId = currentUserID
        let toId = channelID
        
        var fcmDict = [String:String]()
        
        channel?.fcmTokens.forEach({ (token) in
            if fcmDict[token.userId] != currentUserID {
                fcmDict[token.userId] = token.fcmToken
            }
        })
        
        let values: [String: AnyObject] = [
            "messageUID": newInformationMessageReference.documentID as AnyObject,
            "toId": toId as AnyObject,
            "status": defaultMessageStatus as AnyObject,
            "seen": false as AnyObject,
            "fromId": fromId as AnyObject,
            "timestamp": timestamp,
            "text": text as AnyObject,
            "isInformationMessage": true as AnyObject,
            "senderName": "" as AnyObject,
            "channelName": channelName as AnyObject,
            "fcmTokens": fcmDict as AnyObject
        ]
        
        newInformationMessageReference.setData(values) { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            let batch = Firestore.firestore().batch()
            batch.setData([
                "fromId": fromId,
                "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970))
            ], forDocument: Firestore.firestore().collection("channels").document(toId).collection("messageIds").document(newInformationMessageReference.documentID), merge: true)
            batch.setData([
                "fromId": fromId,
                "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970))
            ], forDocument: Firestore.firestore().collection("users").document(fromId).collection("channelIds").document(toId).collection("messageIds").document(newInformationMessageReference.documentID), merge: true)
            
            batch.commit { (error) in
                if error != nil { print(error?.localizedDescription ?? ""); return }
                self.updateLastMessage(with: channelID, messageID: newInformationMessageReference.documentID)
            }
            
        }
    }
    
    fileprivate func updateLastMessage(with channelID: String, messageID: String) {
        guard let fromID = Auth.auth().currentUser?.uid else { return }
        let channelReference = Firestore.firestore().collection("users").document(fromID).collection("channelIds").document(channelID)
        channelReference.setData([
            "lastMessageId": messageID
        ], merge: true)
    }
    
}
