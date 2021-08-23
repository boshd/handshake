//
//  VerificationController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-08.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit

class VerificationController: UIViewController {
    
    var verificationID: String?
    
    let verificationContainerView = VerificationContainerView()
    let userExistenceChecker = UserExistenceChecker()
    let userCreatingGroup = DispatchGroup()
    
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        setupView()
        addObservers()
    }
    
    private func loadViews() {
        self.view = verificationContainerView
    }
    
    private func setupView() {
        guard let view = view as? VerificationContainerView else {
            fatalError("Root view is not VerificationContainerView")
        }
        view.codeField.becomeFirstResponder()
//        verificationContainerView.doneButton.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        
        guard let phoneNumber =  UserDefaults.standard.string(forKey: "userPhoneNumber") else { return }
        
        verificationContainerView.infoLabel.text = "Verification code sent to \(phoneNumber)"
    }
    
    
    // responsible for changing theme based on system theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme))
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) &&
            userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            if traitCollection.userInterfaceStyle == .light {
                ThemeManager.applyTheme(theme: .normal)
            } else {
                ThemeManager.applyTheme(theme: .dark)
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        verificationContainerView.setColors()
    }
    
    fileprivate func setupNavigationbar() {
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(goBack))
        cancelButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = cancelButtonItem
        
        self.navigationItem.hidesBackButton = true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        
//        verificationContainerView.doneButtonConstraint.constant =  -keyboardHeight
    }

    @objc func keyboardWillHide(_ notification: Notification) {
//        verificationContainerView.doneButtonConstraint.constant = -10
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange() {
        if verificationContainerView.codeField.text!.count > 5 {
            //verificationContainerView.codeField.resignFirstResponder()
            authenticate()
        } else {
//            verificationContainerView.doneButton.isEnabled = true
        }
    }
    
    @objc func authenticate() {
        globalIndicator.show()
        
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationContainerView.codeField.text!)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                print(authError.localizedDescription)
                globalIndicator.dismiss()

                hapticFeedbackRegular(style: .medium)
                displayErrorAlert(title: basicErrorTitleForAlert, message: "The verification code you entered is invalid.", preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
                
                self.verificationContainerView.codeField.becomeFirstResponder()

                return
            }
            NotificationCenter.default.post(name: .authenticationSucceeded, object: nil)
            
            self.userExistenceChecker.delegate = self
            self.userExistenceChecker.checkIfUserDataExists()
        }

    }
    
    func createUserNode(reference: DocumentReference, childValues: [String: Any], noImagesToUpload: Bool) {
        let nodeCreationGroup = DispatchGroup()
        nodeCreationGroup.enter()
        nodeCreationGroup.notify(queue: DispatchQueue.main, execute: {
            self.userCreatingGroup.leave()
        })
        reference.setData(childValues) { (_) in
            nodeCreationGroup.leave()
        }
    }
    
    fileprivate func registerFcmToken() {
        if let currentUserID = Auth.auth().currentUser?.uid, let token = Messaging.messaging().fcmToken {
            userDefaults.updateObject(for: userDefaults.fcmToken, with: token)
            let fcmTokensCurrentUserReference = Firestore.firestore().collection("fcmTokens").document(currentUserID)
            let batch = Firestore.firestore().batch()
            batch.setData(["fcmToken":token], forDocument: fcmTokensCurrentUserReference, merge: true)
            batch.commit { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    return
                }
            }
        }
    }
}

extension VerificationController: UserExistenceDelegate {
    func user(userExists: Bool, channelIds: [String]?) {
        registerFcmToken()
        if userExists { 
            hapticFeedbackRegular(style: .medium)
            globalIndicator.dismiss()
            self.dismiss(animated: true, completion: nil)
        } else {
            // onboard and create user
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }
            setOnlineStatus()
            
            /*
             
             if Messaging.messaging().fcmToken != nil {
                 setUserNotificationToken(token: Messaging.messaging().fcmToken!)
             }
             
             */
            
            let userReferenceReference = Firestore.firestore().collection("users").document(currentUserID)
            let childValues = [
                "id": currentUserID,
                "name": "",
                "bio": "",
                "phoneNumber": UserDefaults.standard.string(forKey: "userPhoneNumber") ?? ""
            ] as [String : Any]
            self.userCreatingGroup.enter()
            self.createUserNode(reference: userReferenceReference, childValues: childValues, noImagesToUpload: true)
            self.userCreatingGroup.notify(queue: .main) { [weak self] in
//                self?.registerFcmToken()
                hapticFeedbackRegular(style: .medium)
                globalIndicator.dismiss()
                guard self?.navigationController != nil else { return }
                let destination = PhotoController()
                self?.navigationController?.pushViewController(destination, animated: true)
            }
        }
    }
    
    func error() {
        globalIndicator.dismiss()
        displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
    }

}

