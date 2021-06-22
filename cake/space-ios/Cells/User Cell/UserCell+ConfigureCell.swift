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
        
        if let imageUrl = users[indexPath.row].userThumbnailImageUrl {
            
            imageView?.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "UserpicIcon"))
            
            let itemSize = CGSize.init(width: 50, height: 50)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            imageView?.image!.draw(in: imageRect)
            imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageView?.layer.cornerRadius = (itemSize.width) / 2
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
//            let bounds = self.bounds
//            self.setBounds=bounds
            
        } else {
            imageView?.image = UIImage(named: "UserpicIcon")
            
            let itemSize = CGSize.init(width: 40, height: 40)
            UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
            let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
            imageView?.image!.draw(in: imageRect)
            imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageView?.layer.cornerRadius = (itemSize.width) / 2
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
        }
        
        if admin {
            detailTextLabel?.isHidden = false
            detailTextLabel?.text = "Admin"
        } else {
            detailTextLabel?.isHidden = true
            detailTextLabel?.text = ""
        }
        
        if users[indexPath.row].id == currentUserID {
            textLabel?.text = "You"
        } else {
            print(RealmKeychain.realmUsersArray().map({ $0.id }))
            if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == users[indexPath.row].id }),
               let name = realmUser.localName {
                textLabel?.text = name
            } else {
                let username = users[indexPath.row].name
                let phoneNumber = users[indexPath.row].phoneNumber
                textLabel?.text = "\(phoneNumber ?? "phone")"
                rightLabel.text = "~ \(username ?? "name")"
            }
        }
        
        return
    }
    
}

