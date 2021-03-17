//
//  CustomNavigationItem.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-15.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

enum UINavigationItemTitle: String {
    case nothing = ""
    case noInternet = "Waiting for network"
    case updating = "Updating..."
    case connecting = "Connecting..."
    case updatingUsers = "Syncing Users..."
}

class NavigationItem: UINavigationItem {

    fileprivate var navigationItemActivityTitleView: ActivityTitleView?

    fileprivate var isActive = false

    override var titleView: UIView? {
        didSet {
            if titleView == nil {
                isActive = false
            } else {
                isActive = true
            }
        }
    }

//    func showActivityView(with title: UINavigationItemTitle) {
//        let isConnectedToInternet = navigationItemActivityTitleView?.titleLabel.text != UINavigationItemTitle.noInternet.rawValue
//
//        if title == UINavigationItemTitle.noInternet {
//            return
//        }
//
//    }
//
//    func hideActivityView(with title: UINavigationItemTitle) {
//        if navigationItemActivityTitleView?.titleLabel.text == title.rawValue {
//            titleView = nil
//            navigationItemActivityTitleView = nil
//        }
//    }
    
    func showActivityView(with title: UINavigationItemTitle) {
        let isConnectedToInternet = navigationItemActivityTitleView?.titleLabel.text != UINavigationItemTitle.noInternet.rawValue

        if title == UINavigationItemTitle.noInternet {
            navigationItemActivityTitleView = ActivityTitleView()
            titleView = navigationItemActivityTitleView
            return
        }

        guard isConnectedToInternet, !isActive else { return }
        navigationItemActivityTitleView = ActivityTitleView()
        titleView = navigationItemActivityTitleView
    }

    func hideActivityView(with title: UINavigationItemTitle) {
        if navigationItemActivityTitleView?.titleLabel.text == title.rawValue {
            titleView = nil
            navigationItemActivityTitleView = nil
        }
    }
}
