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
        
        if let startTime = channel.startTime.value, let endTime = channel.endTime.value {
            dateTitle.text = getDateString(startTime: startTime, endTime: endTime)
        }
        
        if let locationName = channel.locationName {
            subTitle.text = locationName
        } else {
            if let remote = channel.isRemote.value, remote {
                subTitle.text = "Remote"
            }
        }
        
        self.channel = channel
        self.channelId = channel.id
        
        if let url = channel.thumbnailImageUrl {
            channelImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "GroupIcon"), options: [.continueInBackground, .scaleDownLargeImages], completed: { (_, error, _, _) in
                print(error?.localizedDescription ?? "")
            })
        } else {
            channelImageView.image = UIImage(named: "GroupIcon")
        }

        let badgeInt = channels[indexPath.row].badge.value ?? 0
        
        guard badgeInt > 0, channels[indexPath.row].lastMessage?.fromId != Auth.auth().currentUser?.uid else {
            updateBadge(0)
            return
        }

        updateBadge(badgeInt)
        
        return
    }
}


