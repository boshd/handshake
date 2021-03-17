//
//  ButtonCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-30.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    var resetButton: InteractiveButton = {
        var button = InteractiveButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        button.setTitle("Reset notifications", for: .normal)
        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBoldItalic(with: 12)
        button.titleLabel?.textColor = ThemeManager.currentTheme().buttonIconColor
        button.layer.cornerRadius = 15
        button.layer.cornerCurve = .continuous
        
        return button
    }()
    
    var detailsLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.numberOfLines = 2
        label.text = "If you're experiencing issues with push notifications, try resseting the push notification token. This operation can take up to 2 minutes."
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        contentView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        
        addSubview(detailsLabel)
        contentView.addSubview(resetButton)
        
        selectionStyle = .none
        
        NSLayoutConstraint.activate([
            detailsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            detailsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            resetButton.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 15),
            resetButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            resetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
//            resetButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        contentView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
    }
}



