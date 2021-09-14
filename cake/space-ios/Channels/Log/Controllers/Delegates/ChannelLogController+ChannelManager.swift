//
//  ChannelLogController+ChannelManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

extension ChannelLogController: ChannelManagerDelegate {
    
    func channelUpdated() {
        if self.isCurrentUserMemberOfCurrentGroup() {
            self.setupTitle()
            self.setupHeaderView()
        }
    }
    
    func nameUpdated(name: String) {
        try! realm.safeWrite {
            self.channel?.name = name
        }
        if self.isCurrentUserMemberOfCurrentGroup() {
            self.setupTitle()
        }
    }
    
    func nameUpdated(description: String) {
        try! realm.safeWrite {
            self.channel?.description_ = description
        }
        if self.isCurrentUserMemberOfCurrentGroup() {
            self.setupTitle()
        }
    }
    
//    func fcmTokensUpdated(tokens: String) {
//        print("description updated")
//        try! realm.safeWrite {
//            self.channel?.description_ = description
//        }
//        if self.isCurrentUserMemberOfCurrentGroup() {
//            self.configureTitleView()
//        }
//    }
    
    
    
    func startTimeUpdated(startTime: Int64) {
        try! realm.safeWrite {
            self.channel?.startTime = RealmOptional(startTime)
        }
        if self.isCurrentUserMemberOfCurrentGroup() {
            setupHeaderView()
        }
    }
    
    func endTimeUpdated(endTime: Int64) {
        try! realm.safeWrite {
            self.channel?.endTime = RealmOptional(endTime)
        }
        if self.isCurrentUserMemberOfCurrentGroup() {
            setupHeaderView()
        }
    }
    
    func locationUpdated(latitude: Double, longitude: Double, locationName: String) {
        try! realm.safeWrite {
            self.channel?.latitude = RealmOptional(latitude)
            self.channel?.longitude = RealmOptional(latitude)
            self.channel?.locationName = locationName
        }
        if self.isCurrentUserMemberOfCurrentGroup() {
            setupHeaderView()
        }
    }
    
    func adminsUpdated(admins: [String]) {
        try! realm.safeWrite {
            // does this actually work?
            self.channel?.admins.assign(admins)
        }
        if self.isCurrentUserMemberOfCurrentGroup() {
            setupHeaderView()
        }
    }
    
    func isRemoteUpdated(_ isRemote: Bool) {
        try! realm.safeWrite {
            self.channel?.isRemote = RealmOptional(isRemote)
        }
        if self.isCurrentUserMemberOfCurrentGroup() {
            // configure virtuality
        }
    }
    
//    func isCancelledUpdated(_ isCancelled: Bool) {
//        try! realm.safeWrite {
//            self.channel?.isCancelled = RealmOptional(isCancelled)
//        }
//        if self.isCurrentUserMemberOfCurrentGroup() {
//            // configure cancellation
//        }
//    }
    
    func channelDeleted(channelID: String) {
        guard let currentChannelID = channel?.id else { return }
        if currentChannelID == channelID {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func addMember(id: String) {
        guard let members = self.channel?.participantIds else { return }
        if let _ = members.firstIndex(where: { (memberID) -> Bool in
            return memberID == id
        }) {} else {
            try! realm.safeWrite {
                self.channel?.participantIds.append(id)
            }
        }
        
        self.changeUIAfterChildAddedIfNeeded()
    }
    
    func removeMember(id: String) {
        guard let members = self.channel?.participantIds else { return }
        guard let memberIndex = members.firstIndex(where: { (memberID) -> Bool in
            return memberID == id
        }) else { return }
        try! realm.safeWrite {
            self.channel?.participantIds.remove(at: memberIndex)
        }
        
        self.changeUIAfterChildRemovedIfNeeded()
    }
    
    fileprivate func changeUIAfterChildAddedIfNeeded() {
        if isCurrentUserMemberOfCurrentGroup() {
            setupTitle()
            if typingIndicatorCollectionListener == nil {
                reloadInputViews()
                inputAccessoryPlaceholder.add(inputContainerView)
                observeTypingIndicator()
                addChannelControllerTypingObserver()
                channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = true
                channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = false
            }
        }
    }
    
    fileprivate func changeUIAfterChildRemovedIfNeeded() {
        if isCurrentUserMemberOfCurrentGroup() {
            setupTitle()
            inputAccessoryPlaceholder.add(inputContainerView)
        } else {
            //channelManager.removeAllListeners()
            
//            if channelManager.channelListener != nil {
//                channelManager.channelListener.remove()
//                channelManager.channelListener = nil
//            }
            // we wont remove parrticipant listener
             
//            if channelParticipantsListener != nil {
//                channelParticipantsListener.remove()
//                channelParticipantsListener = nil
//                print("channelParticipantsListener became nil")
//            }
            
//            if channelManager.userChannelsListener != nil {
//                channelManager.userChannelsListener.remove()
//                channelManager.userChannelsListener = nil
//            }
            
            messagesFetcher?.removeListener()
            self.inputContainerView.resignAllResponders()
            reloadInputViews()
            
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = false
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = true
            
            self.inputContainerView.resignAllResponders()
            handleTypingIndicatorAppearance(isEnabled: false)
            removeSubtitleInGroupChat()
            reloadInputViews()
            
            inputAccessoryPlaceholder.add(inputBlockerContainerView)
            navigationItem.rightBarButtonItem?.isEnabled = false
            // remove typing indicator listener
            if typingIndicatorCollectionListener != nil {
                typingIndicatorCollectionListener?.remove()
                typingIndicatorCollectionListener = nil
            }
        }
     }
    
    func isCurrentUserMemberOfCurrentGroup() -> Bool {
        guard let membersIDs = channel?.participantIds,
              let uid = Auth.auth().currentUser?.uid, membersIDs.contains(uid) else { return false }
        return true
    }
    
    func addChannelControllerTypingObserver() {
        observeTypingIndicator()
    }
    
    fileprivate func removeSubtitleInGroupChat() {
        if let title = channel?.name {
            let subtitle = ""
            print("arriveeeeeeeeeeeeeeeeeeeeeeeee")
            navigationItem.setTitle(title: title, subtitle: subtitle, url: nil)
            return
        }
    }
}
