//
//  SettingsContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-10-15.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class SettingsContainerView: UIView {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear

        return tableView
    }()

    let logoutButton: UIButton = {
        let logoutButton = UIButton(frame: .zero)
        logoutButton.titleLabel?.text = "Logout"
        logoutButton.setTitle("logout", for: .normal)
        logoutButton.setTitleColor(.black, for: .normal)
        
        return logoutButton
    }()
    
    let dismissControllerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("close", for: .normal)
        button.titleLabel?.textColor = .black
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(dismissControllerButton)
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            dismissControllerButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            dismissControllerButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            dismissControllerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dismissControllerButton.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: dismissControllerButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}

