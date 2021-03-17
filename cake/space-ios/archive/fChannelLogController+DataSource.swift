////
////  ChannelLogController+DataSource.swift
////  space-ios
////
////  Created by Kareem Arab on 2019-06-02.
////  Copyright © 2019 Kareem Arab. All rights reserved.
////
//
//import UIKit
//import Firebase
//import Photos
//
//extension ChannelLogController4: UICollectionViewDelegateFlowLayout {
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let message = messages[indexPath.item]
//        
//        let isOutgoingMessage = message.fromId == Auth.auth().currentUser?.uid
//        
//        switch isOutgoingMessage {
//        case true:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: outgoingMessageCellID,
//                                                           for: indexPath) as? OutgoingMessageCell ?? OutgoingMessageCell()
//            cell.channelLogController = self
//            cell.setupData(message: message)
//
//            DispatchQueue.global(qos: .background).async {
//                cell.configureDeliveryStatus(at: indexPath, lastMessageIndex: self.messages.count-1, message: message)
//            }
//            
//            return cell
//        case false:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: incomingMessageCellID,
//                                                           for: indexPath) as? IncomingMessageCell ?? IncomingMessageCell()
//            cell.channelLogController = self
//            cell.setupData(message: message)
//            return cell
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return selectSize(indexPath: indexPath)
//    }
//    
//    func selectSize(indexPath: IndexPath) -> CGSize {
//        
//        guard indexPath.section == 0 else {  return CGSize(width: self.collectionView!.frame.width, height: 40) }
//        var cellHeight: CGFloat = 120
//        let message = messages[indexPath.row]
//        let isOutgoingMessage = message.fromId == Auth.auth().currentUser?.uid
//        let isGroupChat = true
//        
//
//        cellHeight = message.estimatedFrameForText!.height + 20
//        
//        return CGSize(width: self.collectionView!.frame.width, height: cellHeight)
//    }
//    
//}
//
