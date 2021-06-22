//
//  ChannelDetailsCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelDetailsCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }
    
}
