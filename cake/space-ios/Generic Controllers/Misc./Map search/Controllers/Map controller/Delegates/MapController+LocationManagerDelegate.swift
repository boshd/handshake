//
//  MapController+LocationManagerDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-28.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit
import CoreLocation

extension MapController: CLLocationManagerDelegate {
    public func locationManagerRequestLocation(withPermission permission: CLAuthorizationStatus? = nil) {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        case .notDetermined:
            guard let permission = permission else {
                return
            }
            switch permission {
            case .authorizedAlways:
                locationManager.requestAlwaysAuthorization()
                break
            case .authorizedWhenInUse:
                locationManager.requestWhenInUseAuthorization()
                break
            default:
                break
            }
            break
        case .denied:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { [weak self] _ in
                // TODO: Check if conflicts with locationManager(manager: didChangeAuthorization:)
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.locationManager.requestLocation()
                    break
                default:
                    break
                }
            }
            break
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
            break
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        mapSearchContainerView.mapView.setCenter(location.coordinate, animated: true)
        manager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
