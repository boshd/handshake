//
//  ContactsController+TableView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class ContactsTableViewHeaderView: UIView {
    
    var disclaimerLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
        label.numberOfLines = 0
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(disclaimerLabel)
        
        NSLayoutConstraint.activate([
            disclaimerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            disclaimerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            disclaimerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            disclaimerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
