//
//  RealmKeychain.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-09.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Security
import RealmSwift

final class RealmKeychain {
    
    static let defaultRealm = try! Realm(configuration: RealmKeychain.realmDefaultConfiguration())
    static let usersRealm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    static let nonLocalUsersRealm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
    
    static func realmUsersArray() -> [User] {
        return Array(RealmKeychain.usersRealm.objects(User.self))
    }
    
    static func realmNonLocalUsersArray() -> [User] {
        return Array(RealmKeychain.nonLocalUsersRealm.objects(User.self))
    }
    
    static func realmNonLocalUsersConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration()
        // is this safe?
        // config.deleteRealmIfMigrationNeeded = true
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("nonLocalUsers.realm")
        config.encryptionKey = RealmKeychain.getKey() as Data
        return config
    }
    
    static func realmUsersConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration()
        // is this safe?
        // config.deleteRealmIfMigrationNeeded = true
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("users.realm")
        config.encryptionKey = RealmKeychain.getKey() as Data
        return config
    }
    
    static func realmDefaultConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration()
        // is this safe?
        // config.deleteRealmIfMigrationNeeded = true
        let enc = RealmKeychain.getKey() as Data
        config.encryptionKey = enc
        return config
    }
    
    static fileprivate func getKey() -> NSData {
        let keychainId = "spaces.Realm.Key"
        let keychainIdData = keychainId.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]
        
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }
        
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")

        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keyData
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        
        return keyData
    }
    
}
