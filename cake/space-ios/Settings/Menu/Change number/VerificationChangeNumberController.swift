//
//  VerificationChangeNumberController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-24.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class VerificationChangeNumberController: UIViewController {
    
    var verificationId: String?
    var newPhoneNumber: String?
    
    let verificationContainerView = VerificationContainerView()
    
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        setupView()
    }
    
    private func loadViews() {
        self.view = verificationContainerView
    }
    
    private func setupView() {
        guard let view = view as? VerificationContainerView else {
            fatalError("Root view is not VerificationContainerView")
        }
        view.codeField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        verificationContainerView.doneButton.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        
        guard let newPhoneNumber = newPhoneNumber else { return }
        
        verificationContainerView.infoLabel.text = "Verification code sent to \(newPhoneNumber)"
        
        navigationController?.isModalInPresentation = true
    }
    
    @objc fileprivate func authenticate() {
        guard let verificationID = verificationId, let currentUserID = Auth.auth().currentUser?.uid, let newPhoneNumber = newPhoneNumber else { return }
        globalIndicator.show()

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationContainerView.codeField.text!)
        
        Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
            globalIndicator.dismiss()
            if error != nil {
                print(error?.localizedDescription ?? "error")
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Error while changing number. Please try again later.", preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
                return
            }
            Firestore.firestore().collection("users").document(currentUserID).updateData(["phoneNumber": newPhoneNumber])
            UserDefaults.standard.set(self.newPhoneNumber, forKey: "userPhoneNumber")
            displayAlert(title: "Successful!", message: "Your number has been successfully changed.", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            self.dismiss(animated: true, completion: nil)
            
//            Auth.auth().currentUser?.link(with: credential, completion: { (_, error) in
//                self.verificationContainerView.ind.dismiss()
//                if error != nil {
//                    print(error?.localizedDescription ?? "error")
//                    displayErrorAlert(title: basicErrorTitleForAlert, message: "The verification code you entered is invalid.", preferredStyle: UIAlertController.Style.alert, actionTitle: "Dismiss", controller: self)
//                    return
//                }
//                displayAlert(title: "Successful!", message: "Your number has been successfully changed.", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
//                self.dismiss(animated: true, completion: nil)
//            })
            
        })
        
    }
    
    fileprivate func setupNavigationbar() {
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        cancelButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = cancelButtonItem
        self.navigationItem.hidesBackButton = true
    }
    
    @objc fileprivate func popController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange() {
        if verificationContainerView.codeField.text!.count >= 6 {
            verificationContainerView.codeField.resignFirstResponder()
            authenticate()
        } else {
            verificationContainerView.doneButton.isEnabled = true
        }
    }
    
}

extension VerificationChangeNumberController  {
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        verificationContainerView.doneButtonConstraint.constant =  -keyboardHeight
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        verificationContainerView.doneButtonConstraint.constant = -10
    }
}
