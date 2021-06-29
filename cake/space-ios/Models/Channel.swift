//
//  Channel.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-30.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import RealmSwift
import MapKit
import Firebase

enum EventStatus {
    case upcoming
    case inProgress
    case expired
    case cancelled
}

final class Channel: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var imageUrl: String?
    @objc dynamic var author: String?
    @objc dynamic var authorName: String?
    @objc dynamic var thumbnailImageUrl: String?
    @objc dynamic var lastMessageId: String?
    @objc dynamic var description_: String?
    @objc dynamic var locationName: String?
    @objc dynamic var locationDescription: String?
    @objc dynamic var location: Location?
    
    var createdAt = RealmOptional<Int64>()
    var lastMessageTimestamp = RealmOptional<Int64>()
    
    let isTyping = RealmOptional<Bool>()
    
    var startTime = RealmOptional<Int64>()
    var endTime = RealmOptional<Int64>()
    
    var badge = RealmOptional<Int>()
    
    var participantIds = List<String>()
    var admins = List<String>()
    var goingIds = List<String>()
    var maybeIds = List<String>()
    var notGoingIds = List<String>()
    
    var fcmTokens = List<FCMToken>()
    
    var isRemote = RealmOptional<Bool>()
    
    var latitude = RealmOptional<Double>()
    var longitude = RealmOptional<Double>()
    
    var lastMessageRuntime: Message?
    
    // local use
//    @objc dynamic var nonFriends = [User]()
    
    var messages = LinkingObjects(fromType: Message.self, property: "channel")
    let shouldUpdateRealmRemotelyBeforeDisplaying = RealmOptional<Bool>()
    
    @objc dynamic var lastMessage: Message? {
        return RealmKeychain.defaultRealm.object(ofType: Message.self, forPrimaryKey: lastMessageId ?? "")
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getTyping() -> Bool {
        return RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: id ?? "")?.isTyping.value ?? false
    }
    
    convenience init(dictionary: [String: AnyObject]?) {
        
        self.init()
        
        self.id = dictionary?["id"] as? String
        self.name = dictionary?["name"] as? String
        self.imageUrl = dictionary?["imageUrl"] as? String
        self.thumbnailImageUrl = dictionary?["thumbnailImageUrl"] as? String
        self.author = dictionary?["author"] as? String
        self.authorName = dictionary?["authorName"] as? String
        self.lastMessageId = dictionary?["lastMessageId"] as? String
        self.description_ = dictionary?["description"] as? String
        
        self.createdAt.value = dictionary?["createdAt"] as? Int64
        self.lastMessageTimestamp.value = dictionary?["lastMessageTimestamp"] as? Int64
        self.startTime.value = dictionary?["startTime"] as? Int64
        self.endTime.value = dictionary?["endTime"] as? Int64
        
        self.badge.value = dictionary?["badge"] as? Int
        
        self.participantIds.assign(dictionary?["participantIds"] as? [String])
        self.admins.assign(dictionary?["admins"] as? [String])
        self.goingIds.assign(dictionary?["goingIds"] as? [String])
        self.maybeIds.assign(dictionary?["maybeIds"] as? [String])
        self.notGoingIds.assign(dictionary?["notGoingIds"] as? [String])
        
        // self.fcmTokens.assign(dictionary?["fcmTokens"] as? [FCMToken])
        
        if let fcmTokensDict = dictionary?["fcmTokens"] as? [String:String] {
            self.fcmTokens = convertRawFCMTokensToRealmCompatibleType(fcmTokensDict)
        }
        
        self.latitude.value = dictionary?["latitude"] as? Double
        self.longitude.value = dictionary?["longitude"] as? Double
        
        self.locationDescription = dictionary?["locationDescription"] as? String
        
        
        self.location = dictionary?["location"] as? Location
        
        self.locationName = dictionary?["locationName"] as? String

        self.isRemote.value = dictionary?["isRemote"] as? Bool
        
        self.shouldUpdateRealmRemotelyBeforeDisplaying.value = RealmKeychain.defaultRealm.object(ofType: Channel.self,
        forPrimaryKey: dictionary?["id"] as? String ?? "")?.shouldUpdateRealmRemotelyBeforeDisplaying.value
    }
    
    /*
     
     
     */
    
    static func channelChanged() -> Bool {
        return false
    }
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        if lhs.id == rhs.id,
           lhs.name == rhs.name,
           lhs.imageUrl == rhs.imageUrl,
//           lhs.author == rhs.author,
           lhs.thumbnailImageUrl == rhs.thumbnailImageUrl,
//           lhs.lastMessageId == rhs.lastMessageId,
           lhs.description_ == rhs.description_,
           lhs.locationName == rhs.locationName,
           lhs.locationDescription == rhs.locationDescription,
           lhs.location == rhs.location,
//           lhs.createdAt == rhs.createdAt,
//           lhs.lastMessageTimestamp == rhs.lastMessageTimestamp,
//           lhs.isTyping == rhs.isTyping,
           lhs.startTime == rhs.startTime,
           lhs.endTime == rhs.endTime,
//           lhs.badge == rhs.badge,
//           lhs.participantIds == rhs.participantIds,
//           lhs.admins == rhs.admins,
//           lhs.goingIds == rhs.goingIds,
//           lhs.maybeIds == rhs.maybeIds,
//           lhs.notGoingIds == rhs.notGoingIds,
//           lhs.fcmTokens == rhs.fcmTokens,
           lhs.isRemote == rhs.isRemote,
           lhs.latitude == rhs.latitude,
           lhs.longitude == rhs.longitude
//           lhs.lastMessageRuntime == rhs.lastMessageRuntime,
//           lhs.shouldUpdateRealmRemotelyBeforeDisplaying == rhs.shouldUpdateRealmRemotelyBeforeDisplaying,
//           lhs.lastMessage == rhs.lastMessage
        {
            return true
        } else {
            return false
        }
    }
    
    
}

class FCMToken: Object {
    @objc dynamic var userId = ""
    @objc dynamic var fcmToken = ""
}
