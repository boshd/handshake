//
//  ChannelLogController+DataSource.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-09.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import Photos
//import ChatLayout

extension ChannelLogController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
//    func shouldPresentHeader(_ chatLayout: ChatLayout, at sectionIndex: Int) -> Bool {
//        return true
//    }
//
//    func shouldPresentFooter(_ chatLayout: ChatLayout, at sectionIndex: Int) -> Bool {
//        return false
//    }
//
//    func sizeForItem(_ chatLayout: ChatLayout, of kind: ItemKind, at indexPath: IndexPath) -> ItemSize {
//        .estimated(selectSize(indexPath: indexPath))
//
//    }
//
//    func alignmentForItem(_ chatLayout: ChatLayout, of kind: ItemKind, at indexPath: IndexPath) -> ChatItemAlignment {
//        let message = groupedMessages[indexPath.section].messages[indexPath.row]
//        let isTextMessage = message.text != nil
//        let isOutgoingMessage = message.fromId == Auth.auth().currentUser?.uid
//        let isInformationMessage = message.isInformationMessage.value ?? false
//
//        if isTextMessage {
//            if isOutgoingMessage {
//                return .trailing
//            } else if isInformationMessage {
//                return .center
//            } else {
//                return .leading
//            }
//        } else {
//            return .center
//        }
//    }
//
    
    
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//        if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "lol",
//        for: indexPath) as? ChannelLogViewControllerSupplementaryView {
//            guard groupedMessages.indices.contains(indexPath.section),
//            groupedMessages[indexPath.section].messages.indices.contains(indexPath.row) else { header.label.text = ""; return header }
//            header.label.text = groupedMessages[indexPath.section].messages[indexPath.row].shortConvertedTimestamp
//            return header
//        }
//        return UICollectionReusableView()
//    }
//    
//    func initialLayoutAttributesForInsertedItem(_ chatLayout: ChatLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: ChatLayoutAttributes, on state: InitialAttributesRequestType) {
//        <#code#>
//    }
//
//    func finalLayoutAttributesForDeletedItem(_ chatLayout: ChatLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: ChatLayoutAttributes) {
//        <#code#>
//    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupedMessages.count + typingIndicatorSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == groupedMessages.count {
            return 1
        } else {
            return groupedMessages[section].messages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: "lol",
                                                                        for: indexPath) as? ChannelLogViewControllerSupplementaryView {
            guard groupedMessages.indices.contains(indexPath.section),
            groupedMessages[indexPath.section].messages.indices.contains(indexPath.row) else { header.label.text = ""; return header }
            header.label.text = groupedMessages[indexPath.section].messages[indexPath.row].shortConvertedTimestamp
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return section == groupedMessages.count ? CGSize(width: collectionView.bounds.width , height: 0) : CGSize(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.section != groupedMessages.count else { return showTypingIndicator(indexPath: indexPath)! as! TypingIndicatorCell }
        return selectCell(for: indexPath, isGroupChat: true)!
    }
    
    fileprivate func showTypingIndicator(indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView.typingIndicatorCellID, for: indexPath) as! TypingIndicatorCell
        cell.restart()

        cell.label.text = getUserShit()
        
        return cell
    }
    
    func getUserShit() -> String {
        
        if typingUserIds.count == 0 {
            if let typingUserId = typingUserIds.first {
                if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == typingUserId }),
                   let name = realmUser.localName {
                    return "\(name) is typing..."
                } else if let nonLocalRealmUser = RealmKeychain.realmNonLocalUsersArray().first(where: { $0.id == typingUserId }),
                          let phone = nonLocalRealmUser.phoneNumber {
                    return "\(phone) is typing..."
                } else {
                    // fetch user once and add to non local realm
                    var retVal = ""
                    UsersFetcher.fetchUser(id: typingUserId) { user, error in
                        guard error == nil else { print(error?.localizedDescription ?? ""); return }
                        // issues w/ initial state
                        if let user = user {
                            retVal = "\(user.phoneNumber) is typing..."
                            autoreleasepool {
                                if !self.nonLocalRealm.isInWriteTransaction {
                                    self.nonLocalRealm.beginWrite()
                                    self.nonLocalRealm.create(User.self, value: user, update: .modified)
                                    try! self.nonLocalRealm.commitWrite()
                                }
                            }
                        }
                    }
                    return retVal
                }
            }
            
        } else if typingUserIds.count > 0 {
            var names = [String]()
            
            for id in typingUserIds {
                
                if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == id }),
                   let name = realmUser.localName {
                    names.append(name)
                } else if let nonLocalRealmUser = RealmKeychain.realmNonLocalUsersArray().first(where: { $0.id == id }),
                          let phone = nonLocalRealmUser.phoneNumber {
                    names.append(phone)
                } else {
                    // fetch user once and add to non local realm
//                    var retVal = ""
                    UsersFetcher.fetchUser(id: id) { user, error in
                        guard error == nil else { print(error?.localizedDescription ?? ""); return }
                        // issues w/ initial state
                        if let user = user {
                            names.append(user.phoneNumber ?? "")
                            autoreleasepool {
                                if !self.nonLocalRealm.isInWriteTransaction {
                                    self.nonLocalRealm.beginWrite()
                                    self.nonLocalRealm.create(User.self, value: user, update: .modified)
                                    try! self.nonLocalRealm.commitWrite()
                                }
                            }
                        }
                    }
                    
                }
                
                var printableNameList: String?
                for name in names {
                    if printableNameList == nil {
                        printableNameList = name
                    } else {
                        printableNameList! += ", " + name
                    }
                }
                
                return "\(printableNameList ?? "") are typing.."
                
            }
            
            
        }
        
        return "koko"
