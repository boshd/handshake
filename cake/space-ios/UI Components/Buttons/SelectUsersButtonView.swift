//
//  SelectUsersButtonView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-05-30.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class SelectUsersButtonView: UIView {
    
    var locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "plus")
        imageView.backgroundColor = .clear
        
        return imageView
    }()

    var label: DynamicLabel = {
        let label = DynamicLabel(withInsets: 2, 2, 4, 4)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.textColor = .white
        label.sizeToFit()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Add people"
        label.backgroundColor = .black
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
//        addSubview(locationIcon)
        addSubview(label)
        
        NSLayoutConstraint.activate([
//            locationIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//            locationIcon.heightAnchor.constraint(equalToConstant: 30),
//            locationIcon.widthAnchor.constraint(equalToConstant: 30),
//            locationIcon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            label.heightAnchor.constraint(equalToConstant: 30),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

