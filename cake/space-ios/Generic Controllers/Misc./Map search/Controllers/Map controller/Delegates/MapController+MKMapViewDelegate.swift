//
//  MapController+MKMapViewDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-28.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit

extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        geocodeRequestCancel()
        nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        nextButton.isEnabled = true
        nextButton.tintColor = ThemeManager.currentTheme().generalTitleColor
        navigationItem.rightBarButtonItem = nextButton
        selectedLocation = view.annotation
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        nextButton.isEnabled = false
        selectedLocation = nil
    }

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        geocodeRequestCancel()
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if view == nil {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            marker.clusteringIdentifier = "MapItem"
            view = marker
        }
        return view
    }
    
    public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        switch mode {
        case .follow:
            locationManagerRequestLocation()
            break
        default:
            break
        }
    }
    
    func centerAndZoomMapOnLocation(_ location: CLLocationCoordinate2D) {
//        let coordinateRegion = MKCoordinateRegion(center: location,
//                                                  latitudinalMeters: 1000,
//                                                  longitudinalMeters: 1000)
//        mapSearchContainerView.mapView.setRegion(coordinateRegion, animated: true)
        
        // change location slightly
        let location = CLLocationCoordinate2D(latitude: location.latitude - 0.0012, longitude: location.longitude)
        let coordinate = location
        let region = mapSearchContainerView.mapView.regionThatFits(MKCoordinateRegion(center: coordinate, latitudinalMeters: 700, longitudinalMeters: 200))
        mapSearchContainerView.mapView.setRegion(region, animated: true)
//        mapSearchContainerView.mapView.setCenter(location, animated: true)
//        let coordinate = CLLocationCoordinate2D(latitude: 49, longitude: -123)
//        let region = self.mapView.regionThatFits(MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
//        self.mapView.setRegion(region, animated: true)
    }
    
    public func deselectAnnotations() {
        for annotation in mapSearchContainerView.mapView.selectedAnnotations {
            mapSearchContainerView.mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}
