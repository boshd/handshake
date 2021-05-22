//
//  SearchTableController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import FloatingPanel
import MapKit

//protocol SearchTableDelegate: class {
//    func clickSearchButton(searchBar: UISearchBar)
//    func didSelectMapItem(mapItem: MKMapItem)
//}

class SearchTableController: UIViewController {
    
    var delegate: LocationSearchDelegate?
    
    var searchTableContainerView = SearchTableContainerView()
    let viewPlaceholder = ViewPlaceholder()
    
    let mapSearchCompletionCellId = "mapSearchCompletionCellId"
    let mapItemSearchCellId = "mapItemSearchCellId"
    
    var mapController: MapController!
    
    // MARK: - Search Variables
    var searchCompletionRequest: MKLocalSearchCompleter? = MKLocalSearchCompleter()
    var searchCompletions = [MKLocalSearchCompletion]()
    
    var searchRequestFuture: Timer?
    var searchRequest: MKLocalSearch?
    var searchMapItems = [MKMapItem]()
    
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
    
    // MARK: - Controller Life-Cycle
    
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // responsible for changing theme based on system theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme))
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) &&
            userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            if traitCollection.userInterfaceStyle == .light {
                ThemeManager.applyTheme(theme: .normal)
            } else {
                ThemeManager.applyTheme(theme: .dark)
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        searchTableContainerView.tableView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        searchTableContainerView.setColors()
        DispatchQueue.main.async { [weak self] in
            self?.searchTableContainerView.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTableContainerView.searchBar.becomeFirstResponder()
    }
    
    // MARK: - Controller setup and configuration
    
    fileprivate func loadViews() {
        view = searchTableContainerView
    }
    
    fileprivate func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
        mapController = self.presentingViewController as? MapController
        
//        searchTableContainerView.tableView.delegate = self
//        searchTableContainerView.tableView.dataSource = self
        
        searchTableContainerView.tableView.register(MapSearchCompletionCell.self, forCellReuseIdentifier: mapSearchCompletionCellId)
        searchTableContainerView.tableView.register(MapItemSearchCell.self, forCellReuseIdentifier: mapItemSearchCellId)
        
        if searchMapItems.count == 0 {
            tablePopulated(isEmpty: true)
        } else {
            tablePopulated(isEmpty: false)
        }
    }
    
    func tablePopulated(isEmpty: Bool) {
        guard isEmpty else {
            viewPlaceholder.remove(from: view, priority: .medium)
            return
        }
        viewPlaceholder.add(for: view, title: .searchForLocation, subtitle: .empty, priority: .medium, position: .top)
    }
}
