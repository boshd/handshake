//
//  ChannelLogHistoryFetcher.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-02.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Firebase
import FirebaseFirestore

protocol ChannelLogHistoryDelegate: class {
    func channelLogHistory(isEmpty: Bool)
    func channelLogHistory(updated newMessages: [Message])
}

class ChannelLogHistoryFetcher: NSObject {
    
    weak var delegate: ChannelLogHistoryDelegate?
    
    fileprivate var loadingGroup = DispatchGroup()
    fileprivate let messagesFetcher = MessagesFetcher()

    fileprivate var messages = [Message]()
    fileprivate var channel: Channel?

    fileprivate var messagesToLoad: Int!
    
    public func loadPreviousMessages(_ messages: [Message], _ channel: Channel, _ messagesToLoad: Int) {
        self.messages = messages
        self.channel = channel
        self.messagesToLoad = messagesToLoad
        loadChannelHistory()
    }
    
    fileprivate func loadChannelHistory() {
        guard let currentUserID = Auth.auth().currentUser?.uid, let channelID = channel?.id else { return }
        if messages.count <= 0 { delegate?.channelLogHistory(isEmpty: true) }
        getFirstID(currentUserID, channelID)
    }
    
    fileprivate func getFirstID(_ currentUserID: String, _ channelID: String) {
        let firstIDReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID).collection("messageIds")
        //let firstIDReference = Firestore.firestore().collection("channels").document(channelID).collection("thread")
        let numberOfMessagesToLoad = messagesToLoad + messages.count
        let firstIDQuery = firstIDReference.order(by: "timestamp", descending: true).limit(to: numberOfMessagesToLoad)
        firstIDQuery.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { print(error?.localizedDescription ?? "error"); return }
            guard let firstDocument = documents.last else { return }
            self.getLastID(firstDocument, currentUserID, channelID)
        }
    }
        
    fileprivate func getLastID(_ firstDocument: DocumentSnapshot, _ currentUserID: String, _ channelID: String) {
        let nextMessageIndex = messages.count + 1
        let lastIDReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID).collection("messageIds")
        let lastIDQuery = lastIDReference.order(by: "timestamp", descending: true).limit(to: nextMessageIndex)
        lastIDQuery.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { print(error?.localizedDescription ?? "error"); return }
            guard let lastID = documents.last?.documentID, let lastDocument = documents.last else { return }
            if (firstDocument.documentID == lastID) && self.messages.contains(where: { (message) -> Bool in
                return message.messageUID == lastID
            }) {
              self.delegate?.channelLogHistory(isEmpty: false)
              return
            }
            self.getRange(firstDocument, lastDocument, currentUserID, channelID)
        }
    }
    
    fileprivate func getRange(_ firstDocument: DocumentSnapshot, _ lastDocument: DocumentSnapshot, _ currentUserID: String, _ channelID: String) {
        let rangeReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID).collection("messageIds")
        let rangeQuery = rangeReference.order(by: "timestamp", descending: false).start(atDocument: firstDocument).end(atDocument: lastDocument)
        rangeQuery.getDocuments { (snapshot, error) in
            guard let docs = snapshot?.documents else { print(error?.localizedDescription ?? "error"); return }
            self.getMessages(from: rangeQuery, documents: docs, channelID: channelID)
            self.notifyWhenGroupFinished()
        }
    }
    
    var previousMessages = [Message]()
    fileprivate func getMessages(from query: Query, documents: [DocumentSnapshot], channelID: String) {
        previousMessages = [Message]()
        for _ in 0 ..< documents.count { self.loadingGroup.enter() }
        for document in documents  {
            guard var dictionary = document.data() as [String:AnyObject]? else { return }
            let messageUID = document.documentID
            dictionary.updateValue(messageUID as AnyObject, forKey: "messageUID")
            dictionary = self.messagesFetcher.preloadCellData(to: dictionary)
            let message = Message(dictionary: dictionary)
            message.channel = self.channel
            self.messagesFetcher.loadUserNameForOneMessage(message: message, completion: { (_, newMessage)  in
                self.previousMessages.append(newMessage)
                self.loadingGroup.leave()
            })
        }
    }

    fileprivate func notifyWhenGroupFinished() {
        loadingGroup.notify(queue: DispatchQueue.main) {
            let updatedMessages = self.previousMessages
            self.delegate?.channelLogHistory(updated: updatedMessages)
        }
    }
}
