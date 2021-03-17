//
//  CreateChannelController+Map.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-01.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit
import UIKit

extension CreateChannelController: LocationDelegate {
    func didPressDone(placemark: MKPlacemark) {
        guard let locationTitle = placemark.name else { return }
        
        location = (placemark.coordinate.latitude, placemark.coordinate.longitude)
        locationName = placemark.name
        
//        mainSection[0] = (title: "", secondaryTitle: locationTitle, type: "location")
        tableView.reloadData()
    }
}
