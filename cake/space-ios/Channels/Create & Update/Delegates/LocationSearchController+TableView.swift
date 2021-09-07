//
//  SearchTableController+TableView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-27.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension LocationSearchController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewType {
        case .searchCompletion:
            return searchCompletions.count
        case .mapItem:
            return searchMapItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewType {
        case .searchCompletion:
            let cell = MapSearchCompletionCell(style: .value2, reuseIdentifier: mapSearchCompletionCellId)
            cell.viewSetup(withSearchCompletion: searchCompletions[indexPath.row])
            return cell
        case .mapItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: mapItemSearchCellId, for: indexPath) as? MapItemSearchCell ?? MapItemSearchCell()
            cell.viewSetup(withMapItem: searchMapItems[indexPath.row], tintColor: UIColor.red)
            return cell
        }
    }
}

extension LocationSearchController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableViewType {
        case .searchCompletion:
            guard searchCompletions.count > indexPath.row else {
                return
            }
//            searchTableContainerView.searchBar.text = searchCompletions[indexPath.row].title
//            self.delegate?.clickSearchButton(searchBar: searchTableContainerView.searchBar)
            let selectedCompletionItem = searchCompletions[indexPath.row]
            self.delegate?.didSelectCompletionItem(completion: selectedCompletionItem)
            break
        case .mapItem:
            guard searchMapItems.count > indexPath.row else {
                return
            }
            let selectedMapItem = searchMapItems[indexPath.row]
            self.delegate?.didSelectMapItem(mapItem: selectedMapItem)
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTableContainerView.searchBar.resignFirstResponder()
    }
}
