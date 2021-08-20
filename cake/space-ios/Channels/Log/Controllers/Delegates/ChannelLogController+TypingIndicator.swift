//
//  ChannelLogController+TypingIndicator.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-25.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation
import Firebase

extension ChannelLogController {
    
    func sendTypingStatus(data: NSDictionary) {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channel?.id
        else { return }
        Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").document(currentUserID).setData(data as! [String : Any], merge: true)
//        Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").document("XevIxNAQAPYxV4OWFhtQOIIJfH33").setData(data as! [String : Any], merge: true)
//        Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").document("ZFi01vpuzMhcpJWduO3KuAebDPv2").setData(data as! [String : Any], merge: true)
        
        
    }
    
    func observeTypingIndicator() {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channel?.id
        else { return }
        
        typingIndicatorCollectionListener = Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                self.handleTypingIndicatorAppearance(isEnabled: false)
                return
            }
            
            guard let empty = snapshot?.isEmpty else { return }
            
            if empty {
                self.handleTypingIndicatorAppearance(isEnabled: false)
            }
            
            if let typingIds = snapshot?.documents.map({ $0.documentID }) {
                self.typingUserIds = typingIds
            }
            
            snapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    if change.document.documentID != currentUserID {
                        self.handleTypingIndicatorAppearance(isEnabled: true)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 200.0) {
                            self.handleTypingIndicatorAppearance(isEnabled: false)
                        }
                        
                    }
                    
                }
                if change.type == .removed {
                    if let count = snapshot?.documents.count, count < 1 {
                        self.handleTypingIndicatorAppearance(isEnabled: false)
                    }
                }
            })
            
        }
    }
    
    func handleTypingIndicatorAppearance(isEnabled: Bool) {
        if isEnabled {
            guard collectionView.numberOfSections == groupedMessages.count else { return }
            hapticFeedback(style: .selectionChanged)
            self.typingIndicatorSection = ["TypingIndicator"]
            self.collectionView.performBatchUpdates ({
                self.collectionView.insertSections([groupedMessages.count])
            }, completion: { (isCompleted) in
                if self.isScrollViewAtTheBottom() {
                    if self.collectionView.contentSize.height < self.collectionView.bounds.height {
                        return
                    }
                    self.scrollToBottom(animated: true)
                }
            })
        } else {
            guard collectionView.numberOfSections == groupedMessages.count + 1 else { return }
            self.collectionView.performBatchUpdates ({
                self.typingIndicatorSection.removeAll()

                if self.collectionView.numberOfSections > groupedMessages.count {
                    self.collectionView.deleteSections([groupedMessages.count])

                    guard let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: groupedMessages.count)) as? TypingIndicatorCell else {
                        return
                    }
                    cell.invalidateTimer()
                    if isScrollViewAtTheBottom() {
                        self.scrollToBottom(animated: true)
                    }
                }
            }, completion: nil)
        }
    }
    
}
