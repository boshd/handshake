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
        
        // format start date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d • h:mm a"
        dateFormatter.timeZone = .current
        if let startTime = channel.startTime.value {
            dateTitle.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(startTime))).uppercased()
        }
        
        if let locationName = channel.locationName {
            subTitle.text = locationName
        } else {
            if let virtual = channel.isVirtual.value, virtual {
                subTitle.text = "Virtual event"
            }
        }
        
        self.channel = channel
        self.channelId = channel.id
        
        if let url = channel.imageUrl {
            channelImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "GroupIcon"), options: [.continueInBackground, .scaleDownLargeImages], completed: { (_, error, _, _) in
                print(error?.localizedDescription ?? "")
            })
        }
        
        guard let channelStatus = channel.updateAndReturnStatus() else { return }
        switch channelStatus {
            case .upcoming:
                
                eventStatus.textColor = .priorityGreen()
                eventStatus.backgroundColor = .greenEventStatusBackground()
                
                let startDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel.startTime.value ?? 0)))
                let calendar = Calendar.current
                let date1 = calendar.startOfDay(for: Date())
                let date2 = calendar.startOfDay(for: startDate)
                let components = calendar.dateComponents([.day], from: date1, to: date2)
                if let days = components.day {
                    if days == 1 {
                        eventStatus.text = "Tomorrow"
                    } else if days == 0 {
                        eventStatus.text = "Today"
                    } else {
                        eventStatus.text = "\(days) days"
                    }
                }
                eventStatus.textColor = .priorityGreen()
                eventStatus.backgroundColor = .greenEventStatusBackground()
            case .inProgress:
                eventStatus.text = "In progress"
                eventStatus.textColor = .priorityGreen()
                eventStatus.backgroundColor = .greenEventStatusBackground()
            case .expired:
                eventStatus.text = "Expired"
                eventStatus.textColor = .priorityRed()
                eventStatus.backgroundColor = .redEventStatusBackground()
            case .cancelled:
                eventStatus.text = "Cancelled"
                eventStatus.textColor = .priorityRed()
                eventStatus.backgroundColor = .redEventStatusBackground()
        }
        
        
        startTimer()
        
        return
    }
}
