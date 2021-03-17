//
//  FacetimeView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-21.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class FacetimeView: UIView {

    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        return view
    }()
    
    var detailsLabel: DynamicLabel = {
        let locationLabel = DynamicLabel(withInsets: 0, 0, 0, 0)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        locationLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        locationLabel.sizeToFit()
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 0
        locationLabel.text = "sfknv dkf vjkdfjkv djkf vjkdf jkvd fkjv jdf "
        locationLabel.backgroundColor = .clear
        
        return locationLabel
    }()

    var facetimeButton: InteractiveButton = {
        var button = InteractiveButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .eventOrange()
//        button.overrideUserInterfaceStyle = .dark
        button.isUserInteractionEnabled = false
        button.cornerRadius = 15
        button.backgroundColor = .eventOrange()
        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBoldItalic(with: 13)
//        button.titleLabel?.textColor = .eventOrange()
        button.layer.cornerRadius = 15
        
        button.setTitle("Call", for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: -2, height: 3)

        
        addSubview(containerView)
        containerView.addSubview(detailsLabel)
        containerView.addSubview(facetimeButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            facetimeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            facetimeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60),
            facetimeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60),
            facetimeButton.heightAnchor.constraint(equalToConstant: 35),
            
            detailsLabel.topAnchor.constraint(equalTo: facetimeButton.bottomAnchor, constant: 5),
            detailsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            detailsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -13),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

