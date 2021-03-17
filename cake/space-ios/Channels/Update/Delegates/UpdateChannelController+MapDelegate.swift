//
//  UpdateChannelController+MapDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import MapKit

extension UpdateChannelController: MapControllerDelegate {
    func didUpdateSelectedLocation(with updatedLocation: MKAnnotation?) {
        guard let location_ = updatedLocation else { return }
        location = (location_.coordinate.latitude, location_.coordinate.longitude)
        
        
        if let name = location_.title, let title = name {
            locationName = title
        }
        
        if let subtitle = location_.subtitle {
            locationSubtitle = subtitle
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
