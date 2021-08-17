//
//  MessagesFetcher.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-09.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

protocol MessagesDelegate: class {
    func messages(shouldBeUpdatedTo messages: [Message], channel: Channel, controller: UIViewController)
    func messages(shouldChangeMessageStatusToReadAt reference: DocumentReference, controller: UIViewController)
//    func messages(shouldChangeMessageStatusToReadAt reference: CollectionReference, controller: UIViewController)
}

protocol CollectionDelegate: class {
  func collectionView(shouldBeUpdatedWith message: Message, reference: DocumentReference)
  func collectionView(shouldRemoveMessage id: String)
  func collectionView(shouldUpdateOutgoingMessageStatusFrom reference: DocumentReference, message: Message)
}

class MessagesFetcher: NSObject {
    private var messages = [Message]()

    var messageReference: DocumentReference!
    
    var userMessagesReference: Query!

    private  let messagesToLoad = 3

    weak var delegate: MessagesDelegate?

    weak var collectionDelegate: CollectionDelegate?
    
    var threadListener: ListenerRegistration?

    var isInitialChatMessagesLoad = true

    private var loadingMessagesGroup = DispatchGroup()
    private var loadingNamesGroup = DispatchGroup()
    
//    fileprivate var individualChannelListenersDict: [String:ListenerRegistration] = [String:ListenerRegistration]()
    
    func removeListener() {
        if threadListener != nil {
            threadListener?.remove()
            threadListener = nil
        }
    }
    
    func loadMessagesData(for channel: Channel, controller: UIViewController?) {
        guard let currentUserID = Auth.auth().currentUser?.uid, let channelID = channel.id, let controller = controller else { return }
        
        // remember, the messageId docs don't have timestamps
        userMessagesReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID).collection("messageIds").order(by: "timestamp").limit(toLast: messagesToLoad)
            
            //.order(by: "timestamp", descending: true).limit(toLast: messagesToLoad)
        
        loadingMessagesGroup.enter()
        newLoadMessages(reference: userMessagesReference, channelID: channelID, channel: channel)
        
