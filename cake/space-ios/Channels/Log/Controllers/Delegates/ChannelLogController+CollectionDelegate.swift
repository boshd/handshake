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
        reference.addSnapshotListener { (snapshot, error) in
            guard error == nil else { print(error?.localizedDescription ?? ""); return }
            guard let exists = snapshot?.exists, exists, let data = snapshot?.data(), let messageStatus = data["status"] as? String else { return }
            message.status = messageStatus
            self.updateMessageStatusUI(sentMessage: message)
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
        message.channel = channel
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
            guard let messages = channel?.messages.filter("shortConvertedTimestamp == %@", newSectionTitle)
                .sorted(byKeyPath: "timestamp", ascending: true) else { try! self.realm.commitWrite(); return }

            let newSection = MessageSection(messages: messages, title: newSectionTitle)

            let insertionIndex = groupedMessages.insertionIndexOf(elem: newSection) { (section1, section2) -> Bool in
                return Date.dateFromCustomString(customString: section1.title ?? "") < Date.dateFromCustomString(customString: section2.title ?? "")
            }
            
            groupedMessages.insert(newSection, at: insertionIndex)
            collectionView.performBatchUpdates({
                    collectionView.insertSections([insertionIndex])
            }) { (isCompleted) in
                self.performAdditionalUpdates(reference: reference)
            }
        } else {
            guard let indexPath = Message.get(indexPathOf: message, in: groupedMessages) else { try! self.realm.commitWrite(); return }

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
    
//    @available(iOS 13.0, *)
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
//            return self.makeContextMenu(for: indexPath.row)
//        })
//    }
//    
//    @available(iOS 13.0, *)
//    fileprivate func makeContextMenu(for index:Int) -> UIMenu {
//        var actions = [UIAction]()
//        for item in self.contextMenuItems {
//            let action = UIAction(title: item.title, identifier: nil, discoverabilityTitle: nil) { _ in
//                // self.didSelectContextMenu(menuIndex: item.index, cellIndex: index)  // Here I have both cell index & context menu item index
//            }
//            actions.append(action)
//        }
//        let cancel = UIAction(title: "Cancel", attributes: .destructive) { _ in}
//        actions.append(cancel)
//        return UIMenu(title: "", children: actions)
//    }
    
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
            self.collectionView.scrollToBottom(animated: true)
        }
        NotificationCenter.default.post(name: .messageSent, object: nil)
    }
    
}
