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

            let alert = CustomAlertController(title_: "Confirmation", message: "Are you sure you want to delete and exit this event?", preferredStyle: .alert)
            alert.addAction(CustomAlertAction(title: "No", style: .default, handler: {
                self?.tableView.deselectRow(at: indexPath, animated: false)
            }))
            alert.addAction(CustomAlertAction(title: "Yes", style: .destructive, handler: {
                self?.deleteChannel(at: indexPath)
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        
        delete.backgroundColor = .systemRed
        delete.image = UIImage.init(named: "bucket")
        return delete
    }
    
    func deleteChannel(at indexPath: IndexPath) {
        guard currentReachabilityStatus != .notReachable else {
            displayErrorAlert(title: "Error", message: noInternetError, preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
            return
        }

        guard let theRealmChannels = theRealmChannels else { return }
        
        let channel = theRealmChannels[indexPath.row]
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channel.id,
              // let currentUserDocToDelete = currentUserReference?.collection("channelIds").document(channelID),
              let _ = channelsReference?.document(channelID)
              // let channelDocToDelete = self.channelsReference?.document(channelID).collection("participantIds").document(currentUserID)
        else { return }
        
        let text = "\(globalCurrentUser?.name ?? "Someone") left the group"
        let channelName = channel.name ?? ""
        let channelCopy = Channel(value: channel)

        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        let participantReference = Firestore.firestore().collection("users").document(currentUserID)
        ChannelManager.removeMember(channelReference: channelReference, userReference: participantReference, memberID: currentUserID, channelID: channelID) { error in
            if error != nil {
                print(error?.localizedDescription ?? "err")
                return
            }
            self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channelName, participantIDs: [], text: text, channel: channelCopy)
            
            if !RealmKeychain.defaultRealm.isInWriteTransaction {
                RealmKeychain.defaultRealm.beginWrite()
                let result = RealmKeychain.defaultRealm.objects(Channel.self).filter("id = '\(channel.id!)'")
                let messagesResult = channel.messages

                RealmKeychain.defaultRealm.delete(messagesResult)
                RealmKeychain.defaultRealm.delete(result)
                try! RealmKeychain.defaultRealm.commitWrite()
                
                if theRealmChannels.count == 0 {
                    self.channelsFetcher.cleanFetcherChannels()
                }
            }
            
            //self.navigationController?.popViewController(animated: true)
        }
        
//        let batch = Firestore.firestore().batch()
//        batch.deleteDocument(currentUserDocToDelete)
        
//        channelDocToDelete.delete { error in
//            if error != nil {
//                print(error?.localizedDescription ?? "")
//                return
//            }
//            self.configureTabBarBadge()
//
//            if let realmChannels = self.realmChannels, realmChannels.count <= 0 {
//                self.checkIfThereAnyActiveChats(isEmpty: true)
//            }
//        }
        
//        batch.deleteDocument(channelDocToDelete)
//        batch.commit { (error) in
//            if error != nil {
//                print(error?.localizedDescription ?? "")
//                return
//            }
//
//            self.configureTabBarBadge()
//
//            if let realmChannels = self.realmChannels, realmChannels.count <= 0 {
//                self.checkIfThereAnyActiveChats(isEmpty: true)
//            }
//        }
        
        
    }
}
