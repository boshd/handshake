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
    func channelUpdated()
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
            channelListener = nil
        }
        
        if channelParticipantsListener != nil {
            channelParticipantsListener.remove()
            channelParticipantsListener = nil
            print("channelParticipantsListener became nil")
        }
        
        if userChannelsListener != nil {
            userChannelsListener.remove()
            userChannelsListener = nil
        }
    }
    
    func setupListeners(_ channel: Channel?) {
        guard let channelID = channel?.id else { return }
        // CHANNEL UPDATING
        
//        if channelListener == nil {
            channelListener = Firestore.firestore().collection("channels").document(channelID).addSnapshotListener { [weak self] snapshot, error in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    return
                }
                
                // self?.delegate?.channelUpdated()
            }
//        }
        
        
        // USER ADDITION AND DELETION
        
        channelParticipantsReference = Firestore.firestore().collection("channels").document(channelID).collection("participantIds")
//        print("attempting to setup channelParticipantsListener")
//        if channelParticipantsListener == nil {
//        var first = true
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
//        }
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
    
    func channelUpdated() {
        
    }
    
}

// MARK: - Adminship

extension ChannelManager {
    
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
}

// MARK: - Removing member

extension ChannelManager {
    public static func removeMember(channelReference: DocumentReference, userReference: DocumentReference, memberID: String, channelID: String, completion: @escaping (Error?) -> ()) {
        print("pre remove member")
        removeMemberBatchOperation(userReference: userReference, channelReference: channelReference, channelID: channelID, memberID: memberID) { error in
            if error != nil {
                print(error?.localizedDescription ?? "error removeUserBatchOperation")
                completion(error)
            }
            removeUserFromFCMTokenMapTransaction(userToBeRemoved: memberID, currentChannelReference: channelReference) { error in
                if error != nil {
                    print(error?.localizedDescription ?? "error in transaction")
                    completion(error)
                }
                completion(nil)
            }
        }
    }
    
    fileprivate static func removeMemberBatchOperation(userReference: DocumentReference, channelReference: DocumentReference, channelID: String, memberID: String, completion: @escaping (Error?) -> ()) {
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
    
}

extension ChannelManager {
    
    // MARK: - Adding members
    public static func addMembers(memberIds: [String], channelID: String, completion: @escaping (Error?) -> ()) {
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        addMembersBatchOperation(memberIds: memberIds, channelReference: channelReference, channelID: channelID) { error in
            if error != nil {
                print(error?.localizedDescription ?? "error removeUserBatchOperation")
                completion(error)
            }
            
            fetchMemeberFCMTokensMap(memberIds: memberIds) { dict, error in
                if error != nil {
                    print(error?.localizedDescription ?? "err")
                    completion(error)
                }
                addUsersFromFCMTokenMapTransaction(fcmDict: dict, currentChannelReference: channelReference) {
                    completion(nil)
                }
            }
        }
    }
    
