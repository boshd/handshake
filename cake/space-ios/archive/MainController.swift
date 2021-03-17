//
//  MainController.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-21.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

protocol CreateButtonDelegate {
    func show()
    func hide()
}

class MainController: UIViewController, CreateButtonDelegate {
    
    fileprivate var currentUserFetched = false
    var currentUser: User?
    
    var onceToken = 0
    
    let mainView: UIView = {
        let mainView = UIView(frame: .zero)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.backgroundColor = .white
        
        return mainView
    }()
    
    let tabBar: BlurView = {
        let tabBar = BlurView(frame: .zero)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        return tabBar
    }()
    
    let createButton: UIButton = {
        let createButton = UIButton(type: .custom)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        createButton.layer.shadowRadius = 20
        createButton.layer.shadowOpacity = 0.6
        createButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        createButton.addTarget(self, action: #selector(presentCreateChannelController), for: .touchUpInside)
        createButton.setImage(UIImage(named: "add")?.withRenderingMode(.alwaysTemplate), for: .normal)
        createButton.tintColor = ThemeManager.currentTheme().buttonIconColor
        createButton.imageView?.contentMode = .scaleAspectFit
        return createButton
    }()
    
    let contactsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        button.layer.shadowRadius = 20
        button.layer.shadowOpacity = 0.6
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.addTarget(self, action: #selector(presentContactsController), for: .touchUpInside)
        button.setImage(UIImage(named: "add-people")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = ThemeManager.currentTheme().buttonIconColor
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    let channelsController = ChannelsController()
    
    var controllers: [UINavigationController]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let channelsNavigationController = UINavigationController(rootViewController: channelsController)
        channelsNavigationController.isNavigationBarHidden = true
        
        controllers = [channelsNavigationController]
        addObservers()
        setupController()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        createButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        contactsButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        createButton.tintColor = ThemeManager.currentTheme().buttonIconColor
        contactsButton.tintColor = ThemeManager.currentTheme().buttonIconColor
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.isHidden = false
        createButton.isHidden = false
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBar.isHidden = true
        createButton.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        createButton.isHidden = true
    }
    
    @objc func initializeDataSource() {}
    
    fileprivate func setupController() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        view.addSubview(mainView)

        view.addSubview(createButton)
        view.addSubview(contactsButton)
        view.bringSubviewToFront(createButton)
        view.bringSubviewToFront(contactsButton)

        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            mainView.topAnchor.constraint(equalTo: view.topAnchor),

            contactsButton.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -10),
            contactsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactsButton.heightAnchor.constraint(equalToConstant: 50),
            contactsButton.widthAnchor.constraint(equalToConstant: 50),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        // channelsController.delegate = self
        
        let vc = controllers[0]
        addChild(vc)
        vc.view.frame = mainView.bounds
        mainView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func presentOnboardingController() {
        guard Auth.auth().currentUser == nil else {
            initializeDataSource()
            return
        }
        let destination = WelcomeViewController()
        destination.modalPresentationStyle = .fullScreen
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.navigationBar.shadowImage = UIImage()
        newNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        newNavigationController.modalPresentationStyle = .fullScreen
        present(newNavigationController, animated: false, completion: nil)
    }
    
    var i = 0
    
    @objc func presentCreateChannelController() {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        } else {
            hapticFeedback(style: .impact)
        }

        let destination = SelectChannelParticipantsController()
        // remove blocked users
        let users = RealmKeychain.realmUsersArray()
        destination.users = users
        destination.filteredUsers = users
        destination.setUpCollation()

        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .formSheet
        newNavigationController.navigationBar.isHidden = false
        present(newNavigationController, animated: true, completion: nil)
    }
    
    @objc func presentContactsController() {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        hapticFeedback(style: .impact)
        
        let destination = ContactsController()
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .formSheet
        present(newNavigationController, animated: true, completion: nil)
    }
    
    func show() {
        tabBar.isHidden = false
        createButton.isHidden = false
        contactsButton.isHidden = false
    }
    
    func hide() {
        tabBar.isHidden = true
        createButton.isHidden = true
        contactsButton.isHidden = true
    }
    
}

//extension MainController: ManageAppearance {
//    func manageAppearance(_ chatsController: ChannelsTableViewController, didFinishLoadingWith state: Bool) {
//        _ = userDefaults.currentBoolObjectState(for: userDefaults.biometricalAuth)
//        _ = channelsController.view
//        guard state else { return }
//    }
//}
