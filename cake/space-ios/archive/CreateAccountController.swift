//
//  CreateAccountController.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-06.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountController: UIViewController, UITextFieldDelegate {
    
    var window: UIWindow?
    let createAccountContainerView = CreateAccountContainerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(createAccountContainerView)
        createAccountContainerView.frame = view.bounds
        subscribeToShowKeyboardNotifications()
        setupController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createAccountContainerView.nameField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        createAccountContainerView.nameField.endEditing(true)
//        createAccountContainerView.emailField.endEditing(true)
//        createAccountContainerView.passwordField.endEditing(true)
    }
    
    @objc func signup() {
        disableNextButton()
        
        guard let name = createAccountContainerView.nameField.text else { return }
        guard let email = createAccountContainerView.emailField.text else { return }
        guard let password = createAccountContainerView.passwordField.text else { return }
        
        switch true {
        case EmailValidator.invalidEmail(createAccountContainerView.emailField.text!):
            disableNextButton()
            createAccountContainerView.errorLabel.text = "Invalid Email."
        case NameValidator.invalidCharactersIn(name: createAccountContainerView.nameField.text!):
            disableNextButton()
            createAccountContainerView.errorLabel.text = "Invalid character(s) in name."
        case PasswordValidator.passwordInvalidLength(createAccountContainerView.passwordField.text!):
            disableNextButton()
            createAccountContainerView.errorLabel.text = "Invalid password length."
        case PasswordValidator.passwordTooWeak(createAccountContainerView.passwordField.text!):
            disableNextButton()
            createAccountContainerView.errorLabel.text = "Password too weak."
        default:
            disableNextButton()
            createAccountContainerView.nextButton.showLoading()
            createAccountContainerView.emailField.checkEmail(field: createAccountContainerView.emailField.text!) { (success) in
                if success == true {
                    self.createAccountContainerView.errorLabel.text = "Email already exists."
                    self.createAccountContainerView.nextButton.hideLoading()
                    self.disableNextButton()
                } else {
                    self.createAccountContainerView.nextButton.hideLoading()
                    self.enableNextButton()
                    // move on
                    
                    UserDefaults.standard.set(name, forKey: "name")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(password, forKey: "password")
                    
                    let destination = PhotoController()
                    self.navigationController?.pushViewController(destination, animated: true)
                }
            }
            
        }
    }
    
    @objc func nameChanged() {
        disableNextButton()
        switch true {
        case NameValidator.invalidCharactersIn(name: createAccountContainerView.nameField.text!):
            disableNextButton()
            createAccountContainerView.errorLabel.text = "Invalid character(s) in name."
        default:
            if createAccountContainerView.emailField.text != "" && createAccountContainerView.passwordField
                .text != "" {
                enableNextButton()
            }
            createAccountContainerView.errorLabel.text = ""
        }
    }
    
    @objc func emailChanged() {
        disableNextButton()
        createAccountContainerView.errorLabel.text = ""
        if createAccountContainerView.emailField.text != "" {
            switch true {
            case EmailValidator.invalidEmail(createAccountContainerView.emailField.text!):
                disableNextButton()
                createAccountContainerView.errorLabel.text = "Invalid Email."
            default:
                disableNextButton()
                createAccountContainerView.nextButton.showLoading()
                createAccountContainerView.emailField.checkEmail(field: createAccountContainerView.emailField.text!) { (success) in
                    if success == true {
                        self.createAccountContainerView.errorLabel.text = "Email already exists."
                        self.createAccountContainerView.nextButton.hideLoading()
                        self.disableNextButton()
                    } else {
                        self.createAccountContainerView.nextButton.hideLoading()
                        if self.createAccountContainerView.nameField.text != "" && self.createAccountContainerView.passwordField.text != ""{
                            self.enableNextButton()
                            self.createAccountContainerView.errorLabel.text = ""
                        }
                    }
                }
            }
        }
    }
    
    @objc func passwordChanged() {
        disableNextButton()
        switch true {
        case PasswordValidator.passwordInvalidLength(createAccountContainerView.passwordField.text!):
            disableNextButton()
            createAccountContainerView.errorLabel.text = "Invalid password length."
        case PasswordValidator.passwordTooWeak(createAccountContainerView.passwordField.text!):
            disableNextButton()
            createAccountContainerView.errorLabel.text = "Password too weak."
        default:
            if createAccountContainerView.nameField.text != "" && createAccountContainerView.emailField.text != "" {
                enableNextButton()
            }
            createAccountContainerView.errorLabel.text = ""
            createAccountContainerView.nextButton.isEnabled = true
        }
    }
    
    func enableNextButton() {
        createAccountContainerView.nextButton.isEnabled = true
        createAccountContainerView.nextButton.backgroundColor = UIColor.black
        createAccountContainerView.nextButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func disableNextButton() {
        createAccountContainerView.nextButton.isEnabled = false
        createAccountContainerView.nextButton.backgroundColor = UIColor.gray
        createAccountContainerView.nextButton.setTitleColor(UIColor.offWhite(), for: .normal)
    }
    
    fileprivate func setupController() {
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        /*** If needed Assign Title Here ***/
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = .black
        
        createAccountContainerView.nextButton.isEnabled = false
        createAccountContainerView.errorLabel.text = ""
        disableNextButton()
        createAccountContainerView.nameField.tag = 0
        createAccountContainerView.emailField.tag = 1
        createAccountContainerView.passwordField.tag = 2
        
//        self.hideKeyboardWhenTappedAround()
        createAccountContainerView.nameField.delegate = self
        createAccountContainerView.emailField.delegate = self
        createAccountContainerView.passwordField.delegate = self
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        createAccountContainerView.nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        createAccountContainerView.emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        createAccountContainerView.passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
//            textField.resignFirstResponder()
            self.createAccountContainerView.nextButton.hideLoading()
            signup()
        }
        return false
    }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        createAccountContainerView.buttonConstraint.constant = -15 - keyboardHeight
        
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        createAccountContainerView.buttonConstraint.constant = -15
        
        let userInfo = notification.userInfo
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}
