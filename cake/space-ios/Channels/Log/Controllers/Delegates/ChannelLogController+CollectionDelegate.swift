//
//  ChannelLogController+CollectionDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-09.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

extension ChannelLogController: CollectionDelegate {
    
    func collectionView(shouldUpdateOutgoingMessageStatusFrom reference: DocumentReference, message: Message) {
        var initial = true
        lastOutgoingMessageListener = reference.addSnapshotListener { [weak self] (snapshot, error) in

            guard error == nil else { print(error?.localizedDescription ?? ""); return }
            guard let exists = snapshot?.exists, exists, let data = snapshot?.data(), let messageStatus = data["status"] as? String else { return }
            message.status = messageStatus
            self?.updateMessageStatusUI(sentMessage: message)
            if initial {
                initial = false
                return
            } else {
                self?.lastOutgoingMessageListener?.remove()
                self?.lastOutgoingMessageListener = nil
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            self.updateMessageStatus(messageRef: reference)
        }
        
        updateMessageStatusUI(sentMessage: message)
    }
    
    func collectionView(shouldBeUpdatedWith message: Message, reference: DocumentReference) {
        update(message: message, reference: reference)
    }
    
    func collectionView(shouldRemoveMessage id: String) {}
    
    func update(message: Message, reference: DocumentReference) {
        guard isInsertingToTheBottom(message: message) else { return }
        batch(message: message, reference: reference)
    }
    
    fileprivate func batch(message: Message, reference: DocumentReference) {
        guard !realm.isInWriteTransaction else { return }
        realm.beginWrite()
        groupedMessages.last?.messages.last?.isCrooked.value = false
        groupedMessages.last?.messages.first?.isFirstInSection.value = false
        message.channel = channel
        message.isCrooked.value = false
        message.isFirstInSection.value = false
        
        realm.create(Message.self, value: message, update: .modified)
        guard let newSectionTitle = message.shortConvertedTimestamp else { try! self.realm.commitWrite(); return }
        let lastSectionTitle = groupedMessages.last?.title ?? ""
        let mustCreateNewSection = newSectionTitle != lastSectionTitle

        if userDefaults.currentBoolObjectState(for: userDefaults.inAppSounds) &&
            UIApplication.topViewController() is ChannelLogController {
            let systemSoundID: SystemSoundID = 1003
            AudioServicesPlaySystemSound(systemSoundID)
        }
        
        if mustCreateNewSection {
            print("must new section")
            guard let messages = channel?.messages.filter("shortConvertedTimestamp == %@", newSectionTitle)
                .sorted(byKeyPath: "timestamp", ascending: true) else { try! self.realm.commitWrite(); return }

            let newSection = MessageSection(messages: messages, title: newSectionTitle)

            let insertionIndex = groupedMessages.insertionIndexOf(elem: newSection) { (section1, section2) -> Bool in
                return Date.dateFromCustomString(customString: section1.title ?? "") < Date.dateFromCustomString(customString: section2.title ?? "")
            }
            
            groupedMessages.insert(newSection, at: insertionIndex)
            
//            groupedMessages.last?.messages.last?.isCrooked.value = true
//            groupedMessages.last?.messages.last?.isFirstInSection.value = true
//
//            if let index = groupedMessages.last?.messages.count, index > 1 {
//                if groupedMessages.last?.messages[index - 2].fromId != groupedMessages.last?.messages.last?.fromId {
//                    groupedMessages.last?.messages.last?.isFirstInSection.value = true
//                } else {
//                    // removes crookedness from before
//                    if groupedMessages.last?.messages[index - 2].isCrooked.value == true {
//                        groupedMessages.last?.messages[index - 2].isCrooked.value = false
//                    }
//                }
//                print("message: \(message.text), groupedMessages.last?.messages.last?: \(groupedMessages.last?.messages[index - 2].text)")
//            } else {
//                print("LEFT OUT")
//            }
            
            //groupedMessages.last?.messages.first?.isFirstInSection.value = true

            groupedMessages.last?.messages.last?.isCrooked.value = true
            
            if let messageCount = groupedMessages.last?.messages.count, messageCount > 1 {
                // message is equal to messages.last
                if groupedMessages.last?.messages[messageCount-2].fromId != groupedMessages.last?.messages.last?.fromId {
                    groupedMessages.last?.messages[messageCount-2].isCrooked.value = true
                    groupedMessages.last?.messages.last?.isFirstInSection.value = true
                } else {
                    groupedMessages.last?.messages[messageCount-2].isCrooked.value = false
                    groupedMessages.last?.messages.last?.isFirstInSection.value = false
                }
                
            } else {
                groupedMessages.last?.messages.last?.isCrooked.value = true
                groupedMessages.last?.messages.last?.isFirstInSection.value = true
            }
            
            collectionView.performBatchUpdates({
                    collectionView.insertSections([insertionIndex])
            }) { (isCompleted) in
                self.performAdditionalUpdates(reference: reference)
            }
        } else {
            print("no new section")
            guard let indexPath = Message.get(indexPathOf: message, in: groupedMessages) else { try! self.realm.commitWrite(); return }
            if message.isInformationMessage.value == nil || !(message.isInformationMessage.value ?? false) {
                print("not info \(groupedMessages.last?.messages.count) \(message.text)")
                groupedMessages.last?.messages.last?.isCrooked.value = true
                
                if let messageCount = groupedMessages.last?.messages.count, messageCount > 1 {
                    // message is equal to messages.last
                    if groupedMessages.last?.messages[messageCount-2].fromId != groupedMessages.last?.messages.last?.fromId {
                        groupedMessages.last?.messages[messageCount-2].isCrooked.value = true
                        groupedMessages.last?.messages.last?.isFirstInSection.value = true
                    } else {
                        groupedMessages.last?.messages[messageCount-2].isCrooked.value = false
                        groupedMessages.last?.messages.last?.isFirstInSection.value = false
                    }
                    
                } else {
                    groupedMessages.last?.messages.last?.isCrooked.value = true
                    groupedMessages.last?.messages.last?.isFirstInSection.value = true
                }
                
                //groupedMessages.last?.messages.last?.isFirstInSection.value = true
                
                // last msg = crooked
                // b4 last msg = not crooked
                
                
                // if last msg not same sender as current sender, then first in section
                
                
//                if let messageCount = groupedMessages.last?.messages.count, messageCount > 1 {
//                    if groupedMessages.last?.messages[messageCount - 2].fromId != groupedMessages.last?.messages.last?.fromId {
//                        groupedMessages.last?.messages.last?.isCrooked.value = true
//                    } else {
//                        groupedMessages.last?.messages[messageCount - 2].isCrooked.value = false
//                    }
//                }
//
//
//
//
//                if let messageCount = groupedMessages.last?.messages.count, messageCount > 1 {
//                    if groupedMessages.last?.messages[messageCount - 2].fromId != groupedMessages.last?.messages.last?.fromId {
//                        groupedMessages.last?.messages.last?.isCrooked.value = true
//                    } else {
//                        groupedMessages.last?.messages[messageCount - 2].isCrooked.value = false
//                    }
//                }
//                    if groupedMessages.last?.messages[index - 2].fromId != groupedMessages.last?.messages.last?.fromId {
//                        groupedMessages.last?.messages.last?.isFirstInSection.value = true
//                    } else {
//                        groupedMessages.last?.messages[index - 2].isCrooked.value = false
//                    }
//                    print("message: \(message.text), groupedMessages.last?.messages.last?: \(groupedMessages.last?.messages[index - 2].text)")
//                } else {
//                    print("LEFT OUT")
//                }
            }
            
//            if let i = groupedMessages.last?.messages.count, i > 1 {
//                if groupedMessages.last?.messages[i - 2].fromId == groupedMessages.last?.messages.last?.fromId {
//                    groupedMessages.last?.messages[i - 2].isCrooked.value = false
//                }
//            }
            
            // temporary due to inefficiency
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates({
                    collectionView.reloadSections([indexPath.section])
                }) { (isCompleted) in
                    self.performAdditionalUpdates(reference: reference)
                }
            }
        }
        try! self.realm.commitWrite()
    }

    
    fileprivate func isInsertingToTheBottom(message: Message) -> Bool {
        let firstObject = groupedMessages.last?.messages.first?.timestamp.value ?? 0
        guard message.timestamp.value ?? 0 >= firstObject else { return false }
        return true
    }

    fileprivate func performAdditionalUpdates(reference: DocumentReference) {
        DispatchQueue.global(qos: .background).async {
            self.updateMessageStatus(messageRef: reference)
        }
        if self.isScrollViewAtTheBottom() {
            self.scrollToBottom(animated: true)
        }
        NotificationCenter.default.post(name: .messageSent, object: nil)
    }
    
}
