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
        
        //let channelReference = Firestore.firestore().collection("channels").document(channelID)
        let newInformationMessageReference = Firestore.firestore().collection("messages").document()
        
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let defaultMessageStatus = messageStatusDelivered
        let fromId = Auth.auth().currentUser?.uid
        let toId = channelID
        
        var fcmDict = [String:String]()
        
        channel?.fcmTokens.forEach({ (token) in
            fcmDict[token.userId] = token.fcmToken
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
            "historicSenderName": "" as AnyObject,
            "historicChannelName": channelName as AnyObject,
            "fcmTokens": fcmDict as AnyObject
        ]
        
        newInformationMessageReference.setData(values) { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            self.updateLastMessage(with: channelID, text: text, messageID: newInformationMessageReference.documentID)
        }
    }
    
    fileprivate func updateLastMessage(with channelID: String, text: String, messageID: String) {
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        channelReference.updateData([
            "lastMessageTimeStamp": NSNumber(value: Int(Date().timeIntervalSince1970)) as Any,
            "lastMessageId": messageID
        ])
    }
    
}
