//
//  ChannelDetailsController+AvatarOpener.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-30.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelDetailsController: AvatarOpenerDelegate {

    func avatarOpener(avatarPickerDidPick image: UIImage) {
        guard let channelID  = channel?.id else { return }

        channelDetailsContainerView.channelImageView.showActivityIndicator()
        channelDetailsDataDatabaseUpdater.deleteCurrentPhoto(with: channelID) { [weak self] (isDeleted) in
            self?.channelDetailsDataDatabaseUpdater.updateChannelDetails(with: channelID, image: image, completion: { [weak self] (isUpdated) in
                self?.channelDetailsContainerView.channelImageView.hideActivityIndicator()
                guard isUpdated else {
                    basicErrorAlertWith(title: basicErrorTitleForAlert, message: thumbnailUploadError, controller: self!)
                    return
                }
                self?.channelDetailsContainerView.channelImageView.image = image
            })
        }
    }

    func avatarOpener(didPerformDeletionAction: Bool) {
        guard let channelID  = channel?.id else { return }
        self.channelImageView?.showActivityIndicator()
        channelDetailsDataDatabaseUpdater.deleteCurrentPhoto(with: channelID) { [weak self] (isDeleted) in
            self?.channelImageView?.hideActivityIndicator()
            guard isDeleted else {
                basicErrorAlertWith(title: basicErrorTitleForAlert, message: deletionErrorMessage, controller: self!)
                return
            }
            self?.channelImageView?.image = nil
        }
    }
}

