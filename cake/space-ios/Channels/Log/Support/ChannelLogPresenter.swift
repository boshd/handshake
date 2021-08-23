//
//  ChannelLogPresenter.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-10.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

let channelLogPresenter = ChannelLogPresenter()

class ChannelLogPresenter: NSObject {

    fileprivate var channelLogController: ChannelLogController?
    fileprivate var messagesFetcher: MessagesFetcher?
    
    fileprivate var isChannelLogAlreadyOpened = false
    
    fileprivate func deselectItem(controller: UIViewController) {
        guard let controller = controller as? ChannelsController else { return }

        if let indexPath = controller.tableView.indexPathForSelectedRow {
            controller.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    public func tryDeallocate(force: Bool = false) {
        channelLogController = nil
        messagesFetcher?.delegate = nil
        messagesFetcher = nil
    }
    
    public func open(_ channel: Channel, controller: UIViewController) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        isChannelLogAlreadyOpened = false
        channelLogController = ChannelLogController()
        messagesFetcher = MessagesFetcher()
        messagesFetcher?.delegate = self
        
        let newMessagesReceived = (channel.badge.value ?? 0) > 0
        let isEnoughData = channel.messages.count >= 3
        
        if !newMessagesReceived && isEnoughData {
            openChannelLog(for: channel, controller: controller)
        }
        
        if Array(channel.participantIds).contains(currentUserID) {
            messagesFetcher?.loadMessagesData(for: channel, controller: controller)
        } else {
            openChannelLog(for: channel, controller: controller)
        }
    }
    
    fileprivate func openChannelLog(for channel: Channel, controller: UIViewController) {
        guard isChannelLogAlreadyOpened == false else { return }
        isChannelLogAlreadyOpened = true
        channelLogController?.hidesBottomBarWhenPushed = true
        channelLogController?.messagesFetcher = messagesFetcher
        channelLogController?.channel = channel
        channelLogController?.getMessages()
        channelLogController?.deleteAndExitDelegate = controller as? DeleteAndExitDelegate
        
        channelLogController?.messagesFetcher?.collectionDelegate = channelLogController
        
        guard let destination = channelLogController else { return }

        controller.navigationController?.pushViewController(destination, animated: true)
        deselectItem(controller: controller)
    }
    
}

extension ChannelLogPresenter: MessagesDelegate {
    func messages(shouldBeUpdatedTo messages: [Message], channel: Channel, controller: UIViewController) {
        addMessagesToRealm(messages: messages, channel: channel, controller: controller)
    }
    
    func messages(shouldChangeMessageStatusToReadAt reference: DocumentReference, controller: UIViewController) {
        channelLogController?.updateMessageStatus(messageRef: reference)
    }
    
    fileprivate func addMessagesToRealm(messages: [Message], channel: Channel, controller: UIViewController) {
        guard messages.count > 0 else {
            openChannelLog(for: channel, controller: controller)
            return
        }
        
        autoreleasepool {
            guard !RealmKeychain.defaultRealm.isInWriteTransaction else { return }
            RealmKeychain.defaultRealm.beginWrite()
            for message in messages {
                
                if message.senderName == nil {
                    message.senderName = RealmKeychain.defaultRealm.object(ofType: Message.self, forPrimaryKey: message.messageUID ?? "")?.senderName
                }
                
//                print("in realm creating new message \(message.text)")
                
                RealmKeychain.defaultRealm.create(Message.self, value: message, update: .modified)
            }
            try! RealmKeychain.defaultRealm.commitWrite()
            openChannelLog(for: channel, controller: controller)
        }
    }
}
