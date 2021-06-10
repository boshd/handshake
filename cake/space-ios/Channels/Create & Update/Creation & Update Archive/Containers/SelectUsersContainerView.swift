//
//  SelectUsersContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-10-19.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class SelectUsersContainerView: UIView {
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Pick your people"
        titleLabel.font = ThemeManager.currentTheme().primaryFontBold(with: 28)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Pick the people you want to invite to this event."
        descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textAlignment = .center
        
        return descriptionLabel
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isMultipleTouchEnabled = false
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .nude()
        
        
        
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(tableView)
        
        tableView.backgroundColor = .nude()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
