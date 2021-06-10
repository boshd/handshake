//
//  CreateChannelController+ChannelNameHeaderDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-15.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation

extension CreateChannelController: ChannelNameHeaderCellDelegate {
    func channelNameHeaderCell(_ cell: ChannelNameHeaderCell, didTapImageView: Bool) {
        if didTapImageView {
            avatarOpener.delegate = self
            selectedImageOwningCellIndexPath = tableView.indexPath(for: cell)
            avatarOpener.handleAvatarOpening(avatarView: cell.channelImageView, at: self, isEditButtonEnabled: true, title: .user)
        }
    }
    
    func channelNameHeaderCell(_ cell: ChannelNameHeaderCell, updatedChannelName: String) {
        channelName = updatedChannelName
        newChannel?.name = updatedChannelName
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}
