//
//  MessageSection.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import RealmSwift

final class MessageSection: Object {

    @objc var title: String?
    var messages: Results<Message>!
    var notificationToken: NotificationToken?

    convenience init(messages: Results<Message>, title: String) {
        self.init()

        self.title = title
        self.messages = messages
    }
}
