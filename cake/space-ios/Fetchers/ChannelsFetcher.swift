//
//  ChannelFetcher.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-15.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SDWebImage
import RealmSwift
  
protocol ChannelUpdatesDelegate: class {
    func channels(didStartFetching: Bool)
    func channels(didStartUpdatingData: Bool)
    func channels(didFinishFetching: Bool, channels: [Channel])
    func channels(update channel: Channel, reloadNeeded: Bool)
    func channels(didRemove: Bool, channelID: String)
    func channels(addedNewChannel: Bool, channelID: String)
}

class ChannelsFetcher: NSObject {
    
    weak var delegate: ChannelUpdatesDelegate?
    
    fileprivate var group: DispatchGroup?
    var groupIndex = 0
    fileprivate var isGroupAlreadyFinished: Bool!
    fileprivate var channels = [Channel]()
    
    fileprivate var userReference: DocumentReference!
    fileprivate var groupChannelReference: DocumentReference!
    fileprivate var currentUserChannelIDsReference: CollectionReference!
    fileprivate var channelReference: DocumentReference!

    fileprivate var loadChannelListener: ListenerRegistration!
    
    fileprivate var userChannelIdsCollectionListener: ListenerRegistration?
    
    fileprivate var individualChannelListenersDict: [String:ListenerRegistration] = [String:ListenerRegistration]()
    
    var listenerCount = 0
    var indListenerCount = 0
    
    func cleanFetcherChannels() {
        channels.removeAll()
    }
    
    @objc public func removeAllObservers() {
        channels.removeAll()
        isGroupAlreadyFinished = false
        group = nil
        if userChannelIdsCollectionListener != nil { userChannelIdsCollectionListener?.remove() }
        
        if !individualChannelListenersDict.isEmpty {
            for (_, listener) in individualChannelListenersDict {
                listener.remove()
            }
        }
    }
    
    func fetchChannels() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        delegate?.channels(didStartFetching: true)
        self.isGroupAlreadyFinished = false
        currentUserChannelIDsReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds")
        
