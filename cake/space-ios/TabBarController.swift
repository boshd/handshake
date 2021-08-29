//
//  TabBarController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-12.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import LocalAuthentication

enum Tabs: Int {
  case contacts = 0
  case chats = 1
  case settings = 2
}

class CurrentTab {
    static let shared = CurrentTab()
    var index = 0
}

class FrostyTabBar: UITabBar {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        frost.frame = bounds
        frost.autoresizingMask = .flexibleWidth
        insertSubview(frost, at: 0)
    }
}

class TabBarController: UITabBarController {
    
    var onceToken = 0
    let frost = UIVisualEffectView(effect: ThemeManager.currentTheme().tabBarBlurEffect)
    
    override var selectedIndex: Int {
        didSet {
            CurrentTab.shared.index = selectedIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //channelsController.delegate = self
        configureTabBar()
        setOnlineStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc fileprivate func changeTheme() {
        tabBar.unselectedItemTintColor = ThemeManager.currentTheme().unselectedButtonTintColor
        // tabBar.selectedImageTintColor = ThemeManager.currentTheme().selectedButtonTintColor // deprecated
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().barTextColor],
        for: .normal)
        tabBar.unselectedItemTintColor = ThemeManager.currentTheme().unselectedButtonTintColor
        tabBar.tintColor = ThemeManager.currentTheme().selectedButtonTintColor
        tabBar.barTintColor = ThemeManager.currentTheme().barBackgroundColor
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().selectedButtonTintColor], for: .selected)
    }

    func applyTheme() {
        if traitCollection.userInterfaceStyle == .light {
            ThemeManager.applyTheme(theme: .normal)
        } else {
            ThemeManager.applyTheme(theme: .dark)
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func configureTabBar() {
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().barTextColor],
        for: .normal)
        tabBar.unselectedItemTintColor = ThemeManager.currentTheme().unselectedButtonTintColor
        tabBar.tintColor = ThemeManager.currentTheme().selectedButtonTintColor
        tabBar.isTranslucent = false
        tabBar.clipsToBounds = true
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().selectedButtonTintColor], for: .selected)
        setTabs()
    }
    
    fileprivate func setTranslucency() {
//        frost.frame = tabBar.bounds
//        tabBar.backgroundColor = .black.withAlphaComponent(0.05)
//        tabBar.insertSubview(frost, at: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard onceToken == 0 else { onceToken = 1; return }
        onceToken = 1
    }
    
    func presentOnboardingController() {
        guard Auth.auth().currentUser == nil else {
            return
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        let destination = WelcomeViewController()
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .overFullScreen
        present(newNavigationController, animated: false, completion: nil)
    }
    
    let channelsController = ChannelsController()
    let contactsController = ContactsController(style: .insetGrouped)
    let exploreController = ExploreController()
    let settingsController = AccountSettingsController()
    
    fileprivate func setTabs() {
        contactsController.navigationItem.title = "CONTACTS"
        channelsController.navigationItem.title = "EVENTS"
        exploreController.navigationItem.title = "Explore"
        settingsController.navigationItem.title = "ACCOUNT"

        let contactsNavigationController = CustomNavigationController(rootViewController: contactsController)
        let channelsNavigationController = CustomNavigationController(rootViewController: channelsController)
        let settingsNavigationController = CustomNavigationController(rootViewController: settingsController)
        settingsNavigationController.navigationBar.setValue(true, forKey: "hidesShadow")

        let contactsImage =  UIImage(named: "Contacts")
        let eventsImage = UIImage(named: "Explore")
        let settingsImage = UIImage(named: "Setting")
        
        let contactsImageSelected =  UIImage(named: "Contacts-fill")
        let eventsImageSelected = UIImage(named: "Explore-fill")
        let settingsImageSelected = UIImage(named: "Setting-fill")

        let contactsTabItem = UITabBarItem(title: contactsController.navigationItem.title, image: contactsImage, selectedImage: contactsImageSelected)
        let eventsTabItem = UITabBarItem(title: channelsController.navigationItem.title, image: eventsImage, selectedImage: eventsImageSelected)
        let settingsTabItem = UITabBarItem(title: settingsController.navigationItem.title, image: settingsImage, selectedImage: settingsImageSelected)

        contactsController.tabBarItem = contactsTabItem
        channelsController.tabBarItem = eventsTabItem
        settingsController.tabBarItem = settingsTabItem
        
        contactsTabItem.setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 8)] as [NSAttributedString.Key : Any], for: .normal)
        contactsTabItem.setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 8)] as [NSAttributedString.Key : Any], for: .selected)
        eventsTabItem.setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 8)] as [NSAttributedString.Key : Any], for: .normal)
        eventsTabItem.setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 8)] as [NSAttributedString.Key : Any], for: .selected)
        settingsTabItem.setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 8)] as [NSAttributedString.Key : Any], for: .normal)
        settingsTabItem.setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 8)] as [NSAttributedString.Key : Any], for: .selected)

        let tabBarControllers = [contactsNavigationController, channelsNavigationController, settingsNavigationController]
        viewControllers = tabBarControllers
        selectedIndex = Tabs.chats.rawValue
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        hapticFeedback(style: .selectionChanged)
    }
    
}