        loadingMessagesGroup.notify(queue: .main) {
            guard self.messages.count != 0 else {
                if self.isInitialChatMessagesLoad {
                    self.messages = self.sortedMessages(unsortedMessages: self.messages)
                }
                self.isInitialChatMessagesLoad = false
                self.delegate?.messages(shouldBeUpdatedTo: self.messages, channel: channel, controller: controller)
                return
            }
            self.loadingNamesGroup.enter()
            self.newLoadUserames()
            // seen, badge and name loading are all chalked and looks like they're all tied to the same issues.
            // sometimes they work and sometimes they don't! Investigate!
            self.loadingNamesGroup.notify(queue: .main, execute: {
                print("NOTIFICATION IN ACTION")
                if self.isInitialChatMessagesLoad {
                    self.messages = self.sortedMessages(unsortedMessages: self.messages)
                }
                self.isInitialChatMessagesLoad = false
                self.delegate?.messages(shouldChangeMessageStatusToReadAt: self.messageReference, controller: controller)
                self.delegate?.messages(shouldBeUpdatedTo: self.messages, channel: channel, controller: controller)
            })
        }
    }
    
    func newLoadMessages(reference: Query, channelID: String, channel: Channel) {
        var loadedMessages = [Message]()
        let loadedMessagesGroup = DispatchGroup()

        reference.getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            guard let docCount = snapshot?.documents.count else { return }
            
            print(snapshot?.documents.map({ $0.data() }))
            
            for _ in 0 ..< docCount { loadedMessagesGroup.enter() }

            loadedMessagesGroup.notify(queue: .main) { [weak self] in
                self?.messages = loadedMessages
                self?.loadingMessagesGroup.leave()
            }

            self.threadListener = reference.addSnapshotListener { (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    return
                }
                guard let documentChanges = snapshot?.documentChanges else { return }
                
                print("in thread listener \(snapshot?.documents.count) messages")
                
                documentChanges.forEach { (diff) in
                    if diff.type == .added {
                        let messageUID = diff.document.documentID
                        self.messageReference = Firestore.firestore().collection("messages").document(messageUID)
                        self.messageReference.getDocument { (snapshot, error) in
                            if error != nil {
                                print(error?.localizedDescription ?? "error")
                                return
                            }

                            guard var dictionary = snapshot?.data() as [String: AnyObject]? else { return }
                            dictionary.updateValue(messageUID as AnyObject, forKey: "messageUID")
                            dictionary = self.preloadCellData(to: dictionary)
                            guard self.isInitialChatMessagesLoad else {
                                self.handleMessageInsertionInRuntime(newDictionary: dictionary)
                                return
                            }

                            let message = Message(dictionary: dictionary)
                            message.channel = channel

                            if message.timestamp.value ?? 0 >= self.messages.first?.timestamp.value ?? 0 {
                                loadedMessages.append(message)
                            }
                            loadedMessagesGroup.leave()
                        }
                    }
                }
            }
        }
    }
    
    func newLoadUserames() {
        let loadedUserNamesGroup = DispatchGroup()

        for _ in messages {
          loadedUserNamesGroup.enter()
        }

        loadedUserNamesGroup.notify(queue: .main, execute: {
          self.loadingNamesGroup.leave()
        })
        for index in 0...messages.count - 1 {
            guard let senderID = messages[index].fromId else { continue }
            // check if user is in realm first
            if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == senderID }) {
                if let localName = realmUser.localName {
                    self.messages[index].senderName = localName
                } else {
                    guard let name = realmUser.name else {
                        loadedUserNamesGroup.leave()
                        return
                    }
                    self.messages[index].senderName = name
                }
                loadedUserNamesGroup.leave()
                
            } else {
                let reference = Firestore.firestore().collection("users").document(senderID)
                reference.getDocument { (documentSnapshot, error) in
                    guard let dictionary = documentSnapshot?.data() as [String: AnyObject]? else {
                        if error != nil {
                            print("error // ", error!)
                        }
                        return
                    }
                    let user = User(dictionary: dictionary)
                    guard let name = user.name else {
                        loadedUserNamesGroup.leave()
                        return
                    }
                    self.messages[index].senderName = name

                    loadedUserNamesGroup.leave()
                }
            }
            
        }
    }
    
    func sortedMessages(unsortedMessages: [Message]) -> [Message] {
        let sortedMessages = unsortedMessages.sorted(by: { (message1, message2) -> Bool in
            return message1.timestamp.value! < message2.timestamp.value!
        })
        return sortedMessages
    }

    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 13)]
        return text.boundingRect(with: size, options: options, attributes: attributes, context: nil).integral
    }
    
    func estimateFrameForText(width: CGFloat, text: String, font: UIFont) -> CGRect {
        let size = CGSize(width: width, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
          let attributes = [NSAttributedString.Key.font: font]
        return text.boundingRect(with: size, options: options, attributes: attributes, context: nil).integral
    }

    func preloadCellData(to dictionary: [String: AnyObject]) -> [String: AnyObject] {
        var dictionary = dictionary
        
        if let messageText = dictionary["text"] as? String {
            let rect = RealmCGRect(estimateFrameForText(messageText, orientation: .portrait), id: dictionary["messageUID"] as? String ?? "")
            let lrect = RealmCGRect(estimateFrameForText(messageText, orientation: .landscapeLeft),
                                    id: (dictionary["messageUID"] as? String ?? "") + "landscape")
            dictionary.updateValue(rect as AnyObject, forKey: "estimatedFrameForText")
            dictionary.updateValue(lrect as AnyObject, forKey: "landscapeEstimatedFrameForText")
        }
        
        if let messageTimestamp = dictionary["timestamp"] as? Int64 {  /* pre-converting timeintervals into dates */
            let date = Date(timeIntervalSince1970: TimeInterval(messageTimestamp))
            let convertedTimestamp = timestampOfChatLogMessage(date) as AnyObject
            let shortConvertedTimestamp = date.getShortDateStringFromUTC() as AnyObject

            dictionary.updateValue(convertedTimestamp, forKey: "convertedTimestamp")
            dictionary.updateValue(shortConvertedTimestamp, forKey: "shortConvertedTimestamp")
        }
        return dictionary
    }
    
    func handleMessageInsertionInRuntime(newDictionary : [String: AnyObject]) {
        print("handleMessageInsertionInRuntime")
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let message = Message(dictionary: newDictionary)

        let isOutBoxMessage = message.fromId == currentUserID || message.fromId == message.toId

        self.loadUserNameForOneMessage(message: message) { [unowned self] (_, messageWithName) in
            if !isOutBoxMessage {
                self.collectionDelegate?.collectionView(shouldBeUpdatedWith: messageWithName, reference: self.messageReference)
            } else {
                if let isInformationMessage = message.isInformationMessage.value, isInformationMessage {
                    self.collectionDelegate?.collectionView(shouldBeUpdatedWith: messageWithName,
                                                            reference: self.messageReference)
                } else {
                    print("is outgoing tho")
                    self.collectionDelegate?.collectionView(shouldUpdateOutgoingMessageStatusFrom: self.messageReference,
                                                            message: messageWithName)
                }
            }
        }
    }

    typealias LoadNameCompletionHandler = (_ success: Bool, _ message: Message) -> Void
    func loadUserNameForOneMessage(message: Message, completion: @escaping LoadNameCompletionHandler) {
        guard let senderID = message.fromId else { completion(true, message); return }
        let reference = Firestore.firestore().collection("users").document(senderID)
        reference.getDocument { (documentSnapshot, error) in
            guard let dictionary = documentSnapshot?.data() as [String: AnyObject]? else { return }
            
            if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == senderID }),
               let name = realmUser.localName {
                message.senderName = name
            } else if let realmNonLocalUser = RealmKeychain.realmNonLocalUsersArray().first(where: { $0.id == senderID }),
                      let name = realmNonLocalUser.name {
                message.senderName = name
            } else {
                let user = User(dictionary: dictionary)
                guard let name = user.name else {
                    completion(true, message)
                    return
                }
                message.senderName = name
            }
            completion(true, message)
        }
    }
    
    func estimateFrameForText(_ text: String, orientation: UIDeviceOrientation) -> CGRect {
        let portraitSize = CGSize(width: BaseMessageCell.bubbleViewMaxWidth,
                                  height: BaseMessageCell.bubbleViewMaxHeight)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: portraitSize,
                                                   options: options,
                                                   attributes: [NSAttributedString.Key.font: MessageFontsAppearance.defaultMessageTextFont],
                                                   context: nil).integral
        
//        //we make the height arbitrarily large so we don't undershoot height in calculation
//        let height: CGFloat = 320
//
//        let size = CGSize(width: yourDesiredWidth, height: height)
//        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
//        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(18, weight: UIFontWeightLight)]
//
//        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: attributes, context: nil)
    }
}
