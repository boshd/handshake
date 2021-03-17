//
//  ChannelLogController+ChannelManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

extension ChannelLogController: ChannelManagerDelegate {
    
    func channelDeleted(channelID: String) {
        guard let currentChannelID = channel?.id else { return }
        if currentChannelID == channelID {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func addMember(id: String) {
        guard let channel = self.channel, !channel.isInvalidated else { return }
        
        guard let members = self.channel?.participantIds else { return }
        if let _ = members.firstIndex(where: { (memberID) -> Bool in
            return memberID == id
        }) {
        } else {
            try! realm.safeWrite {
                self.channel?.participantIds.append(id)
            }
        }
        
        let obj: [String: Any] = ["id": id]
        NotificationCenter.default.post(name: .memberAdded, object: obj)
    }
    
    func removeMember(id: String) {
        guard let channel = self.channel, !channel.isInvalidated else { return }
        
        guard let members = self.channel?.participantIds else { return }
        guard let memberIndex = members.firstIndex(where: { (memberID) -> Bool in
            return memberID == id
        }) else { return }

        try! realm.safeWrite {
            self.channel?.participantIds.remove(at: memberIndex)
        }
        
        let obj: [String: Any] = ["id": id]
        NotificationCenter.default.post(name: .memberRemoved, object: obj)
        
        self.changeUIAfterChildRemovedIfNeeded()
    }
    
    fileprivate func changeUIAfterChildRemovedIfNeeded() {
        
        if isCurrentUserMemberOfCurrentGroup() {
        } else {
            messagesFetcher?.removeListener()
            self.inputContainerView.resignAllResponders()
            reloadInputViews()
            reloadInputView(view: inputBlockerContainerView)
            
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = false
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = true
        }
     }
    
    func isCurrentUserMemberOfCurrentGroup() -> Bool {
        guard let membersIDs = channel?.participantIds,
              let uid = Auth.auth().currentUser?.uid, membersIDs.contains(uid) else { return false }
        return true
    }
}
