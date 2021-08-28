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
    
    
//    init() {
//        super.init()
//        let bounds = navigationBar.bounds
//        let visualEffectView = UIVisualEffectView(effect: ThemeManager.currentTheme().tabBarBlurEffect)
//        visualEffectView.frame = bounds ?? CGRect.zero
//        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        navigationBar.addSubview(visualEffectView)
//
//        // Here you can add visual effects to any UIView control.
//        // Replace custom view with navigation bar in the above code to add effects to the custom view.
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
}
