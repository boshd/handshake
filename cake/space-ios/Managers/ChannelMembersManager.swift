//
//  ChannelMembersManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-06.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

@objc protocol ChannelManagerDelegate: class {
    @objc optional func updateChannel(channel: Channel)
    func addMember(id: String)
    func removeMember(id: String)
    func channelDeleted(channelID: String)
}

class ChannelManager: NSObject {
    var channelReference: DocumentReference!
    var channelListener: ListenerRegistration!
    var channelParticipantsReference: CollectionReference!
    var channelParticipantsListener: ListenerRegistration!
    
    var userChannelsListener: ListenerRegistration!
    
    weak var delegate: ChannelManagerDelegate?
    
    func removeAllListeners() {
        if channelListener != nil {
            channelListener.remove()
        }
        
        if channelParticipantsListener != nil {
            channelParticipantsListener.remove()
        }
        
        if userChannelsListener != nil {
            userChannelsListener.remove()
        }
    }
    
    func setupListeners(_ channel: Channel?) {
        guard let channelID = channel?.id else { return }
        channelParticipantsReference = Firestore.firestore().collection("channels").document(channelID).collection("participantIds")
        channelParticipantsListener = channelParticipantsReference.addSnapshotListener({ (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let documentChanges = snapshot?.documentChanges else { return }
            documentChanges.forEach { diff in
                if (diff.type == .added) {
                    self.delegate?.addMember(id: diff.document.documentID)
                }
                if (diff.type == .removed) {
                    self.delegate?.removeMember(id: diff.document.documentID)
                }
            }
        })
    }

}
