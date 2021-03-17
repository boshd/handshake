//
//  SelectParticipantsController+SearchHandler.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension SelectParticipantsController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {}

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filteredUsers = users
        guard users.count > 0 else { return }
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        setUpCollation()
        UIView.transition(with: tableView, duration: 0.15, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        searchBar.setShowsCancelButton(true, animated: true)

        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsers = searchText.isEmpty ? users : users.filter({ (User) -> Bool in
            return User.localName!.lowercased().contains(searchText.lowercased())
        })
        setUpCollation()
        UIView.transition(with: tableView, duration: 0.15, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }
}

extension SelectParticipantsController { /* hiding keyboard */

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar?.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar?.endEditing(true)
    }
}
