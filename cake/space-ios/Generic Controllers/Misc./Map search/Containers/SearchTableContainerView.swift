//
//  SearchTableContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class SearchTableContainerView: UIView {
    
    var searchBar: UISearchBar = {
        var searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barStyle = ThemeManager.currentTheme().barStyle
        searchBar.tintColor = ThemeManager.currentTheme().tintColor
        searchBar.setTextColor(color: ThemeManager.currentTheme().generalTitleColor)
        searchBar.overrideUserInterfaceStyle = ThemeManager.currentTheme().generalOverrideUserInterfaceStyle
        searchBar.placeholder = "Search for a place or address"
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = true
        searchBar.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        return searchBar
    }()
    
    var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(searchBar)
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
        
    }
    
    func setColors() {
        searchBar.barStyle = ThemeManager.currentTheme().barStyle
        searchBar.tintColor = ThemeManager.currentTheme().tintColor
        searchBar.overrideUserInterfaceStyle = ThemeManager.currentTheme().generalOverrideUserInterfaceStyle
        searchBar.placeholder = "Search for a place or address"
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = true
        searchBar.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
