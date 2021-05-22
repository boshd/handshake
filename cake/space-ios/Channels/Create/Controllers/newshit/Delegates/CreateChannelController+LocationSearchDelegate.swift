//
//  CreateChannelController+LocationSearchDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-20.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import MapKit

extension CreateChannelController: LocationSearchDelegate {
    func clickSearchButton(searchBar: UISearchBar) {
        //
    }
    
    func didSelectMapItem(mapItem: MKMapItem) {
        self.dismiss(animated: true, completion: nil)
        self.mapItem = mapItem
        self.locationName = mapItem.name
        self.locationCoordinates = (mapItem.placemark.coordinate.latitude, mapItem.placemark.coordinate.longitude)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}
