//
//  WelcomeContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-30.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class WelcomeContainerView: UIView {
    
    let signupButton: InteractiveButton = {
        let button = InteractiveButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get started", for: .normal)
        button.setTitleColor(ThemeManager.currentTheme().buttonIconColor, for: .normal)
        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 17)
        button.addTarget(self, action: #selector(WelcomeViewController.toSignup), for: .touchUpInside)
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        button.cornerRadius = 30
        button.layer.cornerCurve = .continuous
        
        return button
    }()
    
    var titleLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.numberOfLines = 0
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 40)
        label.text = "Handshake"
        return label
    }()
    
    var detailsLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().tintColor
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 22)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "Seamlessly plan private events with your favourite people."
        
        return label
    }()
    
    var disclaimerTextView: UITextView = {
        var textView =  UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        textView.textColor = ThemeManager.currentTheme().generalTitleColor
        
        return textView
    }()
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "looking_wo_legs")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var halfView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
//        let mainString = titleLabel.text
//        let stringToColor = "."
//        let range = (mainString! as NSString).range(of: stringToColor)
//        let mutableAttributedString = NSMutableAttributedString.init(string: mainString!)
//        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.47, green: 1.00, blue: 0.88, alpha: 1.00), range: range)
//        mutableAttributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(15.0), range: NSRange(location: 0, length: mutableAttributedString.length))
//        titleLabel.attributedText = mutableAttributedString
//        titleLabel.addCharacterSpacing(kernValue: 3)
//        addSubview(imageView)
//        addSubview(halfView)
        addSubview(titleLabel)
        addSubview(detailsLabel)
        addSubview(disclaimerTextView)
        addSubview(signupButton)
        
        configureDisclaimer()
        
        NSLayoutConstraint.activate([
//            halfView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//            halfView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//            halfView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//            halfView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height / 2) - 30),
//
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -150),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            disclaimerTextView.bottomAnchor.constraint(equalTo: signupButton.topAnchor, constant: -20),
            disclaimerTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            disclaimerTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            disclaimerTextView.heightAnchor.constraint(equalToConstant: 50),
            
            signupButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            signupButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            signupButton.heightAnchor.constraint(equalToConstant: 60),
            signupButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
    }
    
    func configureDisclaimer() {
        let mainString = "By using Handshake, you agree to our Terms of Service.\nYou can learn more about how we process your data in our Privacy Policy."
        let privacyString = "Privacy Policy"
        let termsString = "Terms of Service"
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        let termsRange = (mainString as NSString).range(of: termsString)
        let privacyRange = (mainString as NSString).range(of: privacyString)
        mutableAttributedString.setAttributes([.link: "https://kareemarab.now.sh/terms"], range: termsRange)
        mutableAttributedString.setAttributes([.link: "https://kareemarab.now.sh/privacy"], range: privacyRange)
        disclaimerTextView.attributedText = mutableAttributedString
        
        disclaimerTextView.isUserInteractionEnabled = true
        disclaimerTextView.isSelectable = false
        disclaimerTextView.isEditable = false
        
        disclaimerTextView.dataDetectorTypes = .all
        disclaimerTextView.linkTextAttributes = [
            .foregroundColor: ThemeManager.currentTheme().tintColor
        ]
        
        disclaimerTextView.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        disclaimerTextView.textAlignment = .center
        disclaimerTextView.textColor = ThemeManager.currentTheme().generalTitleColor
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setColors() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        disclaimerTextView.textColor = ThemeManager.currentTheme().generalTitleColor
        configureDisclaimer()
    }
    
}

