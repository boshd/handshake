//
//  ChannelLogController+MessageSending.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-25.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit

extension ChannelLogController {
    
    // MARK: Messages sending
    @objc func sendMessage() {
        hapticFeedback(style: .impact)
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        isTyping = false
        let text = inputContainerView.inputTextView.text
        inputContainerView.prepareForSend()
        guard let channel = self.channel else { return }
//        scrollToBottom(animated: true)
        let messageSender = MessageSender(realmChannel(from: channel), text: text)
        messageSender.delegate = self
        messageSender.sendMessage()
    }
    
    @objc func presentResendActions(_ sender: UIButton) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let resendAction = UIAlertAction(title: "Resend", style: .default) { (action) in
            self.resendMessage(sender)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(resendAction)
        controller.addAction(cancelAction)

//        inputContainerView.resignAllResponders()
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func resendMessage(_ sender: UIButton) {
        let point = collectionView.convert(CGPoint.zero, from: sender)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        guard let channel = self.channel else { return }
        let message = groupedMessages[indexPath.section].messages[indexPath.row]

        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        isTyping = false
//        inputContainerView.prepareForSend()
        resendTextMessage(channel, message.text, at: indexPath)
    }

    fileprivate func resendTextMessage(_ channel: Channel, _ text: String?, at indexPath: IndexPath) {
        handleResend(channel: channel, text: text, indexPath: indexPath)
    }
    
    fileprivate func handleResend(channel: Channel, text: String?, indexPath: IndexPath) {
        let messageSender = MessageSender(channel, text: text)
        messageSender.delegate = self
        messageSender.sendMessage()

        deleteLocalMessage(at: indexPath)
    }
    
    fileprivate func deleteLocalMessage(at indexPath: IndexPath) {
        let message = groupedMessages[indexPath.section].messages[indexPath.row]
        try! realm.safeWrite {
            guard let object = realm.object(ofType: Message.self, forPrimaryKey: message.messageUID ?? "") else { return }
            realm.delete(object)

            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            }, completion: nil)
        }
    }
    
    fileprivate func realmChannel(from channel: Channel) -> Channel {
        guard realm.objects(Channel.self).filter("id == %@", channel.id ?? "").first == nil else { return channel }
        try! realm.safeWrite {
            realm.create(Channel.self, value: channel, update: .modified)
        }

        let newChannel = realm.objects(Channel.self).filter("id == %@", channel.id ?? "").first
        self.channel = newChannel
        return newChannel ?? channel
    }
    
}
