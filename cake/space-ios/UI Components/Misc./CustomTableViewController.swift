//
//  CustomTableViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class CustomTableViewController: UITableViewController {
    fileprivate let customNavigationItem = NavigationItem()
    override func viewDidLoad() {
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }

    override var navigationItem: NavigationItem {
        return customNavigationItem
    }
}
