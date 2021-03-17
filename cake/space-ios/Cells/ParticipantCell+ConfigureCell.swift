//
//  ParticipantCell+ConfigureCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-10-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

extension ParticipantCell {
    func configureCell(for indexPath: IndexPath, users: [User]) {
        // change
        let placeHolderImage = UIImage(named: "UserpicIcon")
        imageView.image = placeHolderImage
        
        if let url = users[indexPath.row].userThumbnailImageUrl, url != "" {
        imageView.sd_setImage(with: URL(string: url), placeholderImage: placeHolderImage, options:
        [.continueInBackground, .scaleDownLargeImages, .avoidAutoSetImage]) { (image, error, cacheType, url) in
            guard image != nil, cacheType != SDImageCacheType.memory, cacheType != SDImageCacheType.disk else {
                self.imageView.image = image
                return
            }
          
            UIView.transition(with: self.imageView, duration: 0.2, options: .transitionCrossDissolve,
                            animations: { self.imageView.image = image }, completion: nil)
            }
        }

        return
    }
}
