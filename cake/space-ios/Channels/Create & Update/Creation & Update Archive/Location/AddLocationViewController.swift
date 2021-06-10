//
//  AddLocationViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-21.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol LocationDelegate: class {
    func didPressDone(placemark: MKPlacemark)
}

class AddLocationViewController: UIViewController {
    
    weak var locationDelegate: LocationDelegate?
    
    let locationManager = CLLocationManager()
    var selectedPin: MKPlacemark? = nil

    let addLocationContainerView = AddLocationContainerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupNavigationBar()
        setupLocationManager()
        setupContainerView()
    }
    
    fileprivate func setupContainerView() {
        view.addSubview(addLocationContainerView)
        addLocationContainerView.frame = view.bounds
        addLocationContainerView.doneButton.addTarget(self,action:#selector(doneTapped), for: .touchUpInside)
    }
    
    fileprivate func setupController() {
        navigationItem.searchController = addLocationContainerView.resultSearchController
        definesPresentationContext = true
        addLocationContainerView.locationSearchTable.handleMapSearchDelegate = self
    }
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    fileprivate func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"),
                                         style: .plain,
                                         target: navigationController,
                                         action: #selector(UINavigationController.popViewController(animated:)))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.backgroundColor = ThemeManager.currentTheme().barBackgroundColor
        
        navigationItem.setTitle(title: "Pick location", subtitle: "")
    }
    
    @objc func doneTapped() {
        if let pm = self.selectedPin {
            self.locationDelegate?.didPressDone(placemark: pm)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
