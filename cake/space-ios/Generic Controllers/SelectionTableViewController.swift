//
//  SelectionTableViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-23.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

protocol SelectedElementsDelegate: class {
    func selectedElements(shouldBeUpdatedTo selectedElements: [Any])
}

class SelectionTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {

    var elements = [Any]()
    var selectedElements = [Any]()
    var filteredElements = [Any]()
    
    weak var delegate: SelectedElementsDelegate?
    
    let selectionHeaderCellID = "selectionHeaderCellID"
    let elementCellID = "elementCellID"
    
    var viewPlaceholder = ViewPlaceholder()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .white
        searchBar.backgroundColor = .clear
        searchBar.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableViewController()
    }
    
    fileprivate func setupTableViewController() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SelectionHeaderCell.self, forCellReuseIdentifier: selectionHeaderCellID)
//        tableView.tableHeaderView = searchBar
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.allowsMultipleSelection = true
        self.navigationItem.rightBarButtonItem = editButtonItem
        
//        searchBar.delegate = self
        
//        NSLayoutConstraint.activate([
//            searchBar.widthAnchor.constraint(equalToConstant: tableView.frame.width - 50),
//            searchBar.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
//        ])
    }
    
}

extension SelectionTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return elements.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 55
        }
    }
    
}
