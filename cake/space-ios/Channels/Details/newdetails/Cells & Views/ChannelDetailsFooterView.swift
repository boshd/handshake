//
//  ChannelDetailsFooterView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-13.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelDetailsFooterView: UIView {
    
    let primaryLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        return label
    }()
    
    let secondaryLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        addSubview(primaryLabel)
        addSubview(secondaryLabel)
        
        NSLayoutConstraint.activate([
            primaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            primaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            primaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: 5),
            secondaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            secondaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            secondaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
