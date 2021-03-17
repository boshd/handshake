//
//  SigninContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-30.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class SignInContainerView: UIView {
    
//    var bottomConstraint: NSLayoutConstraint?
    
    let nextButton: LoadingButton = {
        let nextButton = LoadingButton(frame: .zero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Sign In", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = UIColor.thatPink()
        nextButton.layer.cornerRadius = 30
        nextButton.isEnabled = true
        
        return nextButton
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 25)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.backgroundColor = UIColor.offBlack()
        titleLabel.text = "Log in to Space"
        
        return titleLabel
    }()
    
    let emailField: UITextField = {
        let emailField = UITextField(frame: .zero)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.backgroundColor = UIColor.offBlack()
        emailField.textColor = .white
        emailField.tintColor = UIColor.thatPink()
        emailField.layer.cornerRadius = 30
        emailField.font = UIFont(name: "AvenirNext-Medium", size: 18)
        emailField.placeholder = "Email"
        emailField.autocapitalizationType = .none
        emailField.returnKeyType = .next
        emailField.autocorrectionType = .no
        emailField.spellCheckingType = .no
        emailField.keyboardType = UIKeyboardType.emailAddress
        emailField.keyboardAppearance = .dark
        emailField.tag = 1
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:15, height:10))
        emailField.leftViewMode = UITextField.ViewMode.always
        emailField.leftView = spacerView
        
        return emailField
    }()
    
    let passwordField: UITextField = {
        let passwordField = UITextField(frame: .zero)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.backgroundColor = UIColor.offBlack()
        passwordField.textColor = .white
        passwordField.tintColor = UIColor.thatPink()
        passwordField.layer.cornerRadius = 30
        passwordField.font = UIFont(name: "AvenirNext-Medium", size: 18)
        passwordField.placeholder = "Password"
        passwordField.autocapitalizationType = .none
        passwordField.returnKeyType = .done
        passwordField.autocorrectionType = .no
        passwordField.spellCheckingType = .no
        passwordField.keyboardType = UIKeyboardType.default
        passwordField.isSecureTextEntry = true
        passwordField.keyboardAppearance = .dark
        passwordField.tag = 2
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:15, height:10))
        passwordField.leftViewMode = UITextField.ViewMode.always
        passwordField.leftView = spacerView
        
        return passwordField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(emailField)
        addSubview(passwordField)
        addSubview(nextButton)
        
//        bottomConstraint = NSLayoutConstraint(item: nextButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
//        addConstraint(bottomConstraint!)
        
        backgroundColor = UIColor.offBlack()
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.widthAnchor.constraint(equalToConstant: 250),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),

            emailField.heightAnchor.constraint(equalToConstant: 60),
            emailField.widthAnchor.constraint(equalToConstant: 300),
            emailField.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            passwordField.heightAnchor.constraint(equalToConstant: 60),
            passwordField.widthAnchor.constraint(equalToConstant: 300),
            passwordField.centerXAnchor.constraint(equalTo: centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            
            nextButton.heightAnchor.constraint(equalToConstant: 60),
            nextButton.widthAnchor.constraint(equalToConstant: 250),
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}

