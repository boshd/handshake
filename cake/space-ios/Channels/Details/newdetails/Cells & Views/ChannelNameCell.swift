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
        selectionStyle = .none
        backgroundColor = .clear
//        layoutMargins = .zero
        textLabel?.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 20)
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor

        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        textLabel?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
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

