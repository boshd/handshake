//
//  ChannelsRealmManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-10.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Foundation
import RealmSwift

class ChannelsRealmManager {
    
    func update(channel: Channel) {
        autoreleasepool {
            try! RealmKeychain.defaultRealm.safeWrite {
                RealmKeychain.defaultRealm.create(Channel.self, value: channel, update: .modified)
            }
        }
    }
    
    func update(channels: [Channel], tokens: [NotificationToken]) {
        autoreleasepool {
            guard !RealmKeychain.defaultRealm.isInWriteTransaction else {
                print("Update Array operation, realm is in write transaction in \(String(describing: ChannelsRealmManager.self))")
                return
            }

            RealmKeychain.defaultRealm.beginWrite()
            for channel in channels {
                channel.isTyping.value = RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: channel.id ?? "")?.isTyping.value
                
                RealmKeychain.defaultRealm.create(Channel.self, value: channel, update: .modified)
                if let message = channel.lastMessageRuntime {
                    message.senderName = RealmKeychain.defaultRealm.object(ofType: Message.self, forPrimaryKey: message.messageUID ?? "")?.senderName
                    RealmKeychain.defaultRealm.create(Message.self, value: message, update: .modified)
                }
            }
            do {
                try RealmKeychain.defaultRealm.commitWrite(withoutNotifying: tokens)
            } catch {
                print("ERROR WRITING")
            }
        }
    }
    
    func delete(channel: Channel) {
        autoreleasepool {
            try! RealmKeychain.defaultRealm.safeWrite {
                let result = RealmKeychain.defaultRealm.objects(Channel.self).filter("id = '\(channel.id!)'")
                let messageResult = RealmKeychain.defaultRealm.objects(Message.self).filter("channel.id = '\(channel.id ?? "")'")
                RealmKeychain.defaultRealm.delete(messageResult)
                RealmKeychain.defaultRealm.delete(result)
            }
        }
    }
    
    func deleteAll() {
        autoreleasepool {
            do {
                try RealmKeychain.defaultRealm.safeWrite {
                    RealmKeychain.defaultRealm.deleteAll()
                }
            } catch {}
        }
    }
    
}


