//
//  MapController+SearchBarDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-29.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension MapController: UISearchBarDelegate {
    
    func activate(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        // searchVC.showHeader(animated: true)
        searchTableController.searchTableContainerView.tableView.alpha = 1.0
    }
    func deactivate(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        // searchVC.hideHeader(animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        deactivate(searchBar: searchBar)
        UIView.animate(withDuration: 0.5) {
            self.floatingPanelController.move(to: .half, animated: true)
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchRequestStart(dismissKeyboard: true)
        searchTableController.searchTableContainerView.searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.floatingPanelController.move(to: .half, animated: true)
        }
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchTableController.searchCompletionRequest?.cancel()
        searchTableController.searchRequestFuture?.invalidate()
        searchRequestStart(dismissKeyboard: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activate(searchBar: searchBar)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.floatingPanelController.move(to: .full, animated: false)
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTableController.searchRequestFuture?.invalidate()
        if !searchText.isEmpty {
            searchTableController.searchCompletionRequest?.queryFragment = searchText
        } else {
            // show placeholder or smth
        }
    }
}
