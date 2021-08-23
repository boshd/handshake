//
//  WelcomeContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-30.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import SafariServices

class WelcomeContainerView: UIView, UITextViewDelegate {
    
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
    
    var emojiLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.numberOfLines = 0
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 45)
        label.text = "🤝"
        return label
    }()
    
    var titleLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.numberOfLines = 0
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 36)
        label.text = "Handshake"
        return label
    }()
    
    var detailsLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().tintColor
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 20)
        label.numberOfLines = 0
        label.textAlignment = .left
        //label.text = "Seamlessly plan private events with your favourite people."
        label.text = "Organize private events with those you love — featuring rsvp, group chat, location, and more."
        
        return label
    }()
    
    var disclaimerTextView: UITextView = {
        var textView =  UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
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
        addSubview(emojiLabel)
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
            emojiLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 35),
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emojiLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 115),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            disclaimerTextView.bottomAnchor.constraint(equalTo: signupButton.topAnchor, constant: -20),
            disclaimerTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            disclaimerTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            disclaimerTextView.heightAnchor.constraint(equalToConstant: 50),
            
            signupButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signupButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            signupButton.heightAnchor.constraint(equalToConstant: 60),
            signupButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
    }
    
    func configureDisclaimer() {
        
        let termsUrl = "https://www.notion.so/e0cc5b02ebfa4071ac97a204c7db25eb"
        let privacyUrl = "https://www.notion.so/Your-privacy-matters-to-us-419248ff0f624d66ad9915e1b090fe1f"
        
//        Add a link to your attributed string:

        let originalText = "By using Handshake, you agree to our Terms of Service.\nYou can learn more about how we process your data in our Privacy Policy."
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        
        let termsLinkRange = attributedOriginalText.mutableString.range(of: "Terms of Service")
        attributedOriginalText.addAttribute(.link, value: termsUrl, range: termsLinkRange)
        
        let privacyLinkRange = attributedOriginalText.mutableString.range(of: "Privacy Policy")
        attributedOriginalText.addAttribute(.link, value: privacyUrl, range: privacyLinkRange)

        disclaimerTextView.attributedText = attributedOriginalText
        
        disclaimerTextView.linkTextAttributes = [
            .foregroundColor : ThemeManager.currentTheme().tintColor,
        ]
        
        disclaimerTextView.textAlignment = .center
        
//        let mainString = "By using Handshake, you agree to our Terms of Service.\nYou can learn more about how we process your data in our Privacy Policy."
//        let privacyString = "Privacy Policy"
//        let termsString = "Terms of Service"
//        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
//        let termsRange = (mainString as NSString).range(of: termsString)
//        let privacyRange = (mainString as NSString).range(of: privacyString)
//        mutableAttributedString.setAttributes([.link: "https://www.notion.so/e0cc5b02ebfa4071ac97a204c7db25eb"], range: termsRange)
//        mutableAttributedString.setAttributes([.link: NSMutableAttributedString(string: "https://www.notion.so/Your-privacy-matters-to-us-419248ff0f624d66ad9915e1b090fe1f")], range: privacyRange)
//
//        disclaimerTextView.attributedText = mutableAttributedString
//
//        disclaimerTextView.isUserInteractionEnabled = true
        disclaimerTextView.isSelectable = true
        disclaimerTextView.isEditable = false
//        disclaimerTextView.linkTextAttributes = [.link: NSMutableAttributedString(string: "https://www.notion.so/Your-privacy-matters-to-us-419248ff0f624d66ad9915e1b090fe1f")]
//
//        disclaimerTextView.delegate = self
//
//        disclaimerTextView.dataDetectorTypes = .link
//        disclaimerTextView.linkTextAttributes = [
//            .foregroundColor: ThemeManager.currentTheme().tintColor
//        ]
//
//        disclaimerTextView.font = ThemeManager.currentTheme().secondaryFont(with: 11)
//        disclaimerTextView.textAlignment = .center
//        disclaimerTextView.textColor = ThemeManager.currentTheme().generalTitleColor
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
    
    // MARK: - Text view link clicking
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.absoluteString == "https://www.mywebsite.com") {
            // Do whatever you want here as the action to the user pressing your 'actionString'
            print("detected")
            openUrl("google.com")
        }
        return false
    }
    
    func openUrl(_ url: String) {
        var svc = SFSafariViewController(url: URL(string: url)!)

        if #available(iOS 11.0, *) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true
            svc = SFSafariViewController(url: URL(string: url)!, configuration: configuration)
        }

        svc.preferredControlTintColor = ThemeManager.currentTheme().tintColor
        svc.preferredBarTintColor = ThemeManager.currentTheme().generalBackgroundColor
//        present(svc, animated: true, completion: nil)
    }
}

