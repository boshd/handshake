//
//  CreateChannelContoller+AvatarOpenerDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-21.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension CreateChannelController: AvatarOpenerDelegate {
    func avatarOpener(avatarPickerDidPick image: UIImage) {
        guard let indexPath = selectedImageOwningCellIndexPath else { return }
        tableView.cellForRow(at: indexPath)
        let cell = tableView.cellForRow(at: indexPath) as! ChannelNameHeaderCell
        cell.channelImageView.image = image
        cell.channelImagePlaceholderLabel.isHidden = true
        tableView.reloadData()
        selectedImage = image
    }

    func avatarOpener(didPerformDeletionAction: Bool) {
        guard let indexPath = selectedImageOwningCellIndexPath else { return }
        tableView.cellForRow(at: indexPath)
        let cell = tableView.cellForRow(at: indexPath) as! ChannelNameHeaderCell
        cell.channelImageView.image = nil
        cell.channelImagePlaceholderLabel.isHidden = false
        tableView.reloadData()
        self.selectedImage = nil
    }
}
