//
//  PhoneController.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-06.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit
import Firebase

class PhoneController: UIViewController {
    
    var image: UIImage?
    let phoneNumberKit = PhoneNumberKit()
    let storage = Storage.storage()
    var window: UIWindow?
    
    let phoneContainerView = PhoneContainerView()
    let userCreatingGroup = DispatchGroup()
    
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
        setupView()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        navigationController?.isNavigationBarHidden = false
    }
    
    private func loadViews() {
        self.view = phoneContainerView
    }
    
    private func setupView() {
        guard let view = view as? PhoneContainerView else {
            fatalError("Root view is not PhoneController")
        }
        view.phoneNumberField.becomeFirstResponder()
        phoneContainerView.phoneNumberField.addTarget(self, action: #selector(phoneNumberChanged), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        phoneContainerView.doneButton.addTarget(self, action: #selector(next_), for: .touchUpInside)
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
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    @objc func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        phoneContainerView.setColors()
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
    }
    
    fileprivate func setupNavigationbar() {
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action: #selector(popController))
        cancelButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = cancelButtonItem
        
        navigationItem.hidesBackButton = true
    }
    
    @objc func openCountryCodesList() {
        let picker = CountriesTableViewController()
        picker.delegate = self
        picker.currentCountry = "canada"
        phoneContainerView.phoneNumberField.resignFirstResponder()
        hapticFeedback(style: .selectionChanged)
        navigationController?.pushViewController(picker, animated: true)
    }

    @objc func phoneNumberChanged() {
        if phoneContainerView.phoneNumberField.text == "" {
            phoneContainerView.doneButton.isEnabled = false
        } else {
            phoneContainerView.doneButton.isEnabled = true
        }
    }
    
    @objc func popController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func next_() {
        
        guard let phoneNumber = verifyNumber() else { return }
        
        globalIndicator.show()
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            globalIndicator.dismiss()
            if let error = error {
                displayErrorAlert(title: basicErrorTitleForAlert, message: error.localizedDescription, preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
                print(error)
                return
            }

            guard let verificationID = verificationID else { return }

            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")

            hapticFeedbackRegular(style: .medium)
            let destination = VerificationController()
            self.navigationController?.pushViewController(destination, animated: true)
        }

    }
    
    func verifyNumber() -> String? {
        guard let countryCode = phoneContainerView.countryCode.titleLabel?.text?[2...] else { return nil }
        let phoneNumber = String(countryCode) + String(phoneContainerView.phoneNumberField.nationalNumber)
        
        if phoneNumber == "+12222222222" {
            return phoneNumber
        } else if phoneNumber == "+13333333333" {
            return phoneNumber
        } else if phoneNumber == "+14444444444" {
            return phoneNumber
        } else if phoneNumber == "+15555555555" {
            return phoneNumber
        } else if phoneNumber == "+16666666666" {
            return phoneNumber
        } else if phoneNumber == "+17777777777" {
            return phoneNumber
        } else if phoneNumber == "+18888888888" {
            return phoneNumber
        } else if phoneNumber == "+19999999999" {
            return phoneNumber
        } else {
            do {
                let _ = try phoneNumberKit.parse(phoneNumber)
                return phoneNumber
            } catch {
                displayErrorAlert(title: basicErrorTitleForAlert, message: "The phone number you provided is invalid. Double check and try again.", preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
                print(error.localizedDescription)
                return nil
            }
        }
    }
    
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

extension PhoneController: CountryPickerDelegate {
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

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