//        if typingUserIds.count > 0 {
//            if typingUserIds.count == 1 {
//
//            } else {
//
//            }
//        }
        
//        if RealmKeychain.realmUsersArray().map({$0.id}).contains(user.id) {
//            if let localRealmUser = RealmKeychain.usersRealm.object(ofType: User.self, forPrimaryKey: user.id),
//               !user.isEqual_(to: localRealmUser) {
//
//                // update local realm user copy
//                if !(self.localRealm.isInWriteTransaction) {
//                    self.localRealm.beginWrite()
//                    localRealmUser.email = user.email
//                    localRealmUser.name = user.name
//                    localRealmUser.localName = user.localName
//                    localRealmUser.phoneNumber = user.phoneNumber
//                    localRealmUser.userImageUrl = user.userImageUrl
//                    localRealmUser.userThumbnailImageUrl = user.userThumbnailImageUrl
//                    try! self.localRealm.commitWrite()
//                }
//
//                // update array
//                if let index = self.attendees.firstIndex(where: { user_ in
//                    return user_.id == user.id
//                }) {
//                    self.attendees[index] = user
//                }
//            }
//        } else if RealmKeychain.realmNonLocalUsersArray().map({$0.id}).contains(user.id) {
//            if let nonLocalRealmUser = RealmKeychain.nonLocalUsersRealm.object(ofType: User.self, forPrimaryKey: user.id),
//               !user.isEqual_(to: nonLocalRealmUser) {
//
//                // update local realm user copy
//                if !(self.nonLocalRealm.isInWriteTransaction) {
//                    self.nonLocalRealm.beginWrite()
//                    nonLocalRealmUser.email = user.email
//                    nonLocalRealmUser.name = user.name
//                    nonLocalRealmUser.localName = user.localName
//                    nonLocalRealmUser.phoneNumber = user.phoneNumber
//                    nonLocalRealmUser.userImageUrl = user.userImageUrl
//                    nonLocalRealmUser.userThumbnailImageUrl = user.userThumbnailImageUrl
//                    try! self.nonLocalRealm.commitWrite()
//                }
//
//                // update array
//                if let index = self.attendees.firstIndex(where: { user_ in
//                    return user_.id == user.id
//                }) {
//                    self.attendees[index] = user
//                }
//            }
//        } else {
//            autoreleasepool {
//                if !self.nonLocalRealm.isInWriteTransaction {
//                    self.nonLocalRealm.beginWrite()
//                    self.nonLocalRealm.create(User.self, value: user, update: .modified)
//                    try! self.nonLocalRealm.commitWrite()
//                }
//            }
//            self.attendees.append(user)
//        }
    }
    
    fileprivate func selectCell(for indexPath: IndexPath, isGroupChat: Bool) -> UICollectionViewCell? {
        
        let message = groupedMessages[indexPath.section].messages[indexPath.row]
        let isTextMessage = message.text != nil
        let isOutgoingMessage = message.fromId == Auth.auth().currentUser?.uid
        let isInformationMessage = message.isInformationMessage.value ?? false

        if isInformationMessage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView.informationMessageCellID, for: indexPath) as! InformationMessageCell
            cell.setupData(message: message)
            return cell
        } else if isTextMessage {
            switch isOutgoingMessage {
                case true:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView.outgoingMessageCellID, for: indexPath) as! OutgoingMessageCell
                    cell.channelLogController = self
                    cell.setupData(message: message)
                    cell.configureDeliveryStatus(at: indexPath, groupMessages: self.groupedMessages, message: message)
                    cell.contentView.isUserInteractionEnabled = true
                    return cell
                case false:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView.incomingMessageCellID, for: indexPath) as! IncomingMessageCell
                    cell.channelLogController = self
                    cell.setupData(message: message)
                    cell.contentView.isUserInteractionEnabled = true
        
                    return cell
            }
        }
        return nil
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//////        let totalCellWidth = CellWidth * CellCount
//////        let totalSpacingWidth = CellSpacing * (CellCount - 1)
//////
//////        let leftInset = (collectionViewWidth - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//////        let rightInset = leftInset
//
//
//
//        return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return selectSize(indexPath: indexPath)
    }

    func selectSize(indexPath: IndexPath) -> CGSize {
        
        guard indexPath.section != groupedMessages.count else { return CGSize(width: collectionView.frame.width, height: 15) }
        let cellHeight: CGFloat = 80
        let message = groupedMessages[indexPath.section].messages[indexPath.item]
        let isInformationMessage = message.isInformationMessage.value ?? false
        let isTextMessage = message.text != nil && !isInformationMessage
        let isOutgoingMessage = message.fromId == Auth.auth().currentUser?.uid

        guard !isTextMessage else {
            guard let estimate = message.estimatedFrameForText?.width.value else { return CGSize(width: collectionView.frame.width, height: 15) }
            
//            var width: CGFloat = CGFloat(estimate) + BaseMessageCell.outgoingMessageHorisontalInsets
//            if (CGFloat(estimate) + BaseMessageCell.messageTimeWidth <=  BaseMessageCell.bubbleViewMaxWidth) ||
//                CGFloat(estimate) <= BaseMessageCell.messageTimeWidth {
//                width = width + BaseMessageCell.messageTimeWidth - 5
//            }
 
            return CGSize(width: collectionView.frame.width,
                          height: collectionView.setupCellHeight(isOutgoingMessage: isOutgoingMessage,
                                                                 frame: message.estimatedFrameForText,
                                                                 indexPath: indexPath))
        }

        guard !isInformationMessage else {
            guard let messagesFetcher = messagesFetcher else { return CGSize(width: 0, height: 0) }
            let infoMessageWidth = collectionView.frame.width
            guard let messageText = message.text else { return CGSize(width: 0, height: 0 ) }

            let infoMessageHeight = messagesFetcher.estimateFrameForText(width: infoMessageWidth,
                                                                         text: messageText,
                                                                         font: MessageFontsAppearance.defaultInformationMessageTextFont).height + 25
            return CGSize(width: infoMessageWidth, height: infoMessageHeight)
        }

        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    
}
