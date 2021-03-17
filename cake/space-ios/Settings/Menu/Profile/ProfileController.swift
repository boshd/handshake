//
//  ProfileController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-22.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class ProfileController: UIViewController {
    
    let userProfileContainerView = UserProfileContainerView()
    let settingsFooterContainerView = SettingsFooterContainerView()
    let avatarOpener = AvatarOpener()
    let userProfileDataDatabaseUpdater = UserProfileDataDatabaseUpdater()
    
    var currentName = String()
    var currentBio = String()
    
    var currentUserListener: ListenerRegistration?
    var currentUserReference: DocumentReference?
    
    let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonPressed))
    let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action:  #selector(doneBarButtonPressed))
    let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
    
    override func loadView() {
        super.loadView()
        view = userProfileContainerView
        view.frame = userProfileContainerView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        configureController()
        setupNavigationbar()
        configureContainerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userProfileContainerView.phone.text == "" {
            configureCurrentUser()
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(configureCurrentUser), name: .currentUserDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        userProfileContainerView.addPhotoLabel.textColor = ThemeManager.currentTheme().tintColor
        userProfileContainerView.backgroundColor = view.backgroundColor
        userProfileContainerView.profileImageView.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
        userProfileContainerView.userData.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
        userProfileContainerView.name.textColor = ThemeManager.currentTheme().generalTitleColor
        userProfileContainerView.name.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        settingsFooterContainerView.backgroundColor = view.backgroundColor
    }
    
    fileprivate func configureController() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        currentUserReference = Firestore.firestore().collection("users").document(currentUserID)
    }
    
    fileprivate func setupNavigationbar() {
        title = "Profile"
        
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        navigationItem.leftBarButtonItem = backButton
    }
    
    fileprivate func configureContainerView() {
        userProfileContainerView.profileImageView.isUserInteractionEnabled = true
        userProfileContainerView.name.addTarget(self, action: #selector(nameDidBeginEditing), for: .editingDidBegin)
        userProfileContainerView.name.addTarget(self, action: #selector(nameEditingChanged), for: .editingChanged)
        userProfileContainerView.closeButton.addTarget(self, action: #selector(popController), for: .touchUpInside)
        userProfileContainerView.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUserProfilePicture)))
        userProfileContainerView.name.delegate = self
    }
    
    @objc func clearUserData() {
        userProfileContainerView.name.text = ""
        userProfileContainerView.phone.text = ""
        userProfileContainerView.profileImageView.image = nil
    }
    
    @objc func configureCurrentUser() {
        guard let user = globalCurrentUser else { return }
        
        if let imageURL = user.userImageUrl {
            self.userProfileContainerView.profileImageView.showActivityIndicator()
            self.userProfileContainerView.profileImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil, options: [.scaleDownLargeImages, .continueInBackground], completed: { [weak self] (image, error, _, _) in
                self?.userProfileContainerView.profileImageView.hideActivityIndicator()
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
            })
        }
        
        if let name = user.name {
            self.userProfileContainerView.name.text = name
            self.currentName = name
        }
        
        if let phone = user.phoneNumber {
            self.userProfileContainerView.phone.text = phone
        }
    }
    
    @objc fileprivate func openUserProfilePicture() {
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        avatarOpener.delegate = self
        avatarOpener.handleAvatarOpening(avatarView: userProfileContainerView.profileImageView, at: self, isEditButtonEnabled: true, title: .user)
        cancelBarButtonPressed()
    }
    
    @objc func popController() {
        navigationController?.popViewController(animated: true)
    }
    
}
