//
//  GeneralUpdatesContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-09-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class GeneralUpdatesContainerView: UIView {
    
    let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
//        imageView.image = UIImage(named: "banner-1")
//        imageView.contentMode = .center
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let doneButton: UIButton = {
        let button = InteractiveButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Got it.", for: .normal)
        button.setTitleColor(ThemeManager.currentTheme().buttonIconColor, for: .normal)
        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 17)
        button.addTarget(self, action: #selector(WelcomeViewController.toSignup), for: .touchUpInside)
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        button.cornerRadius = 15
        button.layer.cornerCurve = .continuous
        
        return button
    }()
    
    var titleLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 26)
        label.text = "What's new?"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        addSubview(bannerImageView)
        addSubview(titleLabel)
        addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            bannerImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            bannerImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            bannerImageView.heightAnchor.constraint(equalToConstant: 250),
            
            titleLabel.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            
            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            doneButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
    }
   
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setColors() {
      
    }
}


