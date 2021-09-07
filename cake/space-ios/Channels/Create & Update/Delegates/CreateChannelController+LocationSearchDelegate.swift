//
//  CreateChannelController+LocationSearchDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-20.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import MapKit
import Firebase

extension CreateChannelController: LocationSearchDelegate {
    func clickSearchButton(searchBar: UISearchBar) {
        
    }
    
    func didSelectMapItem(mapItem: MKMapItem) {
        self.mapItem = mapItem
        
        self.locationName = mapItem.name
        self.locationDescription = mapItem.placemark.title
        self.locationCoordinates = (mapItem.placemark.coordinate.latitude, mapItem.placemark.coordinate.longitude)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelectCompletionItem(completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error == nil {
                guard let mapItem = response?.mapItems[0] else { return }

                self.mapItem = mapItem
                
                self.locationName = mapItem.name
                self.locationDescription = mapItem.placemark.title
                self.locationCoordinates = (mapItem.placemark.coordinate.latitude, mapItem.placemark.coordinate.longitude)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
