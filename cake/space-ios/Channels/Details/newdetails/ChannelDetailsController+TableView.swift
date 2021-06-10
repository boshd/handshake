//
//  ChannelDetailsController+TableView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

/*
 sections:
     header: image?
     1. channel name
     2. date and time
     3. about
     4. attendees
     5. location
     footer: foot note
 */

extension ChannelDetailsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Date & time"
        } else if section == 2 {
            return "About"
        } else if section == 3 {
            return "\(channel?.participantIds.count ?? 0) Attendees"
        } else if section == 4 {
            return "How to get there"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        } else if section == 3 {
            
            if allAttendeesLoaded || !initialAttendeesLoaded {
                return attendees.count
            } else {
                return attendees.count + 1
            }
            
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: channelNameCellId, for: indexPath) as? ChannelNameCell ?? ChannelNameCell()
            guard let channelName = channel?.name else { return cell }
            cell.textLabel?.text = channelName
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: channelDetailsCellId, for: indexPath) as? ChannelDetailsCell ?? ChannelDetailsCell()
            if indexPath.row == 0 {
                cell.textLabel?.text = "start??"
                return cell
            } else {
                cell.textLabel?.text = "end??"
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: channelDescriptionCellId, for: indexPath) as? ChannelDescriptionCell ?? ChannelDescriptionCell()
            return cell
        } else if indexPath.section == 3 {
            if indexPath.row == attendees.count && !allAttendeesLoaded {
                let cell = LoadMoreCell(style: .subtitle, reuseIdentifier: loadMoreCellId)
                return cell
            } else {
                let cell = UserCell(style: .value2, reuseIdentifier: userCellId)
                cell.configureCell(for: indexPath, users: attendees, admin: true)
                cell.accessoryView = .none
                cell.accessoryType = .none
                return cell
            }
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: locationViewCellId, for: indexPath) as? LocationViewCell ?? LocationViewCell()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: accountSettingsCellId,
                                                     for: indexPath) as? AccountSettingsTableViewCell ?? AccountSettingsTableViewCell()
            cell.textLabel?.text = "hello?"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            if indexPath.row == attendees.count {
                loadAllAttendees(at: indexPath)
            } else {
                // present action controller: open profile, ...
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 50)))
        let label = UILabel(frame: CGRect(x: 15, y: tableSectionHeaderHeight - 30, width: self.view.frame.width, height: 25))
        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 16)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        headerView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        if section == 1 {
            label.text = "Date & Time"
        } else if section == 2 {
            label.text = "About"
        } else if section == 3 {
            label.text = "Attendees"
        } else if section == 4 {
            label.text = "How to get there"
        } else {
            label.text = ""
        }
        
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return tableSectionHeaderHeight
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else if indexPath.section == 1 {
            return 40
        } else if indexPath.section == 2 {
            return UITableView.automaticDimension
        } else if indexPath.section == 3 {
            return 65
        } else {
            return UITableView.automaticDimension
        }
    }
    
}
