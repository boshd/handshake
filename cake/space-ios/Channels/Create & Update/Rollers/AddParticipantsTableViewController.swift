//
//  AddParticipantsViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Contacts

class AddParticipantsController: SelectionTableViewController {
    
    let userCellID = "userCellID"
    
    // how about merging this into selected users? -- later
    var preSelectedUsers = [User]()
    var users = [User]()
    var selectedUsers = [User]()
    var filteredUsers = [User]()
    
    let doneButton: RoundButton = {
        let button = RoundButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setTitle(title: "Add participants", subtitle: "")
        
        setupNavigationBar()
        
        tableView.addSubview(doneButton)
        
        doneButton.setAttributedTitle(NSAttributedString(string: "Done", attributes: [.font: ThemeManager.currentTheme().secondaryFontBold(with: 14)]), for: .normal)
        
        doneButton.bindToKeyboard()
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 80),
            doneButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        handleReloadTable()
        setupTableView()
    }
    
    fileprivate func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"),
                                         style: .plain,
                                         target: navigationController,
                                         action: #selector(UINavigationController.popViewController(animated:)))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        let nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        nextButton.setTitleTextAttributes([.font: ThemeManager.currentTheme().secondaryFontBold(with: 14)], for: .normal)
        nextButton.tintColor = ThemeManager.currentTheme().tintColor
        navigationItem.rightBarButtonItem = nextButton
    }
    
    @objc func donePressed() {
        navigationController?.popViewController(animated: true)
        self.delegate?.selectedElements(shouldBeUpdatedTo: self.selectedUsers)
    }
    
    fileprivate func setupTableView() {
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellID)
        searchBar.placeholder = "Search friends"
    }
    
    func checkIfThereAnyContacts(isEmpty: Bool) {
        if CNContactStore.authorizationStatus(for: .contacts) == .denied || CNContactStore.authorizationStatus(for: .contacts) == .notDetermined || CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            viewPlaceholder.add(for: tableView, title: .deniedContacts, subtitle: .deniedContacts, priority: .medium, position: .center)
        } else {
            viewPlaceholder.remove(from: tableView, priority: .medium)
        }

        guard isEmpty else {
            viewPlaceholder.remove(from: tableView, priority: .medium)
            return
        }

        viewPlaceholder.add(for: tableView, title: .noUsers, subtitle: .noUsers, priority: .medium, position: .center)
        tableView.reloadData()
    }
    
    func handleReloadTable() {
        if users.count == 0 {
            checkIfThereAnyContacts(isEmpty: true)
        } else {
            checkIfThereAnyContacts(isEmpty: false)
        }
    }
    
}

extension AddParticipantsController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: selectionHeaderCellID, for: indexPath) as? SelectionHeaderCell ?? SelectionHeaderCell()
            
            headerCell.headerView.titleLabel.text = "Select friends"
            headerCell.headerView.subtitleLabel.text = "Choose a place for your event. We don't send notifications when you edit the location."
            
            headerCell.isUserInteractionEnabled = false
            
            return headerCell
        } else {
            let userCell = tableView.dequeueReusableCell(withIdentifier: userCellID, for: indexPath) as? UserCell ?? UserCell()
            
            userCell.isUserInteractionEnabled = true
            
            userCell.configureCell(for: indexPath, users: users, admin: false)
            
            if preSelectedUsers.contains(users[indexPath.row]) {
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                userCell.isUserInteractionEnabled = false
                userCell.tintColor = .gray
                userCell.accessoryType = .checkmark
            } else {
                userCell.isUserInteractionEnabled = true
                userCell.tintColor = .blue
                userCell.accessoryType = .checkmark
            }
            
            return userCell
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.users.count == 0 {
            return 0
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        } else {
            selectedUsers.append(users[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            print("deselected 0")
//        } else {
//            print("deselected not 0")
////            selectedUsers.append(users[indexPath.row])
//        }
        if indexPath.section == 1 {
            if let index = selectedUsers.firstIndex(of: users[indexPath.row]) {
                selectedUsers.remove(at: index)
            }
        }
        // selectedElements.remove(at: elements[indexPath.row] as! Int)
    }
    
}

extension AddParticipantsController {

    func updateSearchResults(for searchController: UISearchController) {}

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filteredElements = elements
        guard elements.count > 0 else { return }
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredElements = searchText.isEmpty ? elements : elements.filter({ (User) -> Bool in
            return (User as! User).name!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
}
