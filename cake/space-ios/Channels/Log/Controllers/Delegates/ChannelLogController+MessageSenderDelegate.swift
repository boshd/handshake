//
//  ChannelLogController+MessageSenderDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-19.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelLogController: MessageSenderDelegate {
    
    func update(mediaSending progress: Double, animated: Bool) {}
    
    func update(with values: [String: AnyObject]) {
        autoreleasepool {
            guard !realm.isInWriteTransaction else { return }
            
            collectionView.performBatchUpdates({
                realm.beginWrite()
                
                let message = Message(dictionary: preloadedCellData(values: values))
                message.status = messageStatusSending
                message.channel = channel
                message.isCrooked.value = false
                realm.create(Message.self, value: message, update: .modified)

                guard let newSectionTitle = message.shortConvertedTimestamp else { realm.cancelWrite(); return }
                let lastSection = groupedMessages.last?.title ?? ""
                let isNewSection = newSectionTitle != lastSection
                if isNewSection {
                    guard let messages = channel?.messages
                    .filter("shortConvertedTimestamp == %@", newSectionTitle)
                            .sorted(byKeyPath: "timestamp", ascending: true) else { realm.cancelWrite(); return }

                    let newSection = MessageSection(messages: messages, title: newSectionTitle)
                    groupedMessages.append(newSection)

                    let sectionIndex = self.groupedMessages.count - 1 >= 0 ? self.groupedMessages.count - 1 : 0
                    self.collectionView.insertSections(IndexSet([sectionIndex]))
                } else {
                    let sectionIndex = self.groupedMessages.count - 1 >= 0 ? self.groupedMessages.count - 1 : 0
                    let rowIndex = self.groupedMessages[sectionIndex].messages.count - 1 >= 0 ?
                    self.groupedMessages[sectionIndex].messages.count - 1 : 0

                    if self.groupedMessages[sectionIndex].messages.indices.contains(rowIndex - 1),
                       self.groupedMessages[sectionIndex].messages[rowIndex - 1].fromId == message.fromId {
                        self.groupedMessages[sectionIndex].messages[rowIndex - 1].isCrooked.value = false
                    }
                    self.collectionView.insertItems(at: [IndexPath(row: rowIndex, section: sectionIndex)])
                }
                self.groupedMessages.last?.messages.last?.isCrooked.value = true
                try! realm.commitWrite()
            }, completion: { (isCompleted) in

                let sectionIndex = self.groupedMessages.count - 1 >= 0 ? self.groupedMessages.count - 1 : 0

                let rowIndex = self.groupedMessages[sectionIndex].messages.count - 1 >= 0 ?
                self.groupedMessages[sectionIndex].messages.count - 1 : 0

                self.collectionView.performBatchUpdates({
                    UIView.performWithoutAnimation {
                        self.collectionView.reloadItems(at: [IndexPath(row: rowIndex, section: sectionIndex)])
                        if rowIndex - 1 >= 0 {
                            self.collectionView.reloadItems(at: [IndexPath(row: rowIndex - 1, section: sectionIndex)])
                        }
                    }
                }, completion: nil)
                self.scrollToBottom(animated: true)
                NotificationCenter.default.post(name: .messageSent, object: nil)
            })
        }
    }
    
    func preloadedCellData(values: [String: AnyObject]) -> [String: AnyObject] {
        var values = values
        values = messagesFetcher?.preloadCellData(to: values) ?? values
        return values
    }
}
