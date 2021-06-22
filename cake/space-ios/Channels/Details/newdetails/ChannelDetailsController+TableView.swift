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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
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
            let cell = ChannelDetailsCell(style: .subtitle, reuseIdentifier: channelDetailsCellId)
            
            let startDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel?.startTime.value ?? 0)))
            let endDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel?.endTime.value ?? 0)))
    
            fullDateFormatter.dateFormat = "MMM d @ h:mm a"
            timeFormatter.dateFormat = "h:mm a"
            var endFullDate = fullDateFormatter.string(from: endDate)
    
            if startDate.isInSameDay(as: endDate) {
                endFullDate = timeFormatter.string(from: endDate)
                fullDateFormatter.dateFormat = "EE, MMM d @ h:mm a"
            }
    
            let startFullDate = fullDateFormatter.string(from: startDate)
    
            let mainString = "\(startFullDate) → \(endFullDate)"
            let stringToColor = "→"
            let range = (mainString as NSString).range(of: stringToColor)
            let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
            mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeManager.currentTheme().tintColor, range: range)
            mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: ThemeManager.currentTheme().secondaryFont(with: 12), range: range)
            
            cell.textLabel?.attributedText = mutableAttributedString
            
            cell.detailTextLabel?.text = "Event dates are subject to change by organizer."
            cell.imageView?.image = UIImage(named: "Time Square")
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: channelDescriptionCellId, for: indexPath) as? ChannelDescriptionCell ?? ChannelDescriptionCell()
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
        } else if indexPath.section == 3 {
            if indexPath.row == attendees.count && !allAttendeesLoaded {
                let cell = LoadMoreCell(style: .subtitle, reuseIdentifier: loadMoreCellId)
                return cell
            } else {
                let cell = UITableViewCell(style: .value2, reuseIdentifier: userCellId) as? UserCell ?? UserCell(style: .subtitle, reuseIdentifier: userCellId)
                cell.configureCell(for: indexPath, users: attendees, admin: true)
                cell.selectionStyle = .none
                cell.accessoryView = .none
                cell.accessoryType = .none
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: locationViewCellId, for: indexPath) as? LocationViewCell ?? LocationViewCell()
            cell.locationView.locationNameLabel.text = "Billings Bridge Shopping Centre"
            cell.locationView.locationLabel.text = "2277 Riverside Dr., Ottawa, ON K1H 7X6"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            if let cell = cell as? ChannelDescriptionCell {
                let readMoreTextView = cell.textView
                readMoreTextView.onSizeChange = { [unowned tableView, unowned self] r in
                    let point = tableView.convert(r.bounds.origin, from: r)
                    guard let indexPath = tableView.indexPathForRow(at: point) else { return }
                    if r.shouldTrim {
                        self.expandedCells.remove(indexPath.row)
                    } else {
                        self.expandedCells.insert(indexPath.row)
                    }
                    tableView.reloadData()
                }
            }
        }
        
       
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = channelDetailsContainerView.tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        
        if indexPath.section == 3 {
            if indexPath.row == attendees.count {
                loadAllAttendees(at: indexPath)
            } else {
                presentLocationActions()
            }
        } else if indexPath.section == 3 {
            print("detected")
        } else if indexPath.section == 4 {
            presentLocationActions()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: 45)))
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 15)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        headerView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        if section == 1 {
            label.text = "Date & Time"
        } else if section == 2 {
            label.text = "About"
        } else if section == 3 {
            let count = attendees.count
            label.text = count == 1 ? "\(count) attendee" : "\(count) attendees"
        } else if section == 4 {
            label.text = "How to get there"
        } else {
            label.text = ""
        }
        
        headerView.addSubview(label)
        
        if section == 3 {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(ThemeManager.currentTheme().tintColor, for: .normal)
//            button.backgroundColor = .handshakeLightPurple
            button.setTitle("RSVP LIST", for: .normal)
//            button.layer.cornerRadius = 10
//            button.layer.cornerCurve = .continuous
            button.contentHorizontalAlignment = .right
            button.titleLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
            button.addTarget(self, action: #selector(presentRSVPList), for: .touchUpInside)
            headerView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
                button.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0),
//                button.heightAnchor.constraint(equalToConstant: 20),
//                button.widthAnchor.constraint(equalToConstant: 120)
            ])
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)
        ])
        
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
            return 40
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
