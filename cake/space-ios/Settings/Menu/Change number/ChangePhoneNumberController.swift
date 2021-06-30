//
//  ChangePhoneNumberController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-24.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit

class ChangePhoneNumberController: UIViewController {
    
    let phoneContainerView = PhoneContainerView()
    let phoneNumberKit = PhoneNumberKit()
    
    var usersReference: CollectionReference?
  
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupContainerView()
        navigationController?.isNavigationBarHidden = false
    }
    
    private func loadViews() {
        self.view = phoneContainerView
    }
    
    private func setupContainerView() {
        guard let view = view as? PhoneContainerView else {
            fatalError("Root view is not PhoneController")
        }
        view.phoneNumberField.becomeFirstResponder()
        phoneContainerView.phoneNumberField.addTarget(self, action: #selector(phoneNumberChanged), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // change content
        phoneContainerView.titleLabel.text = "Enter your new number"
        phoneContainerView.infoLabel.text = "Please enter your new number to initiate the account migration. Message and data rates may apply."
        
        phoneContainerView.doneButton.addTarget(self, action: #selector(next_), for: .touchUpInside)
        
        usersReference = Firestore.firestore().collection("users")
    }
    
    @objc private func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        phoneContainerView.setColors()
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationBar)
        }
    }
    
    @objc fileprivate func next_() {
        guard Auth.auth().currentUser != nil, let newPhoneNumber = fetchPhoneNumber(), usersReference != nil, let currentPhoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") else { return }
        
        globalIndicator.show()
        
        guard currentPhoneNumber != newPhoneNumber else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: "This is your current phone number.", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            globalIndicator.dismiss()
            return
        }
    
        checkIfPhoneNumberAlreayExists(field: newPhoneNumber) { [weak self] (exists) in
            guard let unwrappedSelf = self else { globalIndicator.dismiss(); return }
            switch exists {
            case true:
                globalIndicator.dismiss()
                displayErrorAlert(title: basicErrorTitleForAlert, message: "This phone number already has an account associated with it.", preferredStyle: .alert, actionTitle: basicActionTitle, controller: unwrappedSelf)
                return
            case false:
                PhoneAuthProvider.provider().verifyPhoneNumber(newPhoneNumber, uiDelegate: nil) { (verificationID, error) in
                    globalIndicator.dismiss()
                    if error != nil {
                        print(error?.localizedDescription ?? "error")
                        return
                    }
                    guard let verificationID = verificationID else { return }
                    let destination = VerificationChangeNumberController()
                    destination.verificationId = verificationID
                    destination.newPhoneNumber = newPhoneNumber
                    unwrappedSelf.navigationController?.pushViewController(destination, animated: true)
                }
            }
        }
        
        
//        PhoneAuthProvider.provider().verifyPhoneNumber(newPhoneNumber, uiDelegate: nil) { (verificationID, error) in
//            if error != nil {
//                print(error?.localizedDescription ?? "error")
//                return
//            }
//            
//            guard let verificationID = verificationID else { return }
//            
//            
//        }
        
    }
    
    func verify() {
        
    }
    
//    @objc func next_() {
//
//        guard let  phoneNumber = fetchPhoneNumber() else { return }
////        let phoneNumber = "+15555555555"
//
//        phoneContainerView.ind.show()
//        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
//        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
//            self.phoneContainerView.ind.dismiss()
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            guard let verificationID = verificationID else { return }
//
//            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
//            UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
//
//            let destination = VerificationController()
//            self.navigationController?.pushViewController(destination, animated: true)
//        }
//
//    }
    
    func fetchPhoneNumber() -> String? {
        if phoneContainerView.phoneNumberField.text == "(555) 555-5555" {
            return "+15555555555"
        } else if phoneContainerView.phoneNumberField.text == "(333) 333-3333" {
            return "+13333333333"
        } else if phoneContainerView.phoneNumberField.text == "(444) 444-4444" {
            return "+14444444444"
        } else {
            do {
                let phoneNumber = try phoneNumberKit.parse(phoneContainerView.phoneNumberField.nationalNumber)
                let code = phoneNumber.countryCode
                let number = "+" + String(code) + String(phoneContainerView.phoneNumberField.nationalNumber)
                return number
            } catch {
                hapticFeedbackRegular(style: .medium)
                displayErrorAlert(title: "Oops", message: "The phone number you provided is invalid. Double check and try again.", preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
                return nil
            }
        }
    }
    
    @objc func openCountryCodesList() {
        let picker = CountriesTableViewController()
        picker.delegate = self
        picker.currentCountry = "canada"
        phoneContainerView.phoneNumberField.resignFirstResponder()
        navigationController?.pushViewController(picker, animated: true)
    }

    @objc func phoneNumberChanged() {
        if phoneContainerView.phoneNumberField.text == "" {
            phoneContainerView.doneButton.isEnabled = false
        } else {
            phoneContainerView.doneButton.isEnabled = true
        }
    }
    
    fileprivate func setupNavigationbar() {
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        backButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true
    }
    
    @objc fileprivate func popController() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ChangePhoneNumberController {
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        
        phoneContainerView.doneButtonConstraint.constant =  -keyboardHeight
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        phoneContainerView.doneButtonConstraint.constant = -10
    }
}

extension ChangePhoneNumberController: CountryPickerDelegate {
    func countryPicker(_ picker: CountriesTableViewController, didSelectCountryWithName name: String, code: String, dialCode: String) {
        let flagIcon = flag(country: code)
        phoneContainerView.countryCode.setTitle("\(flagIcon) \(dialCode)", for: .normal)
    }
    
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}
