//
//  MapSearchContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class MapSearchContainerView: UIView {
    
    var mapView: MKMapView = {
        var mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.overrideUserInterfaceStyle = ThemeManager.currentTheme().generalOverrideUserInterfaceStyle
        return mapView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
