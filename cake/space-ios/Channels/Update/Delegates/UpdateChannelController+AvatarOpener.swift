//
//  UpdateChannelController+AvatarOpener.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension UpdateChannelController: AvatarOpenerDelegate {
    func avatarOpener(avatarPickerDidPick image: UIImage) {
        guard let indexPath = selectedImageOwningCellIndexPath else { return }
        tableView.cellForRow(at: indexPath)
        let cell = tableView.cellForRow(at: indexPath) as! CreateChannelHeaderCell
        cell.channelImageView.image = image
        cell.channelImagePlaceholderLabel.isHidden = true
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        selectedImage = image
    }
  
    func avatarOpener(didPerformDeletionAction: Bool) {
        guard let indexPath = selectedImageOwningCellIndexPath else { return }
        tableView.cellForRow(at: indexPath)
        let cell = tableView.cellForRow(at: indexPath) as! CreateChannelHeaderCell
        cell.channelImageView.image = nil
        cell.channelImagePlaceholderLabel.isHidden = false
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        self.selectedImage = nil
    }
}
