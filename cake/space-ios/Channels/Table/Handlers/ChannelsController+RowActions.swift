//
//  ChannelsController+RowActions.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-05.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import RealmSwift

extension ChannelsController {
    
    func setupDeleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let delete = UIContextualAction.init(style: .destructive, title: nil) { [weak self] _,_,_ in
            hapticFeedback(style: .impact)
            let alert = CustomAlertController(title_: "Confirmation", message: "Are you sure you want to delete and exit this event?", preferredStyle: .alert)
            alert.addAction(CustomAlertAction(title: "No", style: .default, handler: {
                self?.channelsContainerView.tableView.deselectRow(at: indexPath, animated: false)
            }))
            alert.addAction(CustomAlertAction(title: "Yes", style: .destructive, handler: {
                self?.deleteChannel(at: indexPath)
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        
        delete.backgroundColor = .priorityRed()
        delete.image = UIImage.init(named: "bucket")
        return delete
    }
    
    func deleteChannel(at indexPath: IndexPath) {
        print("HERE AT ROW ACTIONS")
        guard currentReachabilityStatus != .notReachable else {
            displayErrorAlert(title: "Error", message: noInternetError, preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
            return
        }

        guard let theRealmChannels = theRealmChannels else { return }
        
        let channel = theRealmChannels[indexPath.row]
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channel.id,
              let currentUserDocToDelete = currentUserReference?.collection("channelIds").document(channelID),
              let docToUpdate = channelsReference?.document(channelID),
              let channelDocToDelete = self.channelsReference?.document(channelID).collection("participantIds").document(currentUserID)
        else { return }
        
        // copy values from channel before it's purged from realm
        let deletedChannelID = String(channel.id!)
        let deletedChannelName = String(channel.name!)
        let admins = Array(channel.admins)
        let participantIds = Array(channel.participantIds)
        let channelToBeRemoved = Channel(value: channel)
        
//        if participantIds.contains(currentUserID) {
//            self.informationMessageSender.sendInformationMessage(channelID: deletedChannelID, channelName: deletedChannelName, participantIDs: participantIds, text: "\(globalCurrentUser?.name ?? "") has left the event")
//        }
        
        if !RealmKeychain.defaultRealm.isInWriteTransaction {
            RealmKeychain.defaultRealm.beginWrite()
            let result = RealmKeychain.defaultRealm.objects(Channel.self).filter("id = '\(channel.id!)'")
            let messagesResult = channel.messages

            RealmKeychain.defaultRealm.delete(messagesResult)
            RealmKeychain.defaultRealm.delete(result)
            try! RealmKeychain.defaultRealm.commitWrite()
            
            if theRealmChannels.count == 0 {
                channelsFetcher.cleanFetcherChannels()
            }
            globalIndicator.showSuccess(withStatus: "Deleted")
            print("channel deleted")
        }
        
        if participantIds.contains(currentUserID) {
            print("in here lol")
            
            let batch = Firestore.firestore().batch()
            batch.deleteDocument(currentUserDocToDelete)
            if admins.count == 1 && participantIds.count > 1 && admins.contains(currentUserID) {
                if let replacementUserId = participantIds.filter({ $0 != currentUserID }).first {
                    batch.updateData([
                        "admins": FieldValue.arrayUnion([replacementUserId])
                    ], forDocument: docToUpdate)
                }
            }
            batch.deleteDocument(channelDocToDelete)
            batch.updateData([
                "participantIds": FieldValue.arrayRemove([currentUserID]),
                "admins": FieldValue.arrayRemove([currentUserID]),
                "goingIds": FieldValue.arrayRemove([currentUserID]),
                "maybeIds": FieldValue.arrayRemove([currentUserID]),
                "notGoingIds": FieldValue.arrayRemove([currentUserID])
            ], forDocument: docToUpdate)

            batch.commit { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                Firestore.firestore().runTransaction { (transaction, errorPointer) -> Any? in
                    let document: DocumentSnapshot
                    do {
                        try document = transaction.getDocument(docToUpdate)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    guard let oldFCMTokensMap = document.data()?["fcmTokens"] as? [String:String] else {
                       let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                               NSLocalizedDescriptionKey: "Unable to retrieve fcmTokens from snapshot \(document)"
                           ]
                       )
                       errorPointer?.pointee = error
                       return nil
                    }
                    var newFCMTokensMap = oldFCMTokensMap
                    newFCMTokensMap.removeValue(forKey: currentUserID)
                    transaction.updateData(["fcmTokens": newFCMTokensMap], forDocument: docToUpdate)
                    return nil
                } completion: { (object, error) in
                    if let error = error {
                        print("Transaction failed: \(error)")
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
                
                self.informationMessageSender.sendInformationMessage(channelID: deletedChannelID, channelName: deletedChannelName, participantIDs: participantIds, text: "\(globalCurrentUser?.name ?? "") has left the event", channel: channelToBeRemoved)

                if let realmChannels = self.realmChannels, realmChannels.count <= 0 {
                    self.checkIfThereAnyActiveChats(isEmpty: true)
                }
            }
        } else {
            print("NOT THERE DAMN.")
            if let realmChannels = self.realmChannels, realmChannels.count <= 0 {
                self.checkIfThereAnyActiveChats(isEmpty: true)
            }
        }
        
        
    }
}
