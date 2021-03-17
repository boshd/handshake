//
//  LocationCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-23.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    let titleLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.font = ThemeManager.currentTheme().secondaryFont(with: 16)
        label.numberOfLines = 2
        label.sizeToFit()
        
        return label
    }()
    
    let subTitleLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 2, 2, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        label.numberOfLines = 2
        label.sizeToFit()
        
        return label
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = ""
        subTitleLabel.text = ""
    }
    
}
