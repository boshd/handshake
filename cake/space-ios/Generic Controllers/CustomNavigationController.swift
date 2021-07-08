//
//  CustomNavigationController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-27.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

final class CustomNavigationController: UINavigationController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }
}
