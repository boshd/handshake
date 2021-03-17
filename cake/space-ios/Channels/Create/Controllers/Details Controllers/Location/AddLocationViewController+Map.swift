//
//  AddLocationViewController+CLLocationManagerDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-07-11.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Foundation
import MapKit

extension AddLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            addLocationContainerView.mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
}

extension AddLocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        selectedPin = placemark
        addLocationContainerView.mapView.removeAnnotations(addLocationContainerView.mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        addLocationContainerView.mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        addLocationContainerView.mapView.setRegion(region, animated: true)
    }
}
