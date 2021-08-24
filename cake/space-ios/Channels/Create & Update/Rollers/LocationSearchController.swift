//
//  LocationSearchController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-18.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchDelegate: class {
    func clickSearchButton(searchBar: UISearchBar)
    func didSelectMapItem(mapItem: MKMapItem)
}

class LocationSearchController: UIViewController, CLLocationManagerDelegate {
    
    var delegate: LocationSearchDelegate?
    
    var searchTableContainerView = SearchTableContainerView()
    let viewPlaceholder = ViewPlaceholder()
    
    let mapSearchCompletionCellId = "mapSearchCompletionCellId"
    let mapItemSearchCellId = "mapItemSearchCellId"
    
    // MARK: - Search Variables
    var searchCompletionRequest: MKLocalSearchCompleter? = MKLocalSearchCompleter()
    var searchCompletions = [MKLocalSearchCompletion]()
    
    var searchRequestFuture: Timer?
    var searchRequest: MKLocalSearch?
    var searchMapItems = [MKMapItem]()
    var currentRegion: MKCoordinateRegion?
    
    let locationManager = CLLocationManager()
    
    enum TableType {
        case searchCompletion
        case mapItem
    }
    
    var tableViewType: TableType = .searchCompletion {
        didSet {
            switch tableViewType {
            case .searchCompletion:
                searchTableContainerView.tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                if searchCompletions.count == 0 {
                    tablePopulated(isEmpty: true)
                } else {
                    tablePopulated(isEmpty: false)
                }
            case .mapItem:
                searchTableContainerView.tableView.separatorInset = UIEdgeInsets(top: 0, left: 67, bottom: 0, right: 0)
                if searchMapItems.count == 0 {
                    tablePopulated(isEmpty: true)
                } else {
                    tablePopulated(isEmpty: false)
                }
            }
            searchTableContainerView.tableView.reloadData()
        }
    }
    
    // MARK: - Controller life-cycle
    
    override func loadView() {
        super.loadView()
        view = searchTableContainerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        configureCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Controller setup/config.
    
    fileprivate func configureCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func configureTableView() {
        addObservers()
        
        searchTableContainerView.searchBar.delegate = self
        
        searchTableContainerView.tableView.delegate = self
        searchTableContainerView.tableView.dataSource = self
        searchTableContainerView.tableView.register(MapSearchCompletionCell.self, forCellReuseIdentifier: mapSearchCompletionCellId)
        searchTableContainerView.tableView.register(MapItemSearchCell.self, forCellReuseIdentifier: mapItemSearchCellId)
        searchTableContainerView.tableView.separatorStyle = .singleLine
        searchTableContainerView.tableView.tableFooterView = UIView()
        searchTableContainerView.tableView.keyboardDismissMode = .interactive
        
        searchCompletionRequest = MKLocalSearchCompleter()
        searchTableContainerView.searchBar.delegate = self
        searchCompletionRequest?.delegate = self

        if searchMapItems.count == 0 {
            tablePopulated(isEmpty: true)
        } else {
            tablePopulated(isEmpty: false)
        }
    }
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = "Search Location"
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action: #selector(dismissController))
        cancelButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        navigationItem.rightBarButtonItem = cancelButtonItem
        
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationBar)
        }
    }
    
    func addObservers() {
        //NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    // MARK: - ...
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Cosmetics -- might be removed..
    
    func tablePopulated(isEmpty: Bool) {
        guard isEmpty else {
            viewPlaceholder.remove(from: view, priority: .medium)
            return
        }
        viewPlaceholder.add(for: view, title: .searchForLocation, subtitle: .empty, priority: .medium, position: .top)
    }
    
    // vcvcv
    func searchRequestStart(dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        searchRequestCancel()
        
        guard let text = searchTableContainerView.searchBar.text, !text.isEmpty else {
            searchTableContainerView.searchBar.resignFirstResponder()
            searchMapItems.removeAll()
            searchTableContainerView.tableView.reloadData()
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTableContainerView.searchBar.text
        if let currentRegion = currentRegion {
            request.region = currentRegion
        }
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            self?.searchRequestDidComplete(withResponse: response, error, dismissKeyboard: dismissKeyboard)
        }
        searchRequest = search
    }
    
    func searchRequestCancel() {
        searchCompletionRequest?.cancel()
        searchRequestFuture?.invalidate()
        searchRequest?.cancel()
    }
    
    func searchRequestDidComplete(withResponse response: MKLocalSearch.Response?, _ error: Error?, dismissKeyboard: Bool = false) {
        guard let response = response else {
            return
        }
        searchMapItems = response.mapItems
        tableViewType = .mapItem
//        if isMapPan { // Add new annotations from dragging and searching new areas.
//            var newAnnotations = [PlaceAnnotation]()
//            for mapItem in response.mapItems {
//                if !mapAnnotations.contains(mapItem.placemark) {
//                    mapAnnotations.insert(mapItem.placemark)
//                    newAnnotations.append(PlaceAnnotation(mapItem))
//                }
//            }
//            mapSearchContainerView.mapView.addAnnotations(newAnnotations)
//        } else { // Remove annotations, and resize mapView to new annotations.
//            //tableViewShow()
//            mapAnnotations.removeAll()
//            mapSearchContainerView.mapView.removeAnnotations(mapSearchContainerView.mapView.annotations)  //remove all annotations from map
//            var annotations = [PlaceAnnotation]()
//            for mapItem in response.mapItems {
//                mapAnnotations.insert(mapItem.placemark)
//                annotations.append(PlaceAnnotation(mapItem))
//            }
//
//            mapSearchContainerView.mapView.showAnnotations(annotations, animated: true)
//        }
    }
    

    // MARK: - Search Completions
    // Search Completions Request are invoked on textDidChange in searchBar,
    // and region is updated upon regionDidChange in mapView.
    func searchCompletionRequest(didComplete searchCompletions: [MKLocalSearchCompletion]) {
        searchRequestCancel()
        self.searchCompletions = searchCompletions
        tableViewType = .searchCompletion
    }

    func searchCompletionRequestCancel() {
        searchCompletionRequest?.delegate = nil
        //searchCompletionRequest?.region = mapSearchContainerView.mapView.region
        searchCompletionRequest?.delegate = self
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        // if authorization is denied, setting the region will be automatically skipped.
        // if authorization is given, the region will be set.
    }
    
    @objc
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinates = manager.location?.coordinate {
            currentRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 50000, longitudinalMeters: 50000)
        }
    }
}

