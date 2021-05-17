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

class TabBarController: UITabBarController {
    
    var onceToken = 0
    
    override var selectedIndex: Int {
        didSet {
            CurrentTab.shared.index = selectedIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //channelsController.delegate = self
        configureTabBar()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc fileprivate func changeTheme() {
        tabBar.unselectedItemTintColor = ThemeManager.currentTheme().unselectedButtonTintColor
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().barTextColor],
        for: .normal)
    }

    func applyInitialTheme() {
        if traitCollection.userInterfaceStyle == .light {
            ThemeManager.applyTheme(theme: .normal)
        } else {
            ThemeManager.applyTheme(theme: .dark)
        }
        changeTheme()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func configureTabBar() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().barTextColor],
        for: .normal)
        tabBar.unselectedItemTintColor = ThemeManager.currentTheme().unselectedButtonTintColor
        tabBar.isTranslucent = false
        tabBar.clipsToBounds = true
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 9)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontBold(with: 9)], for: .selected)
        
        setTabs()
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
        let destination = WelcomeViewController()
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .overFullScreen
        present(newNavigationController, animated: false, completion: nil)
    }
    
    let channelsController = ChannelsController()
    let contactsController = ContactsController()
    let exploreController = ExploreController()
    let settingsController = AccountSettingsController()
    
    fileprivate func setTabs() {
        contactsController.navigationItem.title = "Contacts"
        channelsController.navigationItem.title = "Events"
        exploreController.navigationItem.title = "Explore"
        settingsController.navigationItem.title = "Account"

        let contactsNavigationController = UINavigationController(rootViewController: contactsController)
        let channelsNavigationController = UINavigationController(rootViewController: channelsController)
        let exploreNavigationController = UINavigationController(rootViewController: exploreController)
        let settingsNavigationController = UINavigationController(rootViewController: settingsController)
        settingsNavigationController.navigationBar.setValue(true, forKey: "hidesShadow")

//        if #available(iOS 11.0, *) {
//            settingsNavigationController.navigationBar.prefersLargeTitles = false
//            channelsNavigationController.navigationItem.largeTitleDisplayMode = .always
//            contactsNavigationController.navigationBar.prefersLargeTitles = false
//            createNavigationController.navigationBar.prefersLargeTitles = false
//        }

//        if #available(iOS 11.0, *) {
//            channelsNavigationController.navigationItem.largeTitleDisplayMode = .always
//            
//        }
        
        let contactsImage =  UIImage(named: "Contacts")
        let eventsImage = UIImage(named: "Calendar")
        let exploreImage = UIImage(named: "Explore")
        let settingsImage = UIImage(named: "Setting")
        
        let contactsImageSelected =  UIImage(named: "Contacts-fill")
        let eventsImageSelected = UIImage(named: "Calendar-fill")
        let exploreImageSelected = UIImage(named: "Explore-fill")
        let settingsImageSelected = UIImage(named: "Setting-fill")

        let contactsTabItem = UITabBarItem(title: contactsController.navigationItem.title, image: contactsImage, selectedImage: contactsImageSelected)
        let eventsTabItem = UITabBarItem(title: channelsController.navigationItem.title, image: eventsImage, selectedImage: eventsImageSelected)
        let exploreTabItem = UITabBarItem(title: exploreController.navigationItem.title, image: exploreImage, selectedImage: exploreImageSelected)
        let settingsTabItem = UITabBarItem(title: settingsController.navigationItem.title, image: settingsImage, selectedImage: settingsImageSelected)

        contactsController.tabBarItem = contactsTabItem
        channelsController.tabBarItem = eventsTabItem
        exploreController.tabBarItem = exploreTabItem
        settingsController.tabBarItem = settingsTabItem

        let tabBarControllers = [contactsNavigationController, channelsNavigationController, settingsNavigationController]
        viewControllers = tabBarControllers
        selectedIndex = Tabs.chats.rawValue
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        hapticFeedback(style: .selectionChanged)
    }
    
}
