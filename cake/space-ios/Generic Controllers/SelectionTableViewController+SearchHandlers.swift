//
//  SelectionTableViewController+SearchHandlers.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-24.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit

extension SelectionTableViewController { /* hiding keyboard */

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard #available(iOS 11.0, *) else {
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }
        return true
    }
    
}
