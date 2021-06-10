////
////  UpdateChannelController+HeaderCell.swift
////  space-ios
////
////  Created by Kareem Arab on 2021-01-22.
////  Copyright © 2021 Kareem Arab. All rights reserved.
////
//
//import UIKit
//
//extension UpdateChannelController: CreateChannelHeaderCellDelegate {
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
