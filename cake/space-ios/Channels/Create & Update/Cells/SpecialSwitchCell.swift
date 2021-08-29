//
//  SpecialSwitchCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-21.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit


class SpecialSwitchCell: UITableViewCell {

    var switchAccessory: UISwitch = {
        var switchAccessory = UISwitch()
        switchAccessory.isUserInteractionEnabled = true
        switchAccessory.onTintColor = ThemeManager.currentTheme().tintColor
        switchAccessory.isOn = false
        
        return switchAccessory
    }()
  
    var switchTapAction: ((Bool) -> Void)?
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        switchAccessory.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        switchAccessory.backgroundColor = .clear
        selectionStyle = .none
        
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        textLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 13)
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        
        contentView.isUserInteractionEnabled = true
        
        accessoryView = switchAccessory
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        switchAccessory.backgroundColor = .clear
        switchAccessory.onTintColor = ThemeManager.currentTheme().tintColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
    }
  
    @objc func switchStateDidChange(_ sender: UISwitch) {
        switchTapAction?(sender.isOn)
    }

    func setupCell(title: String, subtitle: String) {
        textLabel?.text = title
        
        if subtitle == "" {
            detailTextLabel?.text = nil
        } else {
            detailTextLabel?.text = subtitle
        }
        
    }
}


