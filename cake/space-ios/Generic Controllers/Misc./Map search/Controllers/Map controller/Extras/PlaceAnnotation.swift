//
//  PlaceAnnotation.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-28.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let mapItem: MKMapItem
    let coordinate: CLLocationCoordinate2D
    let title, subtitle: String?
    
    init(_ mapItem: MKMapItem) {
        self.mapItem = mapItem
        coordinate = mapItem.placemark.coordinate
        title = mapItem.name
        subtitle = nil
    }
}
