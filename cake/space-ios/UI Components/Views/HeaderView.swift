//
//  HeaderView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    var titleLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 30)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.textAlignment = .center
        
        return label
    }()
    
    
    var subtitleLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
