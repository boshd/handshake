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
import RealmSwift

@objc protocol ChannelManagerDelegate {
    func nameUpdated(name: String)
    func startTimeUpdated(startTime: Int64)
    func endTimeUpdated(endTime: Int64)
    func locationUpdated(latitude: Double, longitude: Double, locationName: String)
    func adminsUpdated(admins: Array<String>)
    func isRemoteUpdated(_: Bool)
    // func isCancelledUpdated(_: Bool)
    
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
        guard let channel = channel else { return }
        // CHANNEL UPDATING
        
        Firestore.firestore().collection("channels").document(channelID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            guard let dictionary = snapshot?.data() as [String: AnyObject]? else { return }
            let newChannel = Channel(dictionary: dictionary)
            self.processChanges(old: channel, new: newChannel)
        }
        
        
        // USER ADDITION AND DELETION
        
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
    
    fileprivate func processChanges(old: Channel, new: Channel) {
        if let newName = new.name, old.name != newName {
            delegate?.nameUpdated(name: newName)
        }
        
        if let newStartTime = new.startTime.value, old.startTime.value != newStartTime {
            delegate?.startTimeUpdated(startTime: newStartTime)
        }
        
        if let newEndTime = new.endTime.value, old.endTime.value != newEndTime {
            delegate?.endTimeUpdated(endTime: newEndTime)
        }
        
        if  let newLat = new.latitude.value,
            let newLong = new.longitude.value,
            let newLocationName = new.locationName,
            old.latitude.value != newLat && old.longitude.value != newLong && old.locationName != newLocationName {
            delegate?.locationUpdated(latitude: newLat, longitude: newLong, locationName: newLocationName)
        }
        
        if old.admins != new.admins {
            //delegate?.adminsUpdated(admins: new.admins)
        }
        
        if let newIsRemote = new.isRemote.value, old.isRemote.value != newIsRemote {
            delegate?.isRemoteUpdated(newIsRemote)
        }
    }
    
    
    // MARK: - Channel participant action handlers
    public static func removeAdmin(ref: DocumentReference, memberID: String, channelID: String, completion: @escaping (Error?) -> ()) {
        ref.updateData([
            "admins": FieldValue.arrayRemove([memberID])
        ], completion: { (error) in
            globalIndicator.dismiss()
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(error)
                return
            }
            completion(nil)
        })
    }
    
    public static func makeAdmin(ref: DocumentReference, memberID: String, channelID: String, completion: @escaping (Error?) -> ()) {
        ref.updateData([
            "admins": FieldValue.arrayUnion([memberID])
        ], completion: { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                completion(error)
                return
            }
            completion(nil)
        })
    }
    
    public static func removeMember(channelReference: DocumentReference, userReference: DocumentReference, memberID: String, channelID: String, completion: @escaping (Error?) -> ()) {
        
        let batch = Firestore.firestore().batch()
        
        batch.deleteDocument(userReference.collection("channelIds").document(channelID))
        batch.deleteDocument(channelReference.collection("participantIds").document(memberID))
        batch.updateData([
            "participantIds": FieldValue.arrayRemove([memberID]),
            "admins": FieldValue.arrayRemove([memberID]),
            "goingIds": FieldValue.arrayRemove([memberID]),
            "maybeIds": FieldValue.arrayRemove([memberID]),
            "notGoingIds": FieldValue.arrayRemove([memberID]),
        ], forDocument: channelReference)
        
        batch.commit { error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                completion(error)
            }
            completion(nil)
        }
    }
    /*
     going: true false nil
     */
    public static func rsvp(channelReference: DocumentReference, memberID: String, rsvp: )

}
