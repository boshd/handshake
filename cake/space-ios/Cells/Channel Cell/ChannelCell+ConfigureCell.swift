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
        // channel name
        title.text = "\(channel.name ?? "")"
        
//        if let messageText = channel.lastMessage?.text, let messageTime = channel.lastMessage?.shortConvertedTimestamp {
//
//            if let isInfoMessage = channel.lastMessage?.isInformationMessage.value, isInfoMessage {
//                messageLabel.text = messageText
//            } else {
//                var name = "Someone"
//                let message = messageText
//
//                if let fromId = channel.lastMessage?.fromId, let currentUserID = Auth.auth().currentUser?.uid {
//                    if fromId == currentUserID {
//                        name = "You"
//                    } else {
//                        if let localName = RealmKeychain.realmUsersArray().first(where: {$0.id == fromId})?.localName {
//                            name = localName
//                        } else if let name_ = RealmKeychain.realmUsersArray().first(where: {$0.id == fromId})?.name {
//                            name = name_
//                        } else {
//                            print("arrived 2.3 \(channel.lastMessage?.fromId)")
//                            if let senderName = channel.lastMessage?.senderName {
//                                name = senderName
//                            }
//                        }
//                    }
//                }
//                //  \u{200E}
//                let mainText = "\u{200E}💬 " + name + ": " + message + "\u{200C}"
//
//                let range = (mainText as NSString).range(of: name)
//                let mutableAttributedString = NSMutableAttributedString.init(string: mainText)
//                mutableAttributedString.addAttributes([
//                    NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontBold(with: 12)
//                ], range: range)
//                messageLabel.attributedText = mutableAttributedString
//
//            }
//
//
//
////            messageLabel.text = mainText
//        }
        
        if let startTime = channel.startTime.value, let endTime = channel.endTime.value {
            
            
            if endTime < Int64(Date().timeIntervalSince1970) {
                dateTitle.text = "\(getDateString(startTime: startTime, endTime: endTime))"
                statusIndicator.backgroundColor = .red
                dateTitle.textColor = .red
//                channelImageView.borderColor = .red
            } else if startTime > Int64(Date().timeIntervalSince1970) {
                dateTitle.text = "\(getDateString(startTime: startTime, endTime: endTime))"
                statusIndicator.backgroundColor = .handshakeGreen
                dateTitle.textColor = ThemeManager.currentTheme().tintColor
//                channelImageView.borderColor = .handshakeGreen
            } else if startTime < Int64(Date().timeIntervalSince1970) && endTime > Int64(Date().timeIntervalSince1970) {
                statusIndicator.backgroundColor = .handshakeGreen
                dateTitle.text = "Happening now"
                dateTitle.textColor = ThemeManager.currentTheme().tintColor
//                channelImageView.borderColor = .eventOrange()
            }
        }
        
        if let locationName = channel.locationName, let lat = channel.latitude.value, let lon = channel.longitude.value {
            configureSubtitleWithLocation(location: locationName, channelCoordinates: (lat, lon))
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
        
        guard badgeInt > 0, channels[indexPath.row].lastMessage?.fromId != Auth.auth().currentUser?.uid else {
            updateBadge(0)
            return
        }

        updateBadge(badgeInt)
        
        return
    }
    
    fileprivate func configureSubtitleWithLocation(location: String, channelCoordinates: (Double, Double)) {
        
        var distanceString = ""
    
        if let currentRegion = currentRegion {
            let currentLocation = CLLocation(latitude: currentRegion.center.latitude, longitude: currentRegion.center.longitude)
            let distance = currentLocation.distance(from: CLLocation(latitude: channelCoordinates.0, longitude: channelCoordinates.1)) / 1000
            
//            if distance > 1000 {
//                distanceString = " • A very long way form here (\(String(format: "%.0f", distance))km)"
//            } else if distance > 100 && distance <= 1000 {
//                distanceString = " • \(String(format: "%.0f", distance))km"
//            } else if distance <= 100 && distance > 1 {
//                distanceString = " • \(String(format: "%.0f", distance))km"
//            } else {
//                distanceString = " • Just around the corner (\(String(format: "%.0f", distance))km)"
//            }
            
            distanceString = " • \(String(format: "%.0f", distance))km"
        }
        
        
        // Create Attachment
        let imageAttachment = NSTextAttachment()
//        imageAttachment.image = UIImage(named:"gps-arrow")
        // Set bound to reposition
//        let imageOffsetY: CGFloat = -5.0
        imageAttachment.bounds = CGRect(x: 0, y: -1, width: 9, height: 9)
        imageAttachment.image = UIImage(named:"gps-arrow")?.withRenderingMode(.alwaysTemplate)
//        let spacing = NSAttributedString(string: "\u{200B}", attributes:[ NSAttributedString.Key.kern: points])
        // Create string with attachment
        
        
        let padding = NSTextAttachment()
        //Use a height of 0 and width of the padding you want
        padding.bounds = CGRect(x: 0, y: 0, width: 4, height: 0)
                    
//        let attachment = NSTextAttachment(image: image)
        let attachString = NSAttributedString(attachment: imageAttachment)
        
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        completeText.append(NSAttributedString(attachment: padding))
        let textAfterIcon = NSAttributedString(string: location)
        completeText.append(textAfterIcon)
        completeText.append(NSAttributedString(string: distanceString))
//        subTitle.tintColor = .red
//        completeText.addAttribute(.foregroundColor, value: ThemeManager.currentTheme().generalSubtitleColor, range: NSRange(completeText))
        let range = (completeText.mutableString as NSString).range(of: completeText.string)
//        let mutableAttributedString = NSMutableAttributedString.init(string: completeText.string)
        completeText.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeManager.currentTheme().generalSubtitleColor, range: range)
        completeText.addAttribute(NSAttributedString.Key.font, value: ThemeManager.currentTheme().secondaryFont(with: 11), range: range)
        subTitle.textAlignment = .left
        subTitle.attributedText = completeText
    }
    
}


