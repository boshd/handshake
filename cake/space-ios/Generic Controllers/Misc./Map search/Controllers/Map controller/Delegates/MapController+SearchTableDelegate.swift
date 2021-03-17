//
//  MapController+SearchTableDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-29.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit

extension MapController: SearchTableDelegate {
    func clickSearchButton(searchBar: UISearchBar) {
        searchBarSearchButtonClicked(searchBar)
    }
    
    func didSelectMapItem(mapItem: MKMapItem) {
        // Find the annotation on the map from the selected table entry, zoom to it, hide the table, and let delegate know
        if let placeAnnotation = findPlaceAnnotation(from: mapItem) {
            centerAndZoomMapOnLocation(placeAnnotation.coordinate)
        }
    }
}
