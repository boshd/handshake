//
//  LocationViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class LocationViewCell: UITableViewCell {
    
    let locationView = LocationView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
        
        addSubview(locationView)
        selectionStyle = .none
        locationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        locationView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        locationView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        locationView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        locationView.heightAnchor.constraint(equalToConstant: 230).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LocationViewCell {
    func configureCell(title: String, subtitle: String?, lat: Double, lon: Double) {
        locationView.locationNameLabel.text = title
        locationView.locationLabel.text = subtitle
        
            let location = CLLocation(latitude: lat, longitude: lon)
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: { [weak self] placemarks, error -> Void in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                guard let placeMark = placemarks?.first else { return }
                let item = MKPlacemark(placemark: placeMark)

                if subtitle == nil {
                    self?.locationView.locationLabel.text = parseAddress(selectedItem: item)
                }

                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                self?.locationView.mapView.addAnnotation(annotation)
                self?.locationView.mapView.showAnnotations([annotation], animated: false)
            })
    }
}
