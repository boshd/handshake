//
//  LocationView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-05-18.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class LocationView: UIView {
    
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        return view
    }()
    
    var locationNameLabel: DynamicLabel = {
       let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.sizeToFit()
        label.textAlignment = .left
        label.numberOfLines = 2
        label.text = "Dunton Tower"
        
        return label
    }()

    var locationLabel: DynamicLabel = {
        let locationLabel = DynamicLabel(withInsets: 0, 0, 0, 0)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        locationLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        locationLabel.sizeToFit()
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 2
        locationLabel.backgroundColor = .clear
        
        return locationLabel
    }()
    
    var mapView: MKMapView = {
        var mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.backgroundColor = .gray
        mapView.overrideUserInterfaceStyle = ThemeManager.currentTheme().mapViewStyle
        mapView.isUserInteractionEnabled = false
        
        return mapView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = ThemeManager.currentTheme().mapViewBackgroundColor
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.shadowColor = ThemeManager.currentTheme().generalTitleColor.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 15
        layer.shadowOffset = CGSize(width: -2, height: 3)
        
        layer.cornerRadius = 15
        
        addSubview(containerView)
        containerView.addSubview(locationNameLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            mapView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            
            locationNameLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 10),
            locationNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            locationNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            locationLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            locationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -13),
        ])
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
