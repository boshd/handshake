//
//  PhoneContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-08.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import PhoneNumberKit
import SVProgressHUD
 //import CountryPicker

class PhoneContainerView: UIView {
    
    let ind = SVProgressHUD.self
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ThemeManager.currentTheme().secondaryFontBold(with: 23)
        titleLabel.textAlignment = .center
        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .clear
        titleLabel.text = "What's your phone number?"
        
        return titleLabel
    }()
    
    let phoneNumberField: PhoneNumberTextField = {
        let phoneNumberField = PhoneNumberTextField(frame: .zero)
        phoneNumberField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberField.font = ThemeManager.currentTheme().secondaryFontBold(with: 22)
        phoneNumberField.textColor = ThemeManager.currentTheme().generalTitleColor
        phoneNumberField.tintColor = ThemeManager.currentTheme().tintColor
        phoneNumberField.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        return phoneNumberField
    }()
    
    let infoLabel: DynamicLabel = {
        let infoLabel = DynamicLabel(withInsets: 0, 0, 0, 0)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        infoLabel.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        infoLabel.textColor = .gray
        infoLabel.textAlignment = .left
        infoLabel.text = phoneNumberSMSDisclaimer
        infoLabel.numberOfLines = 4
        
        return infoLabel
    }()
    
    let countryCode: InteractiveButton = {
        var countryCode = InteractiveButton()
        countryCode.translatesAutoresizingMaskIntoConstraints = false
        countryCode.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 22)
        countryCode.setTitleColor(ThemeManager.currentTheme().generalTitleColor, for: .normal)
        countryCode.backgroundColor = ThemeManager.currentTheme().countryCodeBackgroundColor
        countryCode.tintColor = ThemeManager.currentTheme().tintColor
        countryCode.setTitle("🇨🇦 +1", for: .normal)
        countryCode.addTarget(self, action: #selector(PhoneController.openCountryCodesList), for: .touchUpInside)
        
        return countryCode
    }()
    
    lazy var stackView: UIStackView = {
        var stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 16.0
        
        stackView.addArrangedSubview(countryCode)
        stackView.addArrangedSubview(phoneNumberField)
        
        return stackView
    }()
    
    let doneButton: InteractiveButton = {
        let button = InteractiveButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        button.isEnabled = false
        
        let image = UIImage(named: "ctrl-right")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = ThemeManager.currentTheme().buttonIconColor
        
        return button
    }()
    
    var doneButtonConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor

        addSubview(stackView)
        addSubview(titleLabel)
        addSubview(infoLabel)
        addSubview(doneButton)
        
        ind.setDefaultMaskType(.clear)
        
        doneButtonConstraint = doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
        doneButtonConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            
            stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -40),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            
            infoLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 6),
            infoLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0),
            infoLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0),
            
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 55),
            doneButton.widthAnchor.constraint(equalToConstant: 55),
            
            phoneNumberField.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            countryCode.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            countryCode.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setColors() {
        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        phoneNumberField.textColor = ThemeManager.currentTheme().generalTitleColor
        countryCode.setTitleColor(ThemeManager.currentTheme().generalTitleColor, for: .normal)
        stackView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        doneButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        doneButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        doneButton.tintColor = ThemeManager.currentTheme().buttonIconColor
        countryCode.backgroundColor = ThemeManager.currentTheme().countryCodeBackgroundColor
        countryCode.setTitleColor(ThemeManager.currentTheme().generalTitleColor, for: .normal)
        phoneNumberField.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
