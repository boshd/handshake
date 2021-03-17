//
//  ChannelLogHeaderView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-15.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelLogHeaderView: UIView {
    
    var timeLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
        
        return label
    }()
    
    var locationNameLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
        
        return label
    }()
    
    let eventStatus: DynamicLabel = {
        let label = DynamicLabel(withInsets: 2, 2, 3, 3)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .defaultHotGreen()
        label.textAlignment = .right
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 10)
        label.cornerRadius = 3
        label.backgroundColor = .greenEventStatusBackground()
        
        return label
    }()
    
    var viewDetails: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.currentTheme().tintColor
        label.textAlignment = .left
        label.layer.masksToBounds = true
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 20)
        label.text = "→"
        // →
        
        return label
    }()
    
    let channelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.5
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    var seperator: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        backgroundColor = ThemeManager.currentTheme().chatLogHeaderBackgroundColor
        
        layer.shadowColor = ThemeManager.currentTheme().buttonTextColor.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: -1, height: 2)
        
//        addSubview(channelImageView)
        addSubview(eventStatus)
        addSubview(timeLabel)
        addSubview(locationNameLabel)
        addSubview(viewDetails)
        addSubview(seperator)
        
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            timeLabel.bottomAnchor.constraint(equalTo: locationNameLabel.topAnchor, constant: -8),
            
            locationNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            locationNameLabel.bottomAnchor.constraint(equalTo: eventStatus.topAnchor, constant: -8),
            
            eventStatus.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            eventStatus.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            
            viewDetails.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            viewDetails.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            seperator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            seperator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            seperator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            seperator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setColors() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        timeLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        timeLabel.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
        locationNameLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        viewDetails.textColor = ThemeManager.currentTheme().tintColor
        
        layer.shadowColor = ThemeManager.currentTheme().buttonTextColor.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: -1, height: 2)
    }
    
}
