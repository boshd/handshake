//
//  ChannelHeaderView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-25.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelsHeaderView: UIView {
    
    var activityView = ActivityTitleView()
    
    var title: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 30)
        label.numberOfLines = 2
        
        return label
    }()
    
    var subTitle: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 11)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        return label
    }()
    
    var userImageButton: MainRoundButton = {
        let button = MainRoundButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lighterGray()
        button.isUserInteractionEnabled = true
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.masksToBounds = true
        button.imageView?.image = UIImage(named: "UserpicIcon")
        button.cornerRadius = 22
        
        return button
    }()
    
    var seperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().seperatorColor
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        
        backgroundColor = .clear
        
        addSubview(title)
        addSubview(activityView)
        addSubview(subTitle)
        addSubview(userImageButton)
        addSubview(seperator)
        
        NSLayoutConstraint.activate([
            subTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            subTitle.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            
//            activityView.leadingAnchor.constraint(equalTo: subTitle.trailingAnchor, constant: 40),
//            activityView.centerYAnchor.constraint(equalTo: subTitle.centerYAnchor, constant: 0),
//            activityView.heightAnchor.constraint(equalToConstant: 14),
//            activityView.widthAnchor.constraint(equalToConstant: 130),
            
            activityView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            activityView.topAnchor.constraint(equalTo: subTitle.bottomAnchor, constant: 5),
            
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            title.topAnchor.constraint(equalTo: subTitle.bottomAnchor, constant: 5),
            
            userImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            userImageButton.bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 0),
            userImageButton.heightAnchor.constraint(equalToConstant: 44),
            userImageButton.widthAnchor.constraint(equalToConstant: 44),
            
            seperator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            seperator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            seperator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            seperator.heightAnchor.constraint(equalToConstant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showActivityView(with title: ActivityTitle) {
        DispatchQueue.main.async { [weak self] in
            self?.activityView.isHidden = false
            self?.activityView.titleLabel.text = title.rawValue
            self?.title.isHidden = true
        }
    }

    func hideActivityView(with title: ActivityTitle) {
        DispatchQueue.main.async { [weak self] in
            self?.activityView.isHidden = true
            self?.title.isHidden = false
        }
    }
    
}
