//
//  UserCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-03.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        return label
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        imageView?.contentMode = .scaleAspectFill
        
        addSubview(rightLabel)
        
        NSLayoutConstraint.activate([
            rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        
        if textLabel != nil {
            rightLabel.topAnchor.constraint(equalTo: textLabel!.topAnchor, constant: 0).isActive = true
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView?.image = nil
        backgroundColor = .clear
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        imageView?.contentMode = .scaleAspectFill
    }
}
