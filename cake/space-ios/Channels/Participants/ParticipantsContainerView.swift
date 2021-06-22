//
//  ParticipantsContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-19.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import SVProgressHUD

class ParticipantsContainerView: UIView {
    
    var ind = SVProgressHUD.self
    
    var interfaceSegmented: CustomSegmentedControl = {
        var interface = CustomSegmentedControl()
        interface.translatesAutoresizingMaskIntoConstraints = false
        interface.setButtonTitles(buttonTitles: ["Maybe", "Going", "Not Going"])
        interface.selectorViewColor = ThemeManager.currentTheme().buttonColor
        interface.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        interface.selectorTextColor = ThemeManager.currentTheme().generalTitleColor
        
        return interface
    }()
    
    var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        addSubview(interfaceSegmented)
        addSubview(tableView)
        
        ind.setDefaultMaskType(.clear)
        
        NSLayoutConstraint.activate([
            interfaceSegmented.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            interfaceSegmented.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            interfaceSegmented.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            interfaceSegmented.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: interfaceSegmented.bottomAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    func setColors() {
        interfaceSegmented.updateView()
        interfaceSegmented.selectorViewColor = ThemeManager.currentTheme().buttonColor
        interfaceSegmented.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        interfaceSegmented.selectorTextColor = ThemeManager.currentTheme().generalTitleColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
