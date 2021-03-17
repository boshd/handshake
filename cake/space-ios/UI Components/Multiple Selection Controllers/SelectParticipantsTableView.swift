//
//  SelectParticipantsTableView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import SDWebImage

extension SelectParticipantsController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsersWithSection[section].count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ThemeManager.currentTheme().generalBackgroundColor
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
            headerTitle.textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return selectCell(for: indexPath)!
    }

    fileprivate func selectCell(for indexPath: IndexPath) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: usersCellID, for: indexPath) as! ParticipantTableViewCell
        cell.selectParticipantsController = self

        let backgroundView = UIView()
        backgroundView.backgroundColor = cell.backgroundColor
        cell.selectedBackgroundView = backgroundView

        let user = filteredUsersWithSection[indexPath.section][indexPath.row]

        DispatchQueue.main.async {
            cell.isSelected = user.isSelected
        }

        if let name = user.localName {
            cell.title.text = name
        } else if let name = user.name {
            cell.title.text = name
        }
        
        if preSelectedUsers.contains(user) {
            cell.isUserInteractionEnabled = false
            cell.title.textColor = .gray
            cell.tintColor = .gray
        } else {
            cell.isUserInteractionEnabled = true
            cell.title.textColor = ThemeManager.currentTheme().generalTitleColor
            cell.tintColor = ThemeManager.currentTheme().tintColor
            cell.accessoryType = .checkmark
        }

        cell.subtitle.textColor = ThemeManager.currentTheme().generalSubtitleColor

        guard let url = user.userThumbnailImageUrl else { return cell }
        cell.icon.sd_setImage(with: URL(string: url), placeholderImage:  UIImage(named: "UserpicIcon"), options: [.continueInBackground], completed: { (image, error, cacheType, url) in
            guard image != nil else { return }
            guard cacheType != SDImageCacheType.memory, cacheType != SDImageCacheType.disk else {
                cell.icon.alpha = 1
                return
            }
            cell.icon.alpha = 0
            UIView.animate(withDuration: 0.25, animations: { cell.icon.alpha = 1 })
        })

        return cell
    }
}

