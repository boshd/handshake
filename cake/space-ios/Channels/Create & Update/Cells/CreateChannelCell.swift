//
//  CreateChannelCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-04.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class SelectLocationCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // userInteractionEnabledWhileDragging = false
        contentView.isUserInteractionEnabled = true
        selectionStyle = .default
        
        contentView.backgroundColor = ThemeManager.currentTheme().modalGroupedInsetCellBackgroundColor
        
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        detailTextLabel?.numberOfLines = 0
        
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
    }
  

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setColor() {
        backgroundColor = ThemeManager.currentTheme().modalGroupedInsetCellBackgroundColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setColor()
    }
}
