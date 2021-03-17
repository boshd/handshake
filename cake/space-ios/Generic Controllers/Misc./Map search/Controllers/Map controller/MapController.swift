//
//  MapController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit
import UIKit
import FloatingPanel

protocol MapControllerDelegate {
    func didUpdateSelectedLocation(with updatedLocation: MKAnnotation?)
}

class MapController: UIViewController {
    
    var mapControllerDelegate: MapControllerDelegate?
    
    var mapSearchContainerView = MapSearchContainerView()
    lazy var searchTableController = SearchTableController()
    var locationManager = CLLocationManager()
    var geocodeRequest = CLGeocoder()
    var searchCompletionRequest = MKLocalSearchCompleter()
    
    var mapAnnotations = Set<MKPlacemark>()
    var searchMapItems = [MKMapItem]()
    
    var geocodeRequestFuture: Timer?
    var floatingPanelController: FloatingPanelController!
    open var userLocationRequest: CLAuthorizationStatus?
    var selectedLocation: MKAnnotation?
    var searchRequestFuture: Timer?
    var searchRequest: MKLocalSearch?
    
    var nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
    
    // MARK: - Controller Life-Cycle
    
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupNavigationbar()
        addBottomSheetView()
        configureCurrentLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // responsible for changing theme based on system theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme))
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) &&
            userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            print("srsfsf")
            if traitCollection.userInterfaceStyle == .light {
                ThemeManager.applyTheme(theme: .normal)
            } else {
                ThemeManager.applyTheme(theme: .dark)
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//        mapSea = ThemeManager.currentTheme().scrollBarStyle
        mapSearchContainerView.mapView.overrideUserInterfaceStyle = ThemeManager.currentTheme().generalOverrideUserInterfaceStyle
        
        
//        DispatchQueue.main.async { [weak self] in
//            self?.tableView.reloadData()
//        }
    }
    
    // MARK: - Controller setup and configuration
    
    fileprivate func loadViews() {
        let view = mapSearchContainerView
        self.view = view
    }
    
    fileprivate func configure() {
        locationManager.delegate = self
        mapSearchContainerView.mapView.delegate = self
        mapSearchContainerView.mapView.showsUserLocation = true
        if let userLocationRequest = userLocationRequest {
            locationManagerRequestLocation(withPermission: userLocationRequest)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    fileprivate func configureCurrentLocation() {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }

        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapSearchContainerView.mapView.setRegion(viewRegion, animated: false)
        }
        
        self.locationManager = locationManager

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    fileprivate func setupNavigationbar() {
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        cancelButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = cancelButtonItem
        
        nextButton.tintColor = ThemeManager.currentTheme().generalTitleColor
        nextButton.isEnabled = false
        navigationItem.rightBarButtonItem = nextButton
        
        title = "Select location"
    }
   
    func addBottomSheetView() {
        floatingPanelController = FloatingPanelController()
        floatingPanelController.set(contentViewController: searchTableController)
        floatingPanelController.delegate = self
        floatingPanelController.addPanel(toParent: self)
        searchTableController.searchCompletionRequest = MKLocalSearchCompleter()
        searchTableController.searchTableContainerView.searchBar.delegate = self
        searchTableController.searchCompletionRequest?.delegate = self
        searchTableController.delegate = self
        searchTableController.searchCompletionRequest?.region = mapSearchContainerView.mapView.region
    }
    
    // MARK: - Search Completions
    // Search Completions Request are invoked on textDidChange in searchBar,
    // and region is updated upon regionDidChange in mapView.
    func searchCompletionRequest(didComplete searchCompletions: [MKLocalSearchCompletion]) {
        searchRequestCancel()
        searchTableController.searchCompletions = searchCompletions
        searchTableController.tableViewType = .searchCompletion
    }
    
    func searchCompletionRequestCancel() {
        searchTableController.searchCompletionRequest?.delegate = nil
        searchTableController.searchCompletionRequest?.region = mapSearchContainerView.mapView.region
        searchTableController.searchCompletionRequest?.delegate = self
    }
    
    // MARK: - Search Map Item
    // TODO: Function too coupled with map gestures, create two functions or rename.
    func searchRequestInFuture(withTimeInterval timeInterval: Double = 2.5, repeats: Bool = false, dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        searchRequestCancel()
        // We use count of 1, as we predict search results won't change.
//        if isExpanded, searchMapItems.count > 1, !searchBarText.isEmpty {
//            searchRequestFuture = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { [weak self] _ in
//                self?.searchRequestStart(dismissKeyboard: dismissKeyboard, isMapPan: isMapPan)
//            }
//        }
    }
    
    func searchRequestCancel() {
        searchCompletionRequest.cancel()
        searchRequestFuture?.invalidate()
        searchRequest?.cancel()
    }
    
    func searchRequestStart(dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        searchRequestCancel()
        
        guard let text = searchTableController.searchTableContainerView.searchBar.text, !text.isEmpty else {
            searchTableController.searchTableContainerView.searchBar.resignFirstResponder()
            searchTableController.searchMapItems.removeAll()
            searchTableController.searchTableContainerView.tableView.reloadData()
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTableController.searchTableContainerView.searchBar.text
        request.region = mapSearchContainerView.mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            self?.searchRequestDidComplete(withResponse: response, error, dismissKeyboard: dismissKeyboard, isMapPan: isMapPan)
        }
        searchTableController.searchRequest = search
    }
    
    func searchRequestDidComplete(withResponse response: MKLocalSearch.Response?, _ error: Error?, dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        guard let response = response else {
            return
        }
        searchTableController.searchMapItems = response.mapItems
        searchTableController.tableViewType = .mapItem
        if isMapPan { // Add new annotations from dragging and searching new areas.
            var newAnnotations = [PlaceAnnotation]()
            for mapItem in response.mapItems {
                if !mapAnnotations.contains(mapItem.placemark) {
                    mapAnnotations.insert(mapItem.placemark)
                    newAnnotations.append(PlaceAnnotation(mapItem))
                }
            }
            mapSearchContainerView.mapView.addAnnotations(newAnnotations)
        } else { // Remove annotations, and resize mapView to new annotations.
            //tableViewShow()
            mapAnnotations.removeAll()
            mapSearchContainerView.mapView.removeAnnotations(mapSearchContainerView.mapView.annotations)  //remove all annotations from map
            var annotations = [PlaceAnnotation]()
            for mapItem in response.mapItems {
                mapAnnotations.insert(mapItem.placemark)
                annotations.append(PlaceAnnotation(mapItem))
            }
            
            mapSearchContainerView.mapView.showAnnotations(annotations, animated: true)
        }
    }
    
    // MARK: - Geocode
    func geocodeRequestInFuture(withLocation location: CLLocation, timeInterval: Double = 0.1, repeats: Bool = false) {
//        guard mapSearchContainerView.mapView.mapBoundsDistance <= 20000 else {
//            // Less than 20KM (Street Level) otherwise don't geocode.
//            return
//        }
        geocodeRequestCancel()
        geocodeRequestFuture = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { [weak self] _ in
            guard let self = self else { return }
            self.geocodeRequest.reverseGeocodeLocation(location) { (placemarks, error) in
                // geocode comepleted
            }
        }
    }
    
    func geocodeRequestCancel() {
        geocodeRequestFuture?.invalidate()
        geocodeRequest.cancelGeocode()
    }
    
    // MARK: - Navigation
    
    @objc fileprivate func popController() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Misc.
    
    // Locates the PlaceAnnotation from an item on the map
    func findPlaceAnnotation(from mapItem: MKMapItem) -> PlaceAnnotation? {
        for annotation in mapSearchContainerView.mapView.annotations {
            if let placeAnnotation = annotation as? PlaceAnnotation {
                if placeAnnotation.mapItem == mapItem {
                    return placeAnnotation
                }
            }
        }
        return nil
    }
    
    @objc func donePressed() {
        self.mapControllerDelegate?.didUpdateSelectedLocation(with: selectedLocation)
        navigationController?.popViewController(animated: true)
    }
}


