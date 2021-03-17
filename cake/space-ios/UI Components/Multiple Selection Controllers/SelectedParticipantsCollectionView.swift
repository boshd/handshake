//
//  SelectParticipantsCollectionView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import SDWebImage

extension SelectParticipantsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = selectedParticipantsCollectionView.dequeueReusableCell(withReuseIdentifier: selectedParticipantsCollectionViewCellID, for: indexPath) as! SelectedParticipantsCollectionViewCell
        cell.contentView.backgroundColor = .clear
        
        let user = selectedUsers[indexPath.item]
        
        cell.title.text = user.localName

        guard let url = user.userThumbnailImageUrl else { return cell }
        cell.imageView.sd_setImage(with: URL(string: url), placeholderImage:  UIImage(named: "UserpicIcon"), options: [.continueInBackground], completed: { (image, error, cacheType, url) in
            guard image != nil else { return }
            guard cacheType != SDImageCacheType.memory, cacheType != SDImageCacheType.disk else {
                cell.imageView.alpha = 1
                return
            }
            cell.imageView.alpha = 0
            UIView.animate(withDuration: 0.25, animations: { cell.imageView.alpha = 1 })
        })
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return selectSize(indexPath: indexPath)
    }

    func selectSize(indexPath: IndexPath) -> CGSize  {
        let cellHeight: CGFloat = 100
        guard let userName = selectedUsers[indexPath.row].name else { return  CGSize(width: 100, height: cellHeight) }
        return CGSize(width: estimateFrameForText(userName).width, height: cellHeight)
    }

    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)], context: nil).integral
    }
}
