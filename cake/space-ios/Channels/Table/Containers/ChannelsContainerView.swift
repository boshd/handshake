//
//  ChannelContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelsContainerView: UIView {
    
    var channelsHeaderView = ChannelsHeaderView()
    
    let createButton: MainRoundButton = {
        let button = MainRoundButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 30
//        button.setImage(UIImage(named: "Plus"), for: .normal)
//        button.backgroundColor = ThemeManager.currentTheme().secondaryButtonBackgroundColor
        button.tintColor = ThemeManager.currentTheme().tintColor
        return button
    }()
    
    let contactsButton: MainRoundButton = {
        let button = MainRoundButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "contacts")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.cornerRadius = 30
        return button
    }()

    lazy var navigationItem: UINavigationItem = {
        var item = UINavigationItem(title: "")
        
        item.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: nil)
        item.leftBarButtonItem?.tintColor = .lightGray
        
        item.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        item.rightBarButtonItem?.tintColor = .lightGray
        
        return item
    }()
    
    lazy var navigationBar: UINavigationBar = {
        var bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .white
        bar.tintColor = .black
        bar.isTranslucent = false
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        
        bar.setItems([navigationItem], animated: true)
        return bar
    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.separatorStyle = .none
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 110, bottom: 0, right: 0)
        tableView.delaysContentTouches = false
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
//        addSubview(channelsHeaderView)
        addSubview(tableView)
        addSubview(createButton)
        addSubview(contactsButton)
        
        NSLayoutConstraint.activate([
//            channelsHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
//            channelsHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//            channelsHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//            channelsHeaderView.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
//            contactsButton.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -10),
//            contactsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            contactsButton.heightAnchor.constraint(equalToConstant: 60),
//            contactsButton.widthAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
