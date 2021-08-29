//
//  User.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-30.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Foundation
import RealmSwift

final class User: Object {
    @objc dynamic var id: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var name: String?
    @objc dynamic var email: String?
    @objc dynamic var bio: String?
    @objc dynamic var userImageUrl: String?
    @objc dynamic var userThumbnailImageUrl: String?
    @objc dynamic var onlineStatus: String?
    @objc dynamic var localName: String? {
        get {
            if let localContactIdentifier = localContactIdentifier {
                return globalVariables.localContactsDict[localContactIdentifier]?.givenName
            } else {
                return nil
            }
        }
        set {}
    }
    
    @objc dynamic var fcmToken: String?
    
    @objc dynamic var localContactIdentifier: String? {
        didSet {
//            self.localName = globalVariables.localContacts.first(where: { $0.identifier == localContactIdentifier })?.givenName
//            self.localName = globalVariables.localContacts[
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var isSelected: Bool! = false // local only
    
    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        self.id = dictionary["id"] as? String
        self.phoneNumber = dictionary["phoneNumber"] as? String
        self.bio = dictionary["bio"] as? String
        self.userImageUrl = dictionary["userImageUrl"] as? String
        self.userThumbnailImageUrl = dictionary["userThumbnailImageUrl"] as? String
        self.email = dictionary["email"] as? String
        self.onlineStatus = dictionary["OnlineStatus"] as? String
        self.name = dictionary["name"] as? String
//        self.localContactIdentifier = dictionary["localContactIdentifier"] as? String
        assignLocalNameIfAvailable()
    }
    
    func assignLocalNameIfAvailable() {
        self.localName = globalVariables.localContacts.first(where: { $0.identifier == localContactIdentifier })?.givenName
    }
    
    func isEqual_(to user: User) -> Bool {
        if self.id == user.id,
           self.name == user.name,
           self.phoneNumber == user.phoneNumber,
           self.userImageUrl == user.userImageUrl,
           self.userThumbnailImageUrl == user.userThumbnailImageUrl
        {
            return true
        } else {
            return false
        }
    }
    
}
