////
////  CreateChannelController+HeaderCell.swift
////  space-ios
////
////  Created by Kareem Arab on 2020-11-01.
////  Copyright © 2020 Kareem Arab. All rights reserved.
////
//
//import UIKit
//
//extension CreateChannelController: CreateChannelHeaderCellDelegate {
//    func createChannelHeaderCell(_ cell: CreateChannelHeaderCell, didTapImageView: Bool) {
//        avatarOpener.delegate = self
//        selectedImageOwningCellIndexPath = tableView.indexPath(for: cell)
//        avatarOpener.handleAvatarOpening(avatarView: cell.channelImageView, at: self, isEditButtonEnabled: true, title: .user)
//    }
//    
//    func createChannelHeaderCell(_ cell: CreateChannelHeaderCell, updatedChannelName: String) {
//        channelName = updatedChannelName
//        DispatchQueue.main.async {
//            self.tableView.beginUpdates()
//            self.tableView.endUpdates()
//        }
//    }
//}
