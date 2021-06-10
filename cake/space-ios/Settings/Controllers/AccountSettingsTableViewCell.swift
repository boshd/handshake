//
//  AccountSettingsTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-23.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class AccountSettingsTableViewCell: InteractiveTableViewCell {
    
    var topInset: CGFloat = 0
    var leftInset: CGFloat = 20
    var bottomInset: CGFloat = 0
    var rightInset: CGFloat = 20
  
    var icon: UIImageView = {
        var icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        return icon
    }()
  
    var title: UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = ThemeManager.currentTheme().secondaryFontMedium(with: 13)
        title.textColor = ThemeManager.currentTheme().generalTitleColor

        return title
    }()
  
  
    let separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = ThemeManager.currentTheme().seperatorColor

        return separator
    }()
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        self.layoutMargins = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        userInteractionEnabledWhileDragging = false
        contentView.isUserInteractionEnabled = false
        selectionStyle = .none
        
        
        
//        setColor()
        
//        contentView.backgroundColor = .red
        backgroundColor = ThemeManager.currentTheme().groupedInsetCellBackgroundColor
        
        contentView.addSubview(icon)
        
        icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        contentView.addSubview(title)
        title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        title.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
//        addSubview(separator)
//        separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
//        separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
//        separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
//        separator.heightAnchor.constraint(equalToConstant: 0.4).isActive = true
    }
  

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    fileprivate func setColor() {
        backgroundColor = ThemeManager.currentTheme().groupedInsetCellBackgroundColor
        accessoryView?.backgroundColor = backgroundColor
        title.backgroundColor = backgroundColor
        icon.backgroundColor = backgroundColor
        title.textColor = ThemeManager.currentTheme().generalTitleColor
        selectionColor = ThemeManager.currentTheme().cellSelectionColor
        separator.backgroundColor = ThemeManager.currentTheme().seperatorColor
    }
  
    override func prepareForReuse() {
        super.prepareForReuse()
        setColor()
    }
}