    fileprivate static func addMembersBatchOperation(memberIds: [String], channelReference: DocumentReference, channelID: String, completion: @escaping (Error?) -> ()) {
        let usersReference = Firestore.firestore().collection("users")
        let currentChannelParticipantIDsReference = Firestore.firestore().collection("channels").document(channelID).collection("participantIds")
        
        let batch = Firestore.firestore().batch()
        
        for memberId in memberIds {
            batch.setData(["participantId": memberId], forDocument: currentChannelParticipantIDsReference.document(memberId))
            batch.updateData([
                "participantIds": FieldValue.arrayUnion([memberId])
            ], forDocument: channelReference)
            batch.setData([
                "channelId": channelID
            ], forDocument: usersReference.document(memberId).collection("channelIds").document(channelID))
        }
        batch.commit { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    fileprivate static func fetchMemeberFCMTokensMap(memberIds: [String], completion: @escaping ([String:String], Error?) -> ()) {
        var membersFCMTokensDict = [String:String]()
        
        let group = DispatchGroup()
        
        for memberId in memberIds {
            group.enter()
            Firestore.firestore().collection("fcmTokens").document(memberId).getDocument { (snapshot, error) in
                group.leave()
                guard let fcmDict = snapshot?.data(), let fcmToken = fcmDict["fcmToken"] as? String else { return }
                membersFCMTokensDict[memberId] = fcmToken
            }
        }
        
        group.notify(queue: .main) {
            completion(membersFCMTokensDict, nil)
        }
        
    }
    
}

// MARK: - RSVP

extension ChannelManager {
    public static func rsvp(channelReference: DocumentReference, memberID: String, rsvp: EventRSVP, completion: @escaping (Error?) -> ()) {
        
        // batch is used here for cosmetics
        let batch = Firestore.firestore().batch()
        
        switch rsvp {
            case .going:
                batch.updateData([
                    "goingIds": FieldValue.arrayUnion([memberID]),
                    "notGoingIds": FieldValue.arrayRemove([memberID]),
                    "maybeIds": FieldValue.arrayRemove([memberID])
                ], forDocument: channelReference)
            case .notGoing:
                batch.updateData([
                    "goingIds": FieldValue.arrayRemove([memberID]),
                    "notGoingIds": FieldValue.arrayUnion([memberID]),
                    "maybeIds": FieldValue.arrayRemove([memberID])
                ], forDocument: channelReference)
            case .tentative:
                batch.updateData([
                    "goingIds": FieldValue.arrayRemove([memberID]),
                    "notGoingIds": FieldValue.arrayRemove([memberID]),
                    "maybeIds": FieldValue.arrayUnion([memberID])
                ], forDocument: channelReference)
        }
        
        batch.commit { error in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }

}

// MARK: - FCM Token Transactions

extension ChannelManager {
    
    fileprivate static func removeUserFromFCMTokenMapTransaction(userToBeRemoved: String, currentChannelReference: DocumentReference, completion: @escaping ((Error?) -> Void)) {
        Firestore.firestore().runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
//            do {
            try! document = transaction.getDocument(currentChannelReference)
//            } catch let fetchError as NSError {
//                print(fetchError.localizedDescription)
//                completion(fetchError)
//            }
            
            guard let oldFCMTokensMap = document.data()?["fcmTokens"] as? [String:String] else { return nil }
            var newFCMTokensMap = oldFCMTokensMap
            
            if newFCMTokensMap[userToBeRemoved] != nil, let index = newFCMTokensMap.index(forKey: userToBeRemoved) {
                newFCMTokensMap.remove(at: index)
            }
            transaction.updateData(["fcmTokens": newFCMTokensMap], forDocument: currentChannelReference)
            return nil
        } completion: { (object, error) in
            if let error = error {
                completion(error)
                print("Transaction failed: \(error)")
            } else {
                completion(nil)
                print("Transaction successfully committed!")
            }
        }
    }
    
    fileprivate static func addUsersFromFCMTokenMapTransaction(fcmDict: [String:String], currentChannelReference: DocumentReference, completion: @escaping (() -> Void)) {
        Firestore.firestore().runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(currentChannelReference)
            } catch let fetchError as NSError {
                print(fetchError.localizedDescription)
                return nil
            }
            
            guard let oldFCMTokensMap = document.data()?["fcmTokens"] as? [String:String] else { return nil }
            
            var newFCMTokensMap = oldFCMTokensMap
            
            newFCMTokensMap.merge(dict: fcmDict)
            
            transaction.updateData(["fcmTokens": newFCMTokensMap], forDocument: currentChannelReference)
            return nil
        } completion: { (object, error) in
            completion()
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
//    fileprivate static func fcmTokenMapTransaction_(newFcmTokensMap: [String:String], currentChannelReference: DocumentReference, completion: @escaping (() -> Void)) {
//
//    }
}

enum EventRSVP {
    case going
    case notGoing
    case tentative
}


