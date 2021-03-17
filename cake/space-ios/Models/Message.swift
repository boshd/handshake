//
//  Message.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-30.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import RealmSwift

struct MessageSubtitle {
    static let empty = "No messages here yet."
}

final class Message: Object {
    
    @objc dynamic var messageUID: String?
    @objc dynamic var fromId: String?
    @objc dynamic var text: String?
    @objc dynamic var toId: String?
    @objc dynamic var status: String?
    @objc dynamic var convertedTimestamp: String?
    @objc dynamic var shortConvertedTimestamp: String?
    @objc dynamic var senderName: String?
    
    // the sender and channel names at the time. this is for push notifications
    @objc dynamic var historicChannelName: String?
    @objc dynamic var historicSenderName: String?
    
    @objc dynamic var estimatedFrameForText: RealmCGRect?
    
    let isInformationMessage = RealmOptional<Bool>()
    let seen = RealmOptional<Bool>()
    
//    var fcmTokens = List<FCMToken>()
    
    let timestamp = RealmOptional<Int64>()
    
    @objc dynamic var channel: Channel?
    
    override static func primaryKey() -> String? {
        return "messageUID"
    }
    
    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        
        self.messageUID = dictionary["messageUID"] as? String
        self.isInformationMessage.value = dictionary["isInformationMessage"] as? Bool
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp.value = dictionary["timestamp"] as? Int64
        self.convertedTimestamp = dictionary["convertedTimestamp"] as? String
        self.shortConvertedTimestamp = dictionary["shortConvertedTimestamp"] as? String
        self.status = dictionary["status"] as? String
        self.seen.value = dictionary["seen"] as? Bool
        self.senderName = dictionary["senderName"] as? String
        self.historicChannelName = dictionary["historicChannelName"] as? String
        self.historicSenderName = dictionary["historicSenderName"] as? String
        self.estimatedFrameForText = dictionary["estimatedFrameForText"] as? RealmCGRect
        
//        self.fcmTokens.assign(dictionary["fcmTokens"] as? [String])
//        self.fcmTokens = dictionary["fcmTokens"] as? List<FCMToken> ?? List<FCMToken>()
    }
    
    static func get(indexPathOf message: Message, in groupedArray: [MessageSection]) -> IndexPath? {
        guard let section = groupedArray.firstIndex(where: { (messages) -> Bool in
            for message1 in messages.messages where message1.messageUID == message.messageUID {
                return true
            }; return false
        }) else { return nil }

        guard let row = groupedArray[section].messages.firstIndex(where: { (message1) -> Bool in
            return message1.messageUID == message.messageUID
        }) else { return nil }

        return IndexPath(row: row, section: section)
    }

    static func get(indexPathOf messageUID: String? = nil , localPhoto: UIImage? = nil, in groupedArray: [MessageSection]?) -> IndexPath? {
          guard let groupedArray = groupedArray else { return nil }
        if messageUID != nil {
            guard let section = groupedArray.firstIndex(where: { (messages) -> Bool in
                for message1 in messages.messages where message1.messageUID == messageUID {
                    return true
                }; return false
            }) else { return nil }

            guard let row = groupedArray[section].messages.firstIndex(where: { (message1) -> Bool in
                return message1.messageUID == messageUID
            }) else { return nil }

            return IndexPath(row: row, section: section)
      }
    return nil
    }
    
}
