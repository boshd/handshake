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

extension ChannelLogController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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
        if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "lol",
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
        return cell
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
                                                                         font: MessageFontsAppearance.defaultInformationMessageTextFont).height + 35
            return CGSize(width: infoMessageWidth, height: infoMessageHeight)
        }

        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    
}
