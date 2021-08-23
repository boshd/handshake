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
        super.init(style: .subtitle, reuseIdentifier: nil)
        
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        textLabel?.numberOfLines = 0
        detailTextLabel?.numberOfLines = 0
        
        addSubview(locationView)
        selectionStyle = .none
        locationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        locationView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        locationView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        locationView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        locationView.heightAnchor.constraint(equalToConstant: 230).isActive = true
        
        let startCoord = CLLocationCoordinate2DMake(37.766997, -122.422032)
        let adjustedRegion = locationView.mapView.regionThatFits(MKCoordinateRegion(center: startCoord, latitudinalMeters: 500, longitudinalMeters: 500))
        locationView.mapView.setRegion(adjustedRegion, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    }
    
}

extension LocationViewCell {
    func configureCell(title: String, subtitle: String?, annotation: MKAnnotation?, addy: String?) {
        locationView.locationNameLabel.text = title
        locationView.locationLabel.text = subtitle
        
        
        
        if let addy = addy {
            if subtitle == nil {
                self.locationView.locationLabel.text = addy
            }
        }
        
        if let annotation = annotation {
            self.locationView.mapView.addAnnotation(annotation)
            self.locationView.mapView.showAnnotations([annotation], animated: true)
        }
    }
}
