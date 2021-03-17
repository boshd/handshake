//
//  PhotoController+AvatarOpenerDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-08.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension PhotoController: AvatarOpenerDelegate {
    func avatarOpener(avatarPickerDidPick image: UIImage) {
        photoContainerView.imageView.showActivityIndicator()
        userProfileDataDatabaseUpdater.updateUserProfile(with: image) { (isUpdated) in
            self.photoContainerView.imageView.hideActivityIndicator()
            guard isUpdated else {
                basicErrorAlertWith(title: basicErrorTitleForAlert, message: thumbnailUploadError, controller: self)
                return
            }
            self.photoContainerView.imageView.image = image
            self.selectedImage = image
        }
    }
  
    func avatarOpener(didPerformDeletionAction: Bool) {
        self.selectedImage = nil
        self.photoContainerView.imageView.image = nil
    }
}
