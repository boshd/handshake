//
//  CreateChannelCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-04.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class CreateChannelCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        userInteractionEnabledWhileDragging = false
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none
        
        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        detailTextLabel?.numberOfLines = 0
        
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
    }
  

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setColor() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setColor()
    }
}
