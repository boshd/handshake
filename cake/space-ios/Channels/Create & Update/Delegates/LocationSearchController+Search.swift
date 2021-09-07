//
//  LocationSearchController+Search.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-18.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension LocationSearchController: UISearchBarDelegate {
    
    func activate(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        // searchVC.showHeader(animated: true)
        searchTableContainerView.tableView.alpha = 1.0
    }
    func deactivate(searchBar: UISearchBar) {
        searchTableContainerView.searchBar.resignFirstResponder()
        searchTableContainerView.searchBar.showsCancelButton  = false
//         searchVC.hideHeader(animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        deactivate(searchBar: searchBar)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        completionSearchRequestStart(dismissKeyboard: true)
        searchTableContainerView.searchBar.resignFirstResponder()
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchCompletionRequest?.cancel()
        searchRequestFuture?.invalidate()
        completionSearchRequestStart(dismissKeyboard: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activate(searchBar: searchBar)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRequestFuture?.invalidate()
//        print(searchCompletions.count)
        print("nnn \(searchMapItems.count)")
//        if !searchText.isEmpty {
            completionSearchRequestStart(dismissKeyboard: true)
//            searchRequestStart(dismissKeyboard: true)
//        } else {
//            print("empty")
//            searchMapItems.removeAll()
//            // show placeholder or smth
//        }
    }
}