        observeChannelAddedOrRemoved()
        DispatchQueue.global(qos: .default).async {
            self.currentUserChannelIDsReference.getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    if error != nil {
                        print("error // ", error?.localizedDescription ?? "")
                    }
                    self.delegate?.channels(didFinishFetching: true, channels: self.channels)
                    return
                }
                self.group = DispatchGroup()
                print("FOUND \(documents.count) docs")
                for _ in 0 ..< documents.count { self.group?.enter() }
                self.group?.notify(queue: .main, execute: { [weak self] in
                    //guard let unwrappedSelf = self else { return }
                    if let delegate = self?.delegate {
                        self?.isGroupAlreadyFinished = true
                        delegate.channels(didFinishFetching: true, channels: self!.channels)
                    }else{
                       print("The delegate is nil")
                     }
                })
            }
        }
    }
    
    func observeChannelAddedOrRemoved() {
        var first = false
        if currentUserChannelIDsReference != nil {
//            if userChannelIdsCollectionListener == nil {
                listenerCount += 1
                userChannelIdsCollectionListener = currentUserChannelIDsReference.addSnapshotListener({ [weak self] (snapshot, error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                        return
                    }

                    if first {
                        first = false
                        return
                    }
                    guard let snap = snapshot else { return }
                    print("snap is here")
                    snap.documentChanges.forEach { (diff) in
                        if (diff.type == .added) {
                            print("snap is added")
                            let channelID = diff.document.documentID
                            self?.listenToChannel(with: channelID)
                            self?.delegate?.channels(addedNewChannel: true, channelID: channelID)
                            self?.loadConversation(for: channelID)
                        } else if (diff.type == .removed) {
                            print("snap is removed")
                            let channelID = diff.document.documentID
//                            let obj: [String: Any] = ["channelID": channelID]
//                            NotificationCenter.default.post(name: .channelRemoved, object: obj)
//                            if let channel = RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: channelID),
//                               !channel.isInvalidated {
//                                print("you were removed")
                                let obj: [String: Any] = ["channelID": channelID]
                                NotificationCenter.default.post(name: .channelRemoved, object: obj)
//                            } else {
//                                print("you left")
//                            }
                            
                            if self?.individualChannelListenersDict.count != 0 {
                                self?.individualChannelListenersDict[channelID]?.remove()
                                
                                if let index = self?.individualChannelListenersDict.firstIndex(where: { (k, v) -> Bool in
                                    return k == channelID
                                }) {
                                    self?.individualChannelListenersDict.remove(at: index)
                                }
                            }
                            self?.delegate?.channels(didRemove: true, channelID: channelID)
                        } else {
                            print("snap is else")
                        }
                    }
                })
//            }
        }
    }

    fileprivate func loadConversation(for channelID: String?) {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channelID
        else { return }
        
        //let groupChannelDataReference = Firestore.firestore().collection("channels").document(channelID)
        let groupChannelDataReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID)
        groupChannelDataReference.getDocument { (documentSnapshot, error) in
            guard let data = documentSnapshot?.data() else {
                if error != nil {
                    print("error // ", error!)
                }
                self.delegate?.channels(didFinishFetching: true, channels: self.channels)
                return
            }
            print("ariveee")
            print(data)
            let channel = Channel(dictionary: data as [String : AnyObject])
            guard let lastMessageID = channel.lastMessageId else {
                self.loadAdditionalMetadata(for: channel)
                return
            }
            self.loadLastMessage(for: lastMessageID, channel: channel)
            
        }
    }
    
    fileprivate func loadLastMessage(for messageID: String, channel: Channel) {
//        guard let channelID = channel.id else { return }
        
//        Firestore.firestore().collection("channels").document(channelID).collection("thread").document(messageID).getDocument { (snapshot, error) in
        Firestore.firestore().collection("messages").document(messageID).getDocument { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            print(" 1 loadLastMessage")
            guard var dictionary = snapshot?.data() as [String: AnyObject]? else { return }
            print(" 2 loadLastMessage")
            dictionary.updateValue(messageID as AnyObject, forKey: "messageUID")
            dictionary = self.messagesFetcher.preloadCellData(to: dictionary)
            let message = Message(dictionary: dictionary)
            channel.lastMessageTimestamp.value = message.timestamp.value
            message.channel = channel
            channel.lastMessageRuntime = message
            print(" last loadLastMessage")
            self.loadAdditionalMetadata(for: channel)
        }
    }
    
    fileprivate func loadAdditionalMetadata(for channel: Channel) {
        print("begin of additional")
        guard let channelID = channel.id, let _ = Auth.auth().currentUser?.uid else { return }
        print("in additional")
        Firestore.firestore().collection("channels").document(channelID).getDocument { (snapshot, error) in
            if error != nil {
                print(error as Any)
                return
            }
            print("in get doc")
            guard var dictionary = snapshot?.data() as [String: AnyObject]? else { return }
            dictionary.updateValue(channelID as AnyObject, forKey: "id")

            if let membersIDs = dictionary["participantIds"] as? [String:AnyObject] {
                dictionary.updateValue(Array(membersIDs.values) as AnyObject, forKey: "participantIds")
            }

            let metaInfo = Channel(dictionary: dictionary)
            channel.name = metaInfo.name
            channel.imageUrl = metaInfo.imageUrl
            channel.thumbnailImageUrl = metaInfo.thumbnailImageUrl
            channel.participantIds.assign(metaInfo.participantIds)
            channel.admins = metaInfo.admins
            channel.author = metaInfo.author
            channel.id = metaInfo.id
            channel.goingIds = metaInfo.goingIds
            channel.maybeIds = metaInfo.maybeIds
            channel.notGoingIds = metaInfo.notGoingIds
            channel.locationName = metaInfo.locationName
            channel.latitude = metaInfo.latitude
            channel.longitude = metaInfo.longitude
            channel.isVirtual = metaInfo.isVirtual
            channel.isCancelled = metaInfo.isCancelled
            channel.startTime = metaInfo.startTime
            channel.endTime = metaInfo.endTime
            channel.fcmTokens = metaInfo.fcmTokens
            if let fcmTokensDict = dictionary["fcmTokens"] as? [String:String] {
                channel.fcmTokens = convertRawFCMTokensToRealmCompatibleType(fcmTokensDict)
            }
            
            prefetchThumbnail(from: channel.thumbnailImageUrl == nil ? channel.imageUrl : channel.thumbnailImageUrl)
            self.updateConversationArrays(with: channel)
        }
    }
    
    fileprivate let messagesFetcher = MessagesFetcher()
    
    fileprivate func prefetchImage(from urlString: String?) {
        if let thumbnail = urlString, let url = URL(string: thumbnail) {
            SDWebImagePrefetcher.shared.prefetchURLs([url])
        }
    }
    
    fileprivate func updateConversationArrays(with channel: Channel) {
        guard let channelID = channel.id else { return }
        if let index = channels.firstIndex(where: { (channel) -> Bool in
            return channel.id == channelID
        }) {
            update(channel: channel, at: index)
        } else {
            channels.append(channel)
            handleGroupOrReloadTable()
        }
    }
    
    func update(channel: Channel, at index: Int) {
        guard isGroupAlreadyFinished, (channels[index].isMuted.value != channel.isMuted.value) else {
            // everything ok..?
            if isGroupAlreadyFinished {
                channels[index] = channel
                delegate?.channels(update: channels[index], reloadNeeded: false)
                return
            }
            channels[index] = channel
            handleGroupOrReloadTable()
            return
        }
        channels[index] = channel
        delegate?.channels(update: channels[index], reloadNeeded: true)
    }
    
    fileprivate func handleGroupOrReloadTable() {
        guard isGroupAlreadyFinished else {
            guard group != nil else {
                delegate?.channels(didFinishFetching: true, channels: channels)
                return
            }
            group?.leave()
            return
        }
        delegate?.channels(didFinishFetching: true, channels: channels)
    }
    
    // MARK:- INDIVIDUAL CHANNEL LISENER
    
    fileprivate func listenToChannel(with channelID: String) {
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        
        let listener = channelReference.addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            guard let data = snapshot?.data() as [String:AnyObject]? else { return }
            
            let updatedChannel = Channel(dictionary: data)
            guard let updatedChannelID = updatedChannel.id
                  // let currentUserID = Auth.auth().currentUser?.uid
            else { return }
            
            guard let index = self.channels.firstIndex(where: { (channel) -> Bool in
                return channel.id == updatedChannelID
            }) else { return }
            
            self.channels[index] = updatedChannel
            self.delegate?.channels(update: self.channels[index], reloadNeeded: true)
        }
        
        individualChannelListenersDict[channelID] = listener
    }
    
}

func convertRawFCMTokensToRealmCompatibleType(_ fcmTokensDict: [String:String]) -> List<FCMToken> {
    let fcmList = List<FCMToken>()
    
    for (userId, token) in fcmTokensDict {
        let fcmTokenObject = FCMToken()
        fcmTokenObject.userId = userId
        fcmTokenObject.fcmToken = token
        fcmList.append(fcmTokenObject)
    }
    
    return fcmList
}
