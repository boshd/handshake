//
//  ChannelNameCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelNameCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        textLabel?.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 20)
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        textLabel?.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 20)
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
    }
    
}

