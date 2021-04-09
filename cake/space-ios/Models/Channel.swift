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
    
    
    var status: EventStatus?
    
    var isCancelled = RealmOptional<Bool>()
    
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
    
    var isMuted = RealmOptional<Bool>()
    var isEmpty = RealmOptional<Bool>()
    var isVirtual = RealmOptional<Bool>()
    
    var latitude = RealmOptional<Double>()
    var longitude = RealmOptional<Double>()
    
    var lastMessageRuntime: Message?
    
    var tmpStartDate: Date?
    var tmpEndDate: Date?
    
    dynamic var placemark: MKPlacemark? // local
    
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
        
//        self.fcmTokens.assign(dictionary?["fcmTokens"] as? [FCMToken])
        
        if let fcmTokensDict = dictionary?["fcmTokens"] as? [String:String] {
            self.fcmTokens = convertRawFCMTokensToRealmCompatibleType(fcmTokensDict)
        }
        
        self.isMuted.value = dictionary?["isMuted"] as? Bool
        self.isEmpty.value = dictionary?["isEmpty"] as? Bool
        
        self.latitude.value = dictionary?["latitude"] as? Double
        self.longitude.value = dictionary?["longitude"] as? Double
        
        self.locationName = dictionary?["locationName"] as? String
        
        self.isCancelled.value = dictionary?["isCancelled"] as? Bool
        self.isVirtual.value = dictionary?["isVirtual"] as? Bool
        
        self.shouldUpdateRealmRemotelyBeforeDisplaying.value = RealmKeychain.defaultRealm.object(ofType: Channel.self,
        forPrimaryKey: dictionary?["id"] as? String ?? "")?.shouldUpdateRealmRemotelyBeforeDisplaying.value
    }
    
    func updateAndReturnStatus() -> EventStatus? {
        guard Auth.auth().currentUser != nil,
              !self.isInvalidated,
              let startTime = startTime.value,
              let endTime = endTime.value
        else { return nil }
        
        if let isCancelled = isCancelled.value, isCancelled {
            status = .cancelled
            return .cancelled
        } else {
            let currentDateInt64 = Int64(Int(Date().timeIntervalSince1970))
            if startTime > currentDateInt64 && endTime > currentDateInt64 {
                status = .upcoming
                return .upcoming
            } else if startTime <= currentDateInt64 && endTime > currentDateInt64 {
                status = .inProgress
                return .inProgress
            } else {
                status = .expired
                return .expired
            }
        }
    }
    
    
}

class FCMToken: Object {
    @objc dynamic var userId = ""
    @objc dynamic var fcmToken = ""
}
