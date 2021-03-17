//
//  CreateAccountContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-06.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class CreateAccountContainerView: UIView {
    
//    var bottomConstraint: KeyboardLayoutConstraint?
    var buttonConstraint: NSLayoutConstraint!
    
    let nextButton: LoadingButton = {
        let nextButton = LoadingButton(frame: .zero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = UIColor.thatPink()
        nextButton.layer.cornerRadius = 22.5
        nextButton.isEnabled = true
        nextButton.addTarget(self, action: #selector(CreateAccountController.signup), for: .touchUpInside)
        
        return nextButton
    }()
//    HelveticaNeue-Bold PlayfairDisplay-Bold
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "PlayfairDisplay-Bold", size: 30)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.backgroundColor = .white
        titleLabel.text = "Create your account"
        
        return titleLabel
    }()
    
    let errorLabel: UILabel = {
        let errorLabel = UILabel(frame: .zero)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        errorLabel.textColor = UIColor.thatPink()
        errorLabel.numberOfLines = 2
        errorLabel.backgroundColor = .white
        errorLabel.text = ""
        
        return errorLabel
    }()
    
    let termsLabel: UILabel = {
        let termsLabel = UILabel(frame: .zero)
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 11)
        termsLabel.textColor = .black
        termsLabel.numberOfLines = 3
        termsLabel.backgroundColor = .white
        termsLabel.textAlignment = .center
       
        let stringValue = "By signing up you agree to the Terms of Service and Privacy Policy, including Cookie Use."
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Terms of Service", withColor: .black)
        attributedString.setColorForText(textForAttribute: "Privacy Policy", withColor: .black)
        termsLabel.attributedText = attributedString

        return termsLabel
    }()
    
    let nameField: UITextField = {
        let nameField = UITextField(frame: .zero)
        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.backgroundColor = UIColor.white
        nameField.textColor = .black
        nameField.tintColor = UIColor.thatPink()
        nameField.layer.cornerRadius = 30
        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .next
        nameField.autocorrectionType = .no
        nameField.spellCheckingType = .no
        nameField.keyboardAppearance = .light
        nameField.tag = 0
        
        nameField.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        nameField.placeholder = "Name"
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:15, height:10))
        nameField.leftViewMode = UITextField.ViewMode.always
        nameField.leftView = spacerView
        
        return nameField
    }()
    
    let emailField: UITextField = {
        let emailField = UITextField(frame: .zero)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.backgroundColor = UIColor.white
        emailField.textColor = .black
        emailField.tintColor = UIColor.thatPink()
        emailField.layer.cornerRadius = 30
        emailField.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        emailField.placeholder = "Email"
        emailField.autocapitalizationType = .none
        emailField.returnKeyType = .next
        emailField.autocorrectionType = .no
        emailField.spellCheckingType = .no
        emailField.keyboardType = UIKeyboardType.emailAddress
        emailField.keyboardAppearance = .light
        emailField.tag = 1
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:15, height:10))
        emailField.leftViewMode = UITextField.ViewMode.always
        emailField.leftView = spacerView
        
        return emailField
    }()
    
    let passwordField: UITextField = {
        let passwordField = UITextField(frame: .zero)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.backgroundColor = UIColor.white
        passwordField.textColor = .black
        passwordField.tintColor = UIColor.thatPink()
        passwordField.layer.cornerRadius = 30
        passwordField.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        passwordField.placeholder = "Password"
        passwordField.autocapitalizationType = .none
        passwordField.returnKeyType = .done
        passwordField.autocorrectionType = .no
        passwordField.spellCheckingType = .no
        passwordField.keyboardType = UIKeyboardType.default
        passwordField.isSecureTextEntry = true
        passwordField.keyboardAppearance = .light
        passwordField.tag = 2
        
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:15, height:10))
        passwordField.leftViewMode = UITextField.ViewMode.always
        passwordField.leftView = spacerView
        
        return passwordField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(nameField)
        addSubview(emailField)
        addSubview(passwordField)
        addSubview(errorLabel)
        addSubview(nextButton)
        addSubview(termsLabel)
        
//        bottomConstraint = KeyboardLayoutConstraint(item: nextButton, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0)
//        addConstraint(bottomConstraint!)
        
        buttonConstraint = nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 15)
        buttonConstraint.isActive = true
        
        backgroundColor = .white
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.widthAnchor.constraint(equalToConstant: 280),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            
            nameField.heightAnchor.constraint(equalToConstant: 60),
            nameField.widthAnchor.constraint(equalToConstant: 280),
            nameField.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            emailField.heightAnchor.constraint(equalToConstant: 60),
            emailField.widthAnchor.constraint(equalToConstant: 280),
            emailField.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 5),
            
            passwordField.heightAnchor.constraint(equalToConstant: 60),
            passwordField.widthAnchor.constraint(equalToConstant: 280),
            passwordField.centerXAnchor.constraint(equalTo: centerXAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 5),
        
            errorLabel.heightAnchor.constraint(equalToConstant: 20),
            errorLabel.widthAnchor.constraint(equalToConstant: 280),
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 5),
            
            termsLabel.heightAnchor.constraint(equalToConstant: 40),
            termsLabel.widthAnchor.constraint(equalToConstant: 280),
            termsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            termsLabel.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 5),
            
            nextButton.heightAnchor.constraint(equalToConstant: 45),
            nextButton.widthAnchor.constraint(equalToConstant: 280),
            nextButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
