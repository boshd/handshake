//
//  ChannelCell+ConfigureCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import RealmSwift
import CoreLocation

enum ChannelState {
    case InProgress
    case Upcoming
    case Past
}

extension ChannelCell {
    func configureCell(for indexPath: IndexPath, channels: Results<Channel>) {
        
        
        
        let channel = channels[indexPath.row]
        print()
        print("CONFIGURING CELL AT INDEX \(indexPath.row) -- txt is: \(channel.lastMessage?.text)")
        print()
        // channel name
        title.text = "\(channel.name ?? "")"
        
        if let messageText = channel.lastMessage?.text, let messageTime = channel.lastMessage?.shortConvertedTimestamp {
            var name = "Someone"
            let message = messageText
            
            if let fromId = channel.lastMessage?.fromId, let currentUserID = Auth.auth().currentUser?.uid {
                
                if fromId == currentUserID {
                    name = "You"
                } else {
                    if let localName = RealmKeychain.realmUsersArray().first(where: { $0.id == fromId })?.localName {
                        name = localName
                    } else if let nonLocalName = RealmKeychain.realmNonLocalUsersArray().first(where: { $0.id == fromId })?.name {
                        name = nonLocalName
                    } else {
                        if let senderName = channel.lastMessage?.senderName {
                            name = senderName
                        }
                    }
                }
            }
            
            let mainText = name + ": " + message
            
            let range = (mainText as NSString).range(of: name)
            let mutableAttributedString = NSMutableAttributedString.init(string: mainText)
            mutableAttributedString.addAttributes([
                NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontBold(with: 12)
            ], range: range)
            messageLabel.attributedText = mutableAttributedString
            
            print("main text \(mainText) \(name) \(range)")
            
//            messageLabel.text = mainText
        }
        
        if let startTime = channel.startTime.value, let endTime = channel.endTime.value {
            dateTitle.text = getDateString(startTime: startTime, endTime: endTime)
            
            if endTime < Int64(Date().timeIntervalSince1970) {
                statusIndicator.backgroundColor = .red
//                channelImageView.borderColor = .red
            } else if startTime > Int64(Date().timeIntervalSince1970) {
                statusIndicator.backgroundColor = .handshakeGreen
//                channelImageView.borderColor = .handshakeGreen
            } else if startTime < Int64(Date().timeIntervalSince1970) && endTime > Int64(Date().timeIntervalSince1970) {
                statusIndicator.backgroundColor = .eventOrange()
//                channelImageView.borderColor = .eventOrange()
            }
        }
        
        if let locationName = channel.locationName {
            subTitle.text = locationName
        } else {
            if let remote = channel.isRemote.value, remote {
                subTitle.text = "Remote"
            }
        }
        
//        self.channel = channel
        self.channelId = channel.id
        
        if let url = channel.thumbnailImageUrl {
            channelImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "handshake"), options: [.continueInBackground, .scaleDownLargeImages], completed: { (_, error, _, _) in
                print(error?.localizedDescription ?? "")
            })
        } else {
            channelImageView.image = UIImage(named: "handshake")
        }
        
        

        let badgeInt = channels[indexPath.row].badge.value ?? 0
        
        print("IN CHANNEL CELL CONFIGURATION \(badgeInt) ... \(channels[indexPath.row].lastMessage?.fromId != Auth.auth().currentUser?.uid)")
        
        guard badgeInt > 0, channels[indexPath.row].lastMessage?.fromId != Auth.auth().currentUser?.uid else {
            updateBadge(0)
            return
        }

        updateBadge(badgeInt)
        
        return
    }
}


