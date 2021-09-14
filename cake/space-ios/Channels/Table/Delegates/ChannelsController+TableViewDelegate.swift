//
//  ChannelsController+TableViewDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theRealmChannels?.count ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellId, for: indexPath) as? ChannelCell ?? ChannelCell()
        guard let realmChannels = theRealmChannels else { return cell }
        cell.currentRegion = currentRegion
        cell.selectionStyle = .default
        cell.configureCell(for: indexPath, channels: realmChannels)
//        cell.accessoryType = .disclosureIndicator
//        cell.accessoryView?.tintColor = ThemeManager.currentTheme().tintColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let theRealmChannels = theRealmChannels else  { return }
        
        let channel = theRealmChannels[indexPath.row]
        // let _ = channel.updateAndReturnStatus()
//        print(self)
        channelLogPresenter.open(channel, controller: self)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension // previously 75
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = DynamicLabel(withInsets: 2, 2, 2, 2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 10)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = .clear
        label.backgroundColor = .clear
        
        let attributedString = NSMutableAttributedString(string: label.text!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.5), range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString

        let headerView = BlurView()
        headerView.addSubview(label)
        headerView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15)
        ])

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let delete = setupDeleteAction(at: indexPath)

        let configuration = UISwipeActionsConfiguration(actions: [delete])


        if #available(iOS 11.0, *) {
            if navigationItem.searchController?.searchBar.text != "" { return configuration }
        }

        if (tableView.cellForRow(at: indexPath) as? UserCell) != nil {
            return configuration
        }

        return configuration
    }
    
}
