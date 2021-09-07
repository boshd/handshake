//
//  MapController+SearchTableDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-29.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit

extension LocationSearchController: LocationSearchDelegate {
    func didSelectCompletionItem(completion: MKLocalSearchCompletion) {
        //
    }
    
    func clickSearchButton(searchBar: UISearchBar) {
        searchBarSearchButtonClicked(searchBar)
    }
    
    func didSelectMapItem(mapItem: MKMapItem) {
        //
    }
}
