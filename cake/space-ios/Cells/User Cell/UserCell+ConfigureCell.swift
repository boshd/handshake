//
//  UserCell+ConfigureCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-03.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

extension UserCell {
    func configureCell(for indexPath: IndexPath, users: [User], admin: Bool) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        if admin {
            detailTextLabel?.isHidden = false
            detailTextLabel?.text = "Organizer"
        } else {
            detailTextLabel?.isHidden = true
            detailTextLabel?.text = ""
        }
        
        if users[indexPath.row].id == currentUserID {
            textLabel?.text = "You"
        } else {
            
            if let name = RealmKeychain.realmUsersArray().first(where: {$0.id == users[indexPath.row].id})?.localName {
                textLabel?.text = name
            } else if let name = RealmKeychain.realmUsersArray().first(where: {$0.id == users[indexPath.row].id})?.name {
                textLabel?.text = name
            } else if let name = RealmKeychain.realmNonLocalUsersArray().first(where: {$0.id == users[indexPath.row].id})?.localName {
                textLabel?.text = name
            } else if let name = RealmKeychain.realmNonLocalUsersArray().first(where: {$0.id == users[indexPath.row].id})?.name {
                textLabel?.text = name
            } else {
                let username = users[indexPath.row].name
                let phoneNumber = users[indexPath.row].phoneNumber
                textLabel?.text = "\(phoneNumber ?? "phone")"
                rightLabel.text = "~ \(username ?? "name")"
            }
            
//            if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == users[indexPath.row].id }),
//               let name = realmUser.localName {
//                textLabel?.text = name
//            } else {
//                let username = users[indexPath.row].name
//                let phoneNumber = users[indexPath.row].phoneNumber
//                textLabel?.text = "\(phoneNumber ?? "phone")"
//                rightLabel.text = "~ \(username ?? "name")"
//            }
        }
        
//        if let imageUrl = users[indexPath.row].userThumbnailImageUrl {
//
//            DispatchQueue.global(qos: .background).async { [weak self] in
//                self?.imageView?.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "UserpicIcon"))
//                let itemSize = CGSize.init(width: 40, height: 40)
//                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
//                let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
//                self?.imageView?.image!.draw(in: imageRect)
//                self?.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
//                UIGraphicsEndImageContext()
//                self?.imageView?.layer.cornerRadius = (itemSize.width) / 2
//                self?.imageView?.contentMode = .scaleAspectFit
//                self?.imageView?.clipsToBounds = true
//            }
//
//        } else {
//            imageView?.image = UIImage(named: "UserpicIcon")
//            let itemSize = CGSize.init(width: 40, height: 40)
//            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
//            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
//            imageView?.image!.draw(in: imageRect)
//            imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
//            UIGraphicsEndImageContext()
//            imageView?.layer.cornerRadius = (itemSize.width) / 2
//            imageView?.contentMode = .scaleAspectFill
//            imageView?.clipsToBounds = true
//        }
        
        guard let url = users[indexPath.row].userThumbnailImageUrl else { return }
        
//        imageView?.image = UIImage(named: "UserpicIcon")
        

        imageView?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "UserpicIcon"), options: [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage], completed: { [weak self] (image, _, cacheType, _) in
            guard image != nil else { return }
            
            
            
            guard cacheType != SDImageCacheType.memory, cacheType != SDImageCacheType.disk else {
                self?.imageView?.image = image
                return
            }

            UIView.transition(with: self?.imageView ?? UIImageView(image: UIImage(named: "UserpicIcon")),
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: { self?.imageView?.image = image },
                              completion: nil)
            

        })
        
        let itemSize = CGSize.init(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        self.imageView?.image!.draw(in: imageRect)
        self.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.imageView?.layer.cornerRadius = itemSize.width / 2
        self.imageView?.contentMode = .scaleAspectFit
        self.imageView?.clipsToBounds = true
        
        return
    }
    
}

