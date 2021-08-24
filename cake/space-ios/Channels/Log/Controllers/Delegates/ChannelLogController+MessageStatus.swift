//
//  ChannelLogController+MessageStatus.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-25.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import AudioToolbox
import SafariServices

extension ChannelLogController {
    
    // MARK: - DATABASE MESSAGE STATUS
    func updateMessageStatus(messageRef: DocumentReference) {
        guard let uid = Auth.auth().currentUser?.uid, currentReachabilityStatus != .notReachable else { return }
        var senderID: String?
        
        messageRef.getDocument { (snapshot, error) in
            guard error == nil else { print(error?.localizedDescription ?? "error"); return }
            guard let data = snapshot?.data() else { return }
            
            senderID = data["fromId"] as? String
            // message here is being sent from current id? is it stuck at a specific message?
            
            guard uid != senderID,
                  (UIApplication.topViewController() is ChannelLogController ||
                    UIApplication.topViewController() is ChannelDetailsController ||
                    UIApplication.topViewController() is ParticipantsController ||
//                    UIApplication.topViewController() is UpdateChannelController ||
                    UIApplication.topViewController() is INSPhotosViewController ||
                    UIApplication.topViewController() is SFSafariViewController)
            else { senderID = nil; return }
            messageRef.updateData([
                "seen": true,
                "status": messageStatusRead
            ]) { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                }
                self.resetBadgeForSelf()
            }
        }
    }
    
    func updateMessageStatusUI(sentMessage: Message) {
        guard let messageToUpdate = channel?.messages.filter("messageUID == %@", sentMessage.messageUID ?? "").first else { return }
        try! realm.safeWrite {
            messageToUpdate.status = sentMessage.status
            let section = collectionView.numberOfSections - 1
            if section >= 0 {
                let index = self.collectionView.numberOfItems(inSection: section) - 1
                if index >= 0 {
                    UIView.performWithoutAnimation { [weak self] in
                        self?.collectionView.reloadItems(at: [IndexPath(item: index, section: section)] )
                    }
                }
            }
        }
        guard sentMessage.status == messageStatusDelivered,
        messageToUpdate.messageUID == self.groupedMessages.last?.messages.last?.messageUID,
        userDefaults.currentBoolObjectState(for: userDefaults.inAppSounds) else { return }
        SystemSoundID.playFileNamed(fileName: "sent", withExtenstion: "caf")
        
//        AudioServicesPlaySystemSound (1004)
    }
    
}
