//
//  ParticipantProfileController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-29.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ParticipantProfileController: UIViewController {
    
    let userProfileContainerView = UserProfileContainerView()
    let avatarOpener = AvatarOpener()
    
    var member: User?
    
    // MARK: - Controller life-cycle
    
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        configure()
        setupNavigationBar()
    }
    
    // MARK: - Controller configuration
    
    fileprivate func loadViews() {
        view = userProfileContainerView
        view.frame = userProfileContainerView.bounds
    }
    
    fileprivate func configure() {
        userProfileContainerView.name.isUserInteractionEnabled = false
        userProfileContainerView.phone.isUserInteractionEnabled = false
        userProfileContainerView.name.textColor = ThemeManager.currentTheme().generalSubtitleColor
        userProfileContainerView.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUserProfilePicture)))
        
        guard let member = member else { return }
        
        if let imageURL = member.userImageUrl {
            self.userProfileContainerView.profileImageView.showActivityIndicator()
            self.userProfileContainerView.profileImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil, options: [.scaleDownLargeImages, .continueInBackground], completed: { [weak self] (image, error, _, _) in
                self?.userProfileContainerView.profileImageView.hideActivityIndicator()
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
            })
        } else {
            self.userProfileContainerView.profileImageView.image = UIImage(named: "UserpicIcon")
        }
        
        if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == member.id }),
           let name = realmUser.localName {
            self.userProfileContainerView.name.text = name
        } else {
            if let name = member.name {
                self.userProfileContainerView.name.text = name
            }
        }
        
        if let phone = member.phoneNumber {
            self.userProfileContainerView.phone.text = phone
        }
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "Profile"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action:  #selector(goBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    @objc fileprivate func openUserProfilePicture() {
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        avatarOpener.handleAvatarOpening(avatarView: userProfileContainerView.profileImageView, at: self, isEditButtonEnabled: false, title: .user)
    }
    
    @objc fileprivate func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
}
