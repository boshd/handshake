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
import MapKit
  
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
    
    fileprivate var group: DispatchGroup!
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
        if userChannelIdsCollectionListener != nil { userChannelIdsCollectionListener?.remove(); userChannelIdsCollectionListener = nil }
        
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
                for _ in 0 ..< documents.count { print("we are entering"); self.group.enter() }
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
        if currentUserChannelIDsReference != nil {
//            var first = true
            userChannelIdsCollectionListener = currentUserChannelIDsReference.addSnapshotListener({ [weak self] (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
//                if first {
//                    first = false
//                    return
//                }
                
                guard let snap = snapshot else { return }
                snap.documentChanges.forEach { (diff) in
                    if (diff.type == .added) {
                        print("channel added")
                        let channelID = diff.document.documentID
                        self?.delegate?.channels(addedNewChannel: true, channelID: channelID)
                        self?.loadConversation(for: channelID)
                    } else if (diff.type == .removed) {
                        print("channel removed")
//                        let obj: [String: Any] = ["channelID": channelID]
//                        NotificationCenter.default.post(name: .channelRemoved, object: obj)
                        print("pre", self?.individualChannelListenersDict.count)
                        if self?.individualChannelListenersDict.count != 0 {
                            self?.individualChannelListenersDict[diff.document.documentID]?.remove()
                            if let index = self?.individualChannelListenersDict.firstIndex(where: { (channelID, _) -> Bool in
                                return channelID == diff.document.documentID
                            }) {
                                self?.individualChannelListenersDict.remove(at: index)
                            }
                        }
                        print("post", self?.individualChannelListenersDict.count)
                        
                        self?.delegate?.channels(didRemove: true, channelID: diff.document.documentID)
                    } else if (diff.type == .modified) {
                        // CHANNEL MODIFIED
//                        print("CHANNEL HAS BEEN MODIIFIED!!")
//                        var dictionary = diff.document.data() as [String: AnyObject]
//                        dictionary.updateValue(diff.document.documentID as AnyObject, forKey: "id")
//
//                        if let isGroupAlreadyFinished = self?.isGroupAlreadyFinished, isGroupAlreadyFinished {
//                            self?.delegate?.channels(didStartUpdatingData: true)
//                        }
//
//                        let channel = Channel(dictionary: dictionary)
//                        channel.isTyping.value = channel.getTyping()
//                        guard let lastMessageID = channel.lastMessageId else {
//                            self?.loadAdditionalMetadata(for: channel)
//                            return
//                        }
//                        self?.loadLastMessage(for: lastMessageID, channel: channel)
                    }
                }
            })
        }
    }

    fileprivate func loadConversation(for channelID: String?) {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channelID
        else { return }
        
        let groupChannelDataReference = Firestore.firestore().collection("channels").document(channelID)
        groupChannelDataReference.getDocument { (documentSnapshot, error) in
            guard let data = documentSnapshot?.data() else {
                if error != nil {
                    print("error // ", error!)
                }
                self.delegate?.channels(didFinishFetching: true, channels: self.channels)
                return
            }
            print("loadConversation")
            let channel = Channel(dictionary: data as [String : AnyObject])
            
            
            channel.isTyping.value = channel.getTyping()
            
            guard let lastMessageID = channel.lastMessageId else {
                self.loadAdditionalMetadata(for: channel)
                print("loadAdditionalMetadata route")
                return
            }
            print("loadLastMessage route")
            self.loadLastMessage(for: lastMessageID, channel: channel)
        }
    }
    
    fileprivate func loadLastMessage(for messageID: String, channel: Channel) {
        Firestore.firestore().collection("messages").document(messageID).getDocument { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            print("loadLastMessage")
            guard var dictionary = snapshot?.data() as [String: AnyObject]? else { return }
            dictionary.updateValue(messageID as AnyObject, forKey: "messageUID")
            
            dictionary = self.messagesFetcher.preloadCellData(to: dictionary)
            let message = Message(dictionary: dictionary)
            channel.lastMessageTimestamp.value = message.timestamp.value
            message.channel = channel
            channel.lastMessageRuntime = message
            self.loadAdditionalMetadata(for: channel)
        }
    }
    
    fileprivate func loadAdditionalMetadata(for channel: Channel) {
        print(channel.id, channel.name, channel.admins)
        guard let channelID = channel.id, let _ = Auth.auth().currentUser?.uid else { return }
        print("arrived in load additional metadata")
        let tempListener = Firestore.firestore().collection("channels").document(channelID).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error as Any)
                return
            }
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
            channel.isRemote = metaInfo.isRemote
            channel.startTime = metaInfo.startTime
            channel.endTime = metaInfo.endTime
            channel.fcmTokens = metaInfo.fcmTokens
            channel.description_ = metaInfo.description_
            
            channel.locationName = metaInfo.locationName
            channel.latitude = metaInfo.latitude
            channel.longitude = metaInfo.longitude
            
            let location = Location()
            location.name = metaInfo.locationName ?? ""
            location.locationDescription = metaInfo.locationDescription ?? ""
            location.latitude = metaInfo.latitude.value ?? 0.0
            location.longitude = metaInfo.longitude.value ?? 0.0
            channel.location = location
            
            if let fcmTokensDict = dictionary["fcmTokens"] as? [String:String] {
                channel.fcmTokens = convertRawFCMTokensToRealmCompatibleType(fcmTokensDict)
            }
            prefetchThumbnail(from: channel.thumbnailImageUrl == nil ? channel.imageUrl : channel.thumbnailImageUrl)
            self.updateConversationArrays(with: channel)
        }
        individualChannelListenersDict[channelID] = tempListener
    }
    
    fileprivate let messagesFetcher = MessagesFetcher()
    
    fileprivate func prefetchImage(from urlString: String?) {
        if let thumbnail = urlString, let url = URL(string: thumbnail) {
            SDWebImagePrefetcher.shared.prefetchURLs([url])
        }
    }
    
    fileprivate func updateConversationArrays(with channel: Channel) {
        guard let channelID = channel.id else { return }
        print("updateConversationArrays")
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
        print("update")
        if channel.isTyping.value == nil {
            let isTyping = channels[index].isTyping.value
            channel.isTyping.value = isTyping
        }
        if isGroupAlreadyFinished {
            channels[index] = channel
            delegate?.channels(update: channels[index], reloadNeeded: true)
            return
        }
        channels[index] = channel
        handleGroupOrReloadTable()
        return
    }
    
    fileprivate func handleGroupOrReloadTable() {
        print("handleGroupOrReloadTable")
        guard isGroupAlreadyFinished else {
            guard group != nil else {
                delegate?.channels(didFinishFetching: true, channels: channels)
                return
            }
            group.leave()
            return
        }
        delegate?.channels(didFinishFetching: true, channels: channels)
    }
    
    // MARK:- INDIVIDUAL CHANNEL LISENER
    
//    fileprivate func listenToChannel(with channelID: String) {
//        let channelReference = Firestore.firestore().collection("channels").document(channelID)
//        let listener = channelReference.addSnapshotListener { (snapshot, error) in
//            // listening to ACTUAL channel
//            if error != nil {
//                print(error?.localizedDescription ?? "error")
//                return
//            }
//
//            print("BTW WE GOT A CHANNEL UPDATE JS")
//
//            guard let data = snapshot?.data() as [String:AnyObject]? else { return }
//
//            let updatedChannel = Channel(dictionary: data)
//            guard let updatedChannelID = updatedChannel.id else { return }
//
//            guard let index = self.channels.firstIndex(where: { (channel) -> Bool in
//                return channel.id == updatedChannelID
//            }) else { return }
//
//            self.channels[index] = updatedChannel
//            self.delegate?.channels(update: self.channels[index], reloadNeeded: true)
//        }
//
//        individualChannelListenersDict[channelID] = listener
//    }
    
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
