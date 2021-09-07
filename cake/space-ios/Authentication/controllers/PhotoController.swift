 //
//  PhotoController.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-09.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class PhotoController: UIViewController {
    
    var selectedImage: UIImage?
    var window: UIWindow?
    
    let uploadPhotoGroup = DispatchGroup()
    
    let photoContainerView = PhotoContainerView()
    let avatarOpener = AvatarOpener()
    let userProfileDataDatabaseUpdater = UserProfileDataDatabaseUpdater()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    fileprivate func setupController() {
        view.addSubview(photoContainerView)
        photoContainerView.frame = view.bounds
        
        hideKeyboardWhenTappedAround()
        
        title = "Your profile"
        
        let next = UIBarButtonItem(title: "Finish up", style: .plain, target: self, action: #selector(nextPressed))
        next.setTitleTextAttributes([NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontBold(with: 14)], for: .normal)
        next.tintColor = ThemeManager.currentTheme().tintColor
        navigationItem.rightBarButtonItem = next
        
        navigationItem.hidesBackButton = true
        
        photoContainerView.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUserProfilePicture)))
    }
    
    @objc func nextPressed() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        guard let name = photoContainerView.nameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            displayErrorAlert(title: "Oops", message: "Please enter your name", preferredStyle: .alert, actionTitle: "Got it", controller: self)
            return
        }
        
        let userReference = Firestore.firestore().collection("users").document(currentUserID)
        
        self.uploadPhotoGroup.enter()
        self.uploadPhotoGroup.enter()
        self.uploadUserImage(channelImage: self.selectedImage, reference: userReference)
        self.updateName(name: name.trimmingCharacters(in: .whitespaces), reference: userReference)
        globalIndicator.show()
        
        self.uploadPhotoGroup.notify(queue: .main) {
            globalIndicator.dismiss()
            hapticFeedback(style: .success)
            
            userDefaults.updateObject(for: userDefaults.currentUserName, with: name)
            hapticFeedbackRegular(style: .medium)
            self.dismiss(animated: true) {
//                if let channelsController = channelsController {
//                    //channelsController.showConfetti()
//                }
            }
//            let channelsController = ChannelsController()
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            self.window?.makeKeyAndVisible()
//            self.window?.rootViewController = channelsController
//            self.window?.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//            channelsController.presentOnboardingController()
        }
    }
    
    @objc fileprivate func openUserProfilePicture() {
        photoContainerView.nameField.resignFirstResponder()
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        avatarOpener.delegate = self
        avatarOpener.handleAvatarOpening(avatarView: photoContainerView.imageView, at: self, isEditButtonEnabled: true, title: .user)
    }
    
    func updateName(name: String, reference: DocumentReference) {
        reference.updateData(["name": name]) { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.uploadPhotoGroup.leave()
                return
            }
            self.uploadPhotoGroup.leave()
        }
    }
    
    func uploadUserImage(channelImage: UIImage?, reference: DocumentReference) {
        guard let image = channelImage else { self.uploadPhotoGroup.leave(); return }
        let thumbnailImage = createImageThumbnail(image)
        var images = [(image: UIImage, quality: CGFloat, key: String)]()
        let compressedImageData = compressImage(image: image)
        let compressedImage = UIImage(data: compressedImageData)
        images.append((image: compressedImage!, quality: 0.5, key: "userImageUrl"))
        images.append((image: thumbnailImage, quality: 1, key: "userThumbnailImageUrl"))
        let imageUpdatingGroup = DispatchGroup()
        for _ in images { imageUpdatingGroup.enter() }
        imageUpdatingGroup.notify(queue: DispatchQueue.main) {
            self.uploadPhotoGroup.leave()
        }
        
        for imageElement in images {
            uploadImageForChannelToFirebaseStorageUsingImage(imageElement.image, quality: imageElement.quality) { (url) in
                reference.updateData([imageElement.key : url]) { (error) in
                    if error != nil {
                        print(error?.localizedDescription ?? "")
                    }
                    imageUpdatingGroup.leave()
                }
            }
        }
    }
    
}
