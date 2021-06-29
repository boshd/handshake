//
//  VerificationContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-08.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import SVProgressHUD

class VerificationContainerView: UIView, UITextFieldDelegate {
    
    let ind = SVProgressHUD.self
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 23)
        titleLabel.textAlignment = .center
        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .clear
        titleLabel.text = "Enter verification code."
        
        return titleLabel
    }()
    
    let infoLabel: DynamicLabel = {
        let infoLabel = DynamicLabel(withInsets: 0, 0, 0, 0)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        infoLabel.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
        infoLabel.textColor = .gray
        infoLabel.textAlignment = .left
        infoLabel.text = "Check your messages for a verification code"
        infoLabel.numberOfLines = 2
        
        return infoLabel
    }()
    
    let codeField: UITextField = {
        var field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = ThemeManager.currentTheme().secondaryFontBold(with: 28)
        field.textColor = ThemeManager.currentTheme().generalTitleColor
        field.tintColor = ThemeManager.currentTheme().tintColor
        field.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        field.textAlignment = .center
        field.keyboardType = .numberPad
        field.textContentType = .oneTimeCode
        field.defaultTextAttributes.updateValue(36.0, forKey: NSAttributedString.Key.kern)
        field.addTarget(self, action: #selector(VerificationController.textFieldDidChange), for: .editingChanged)
        return field
    }()
    
    let doneButton: InteractiveButton = {
        let button = InteractiveButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        
        let image = UIImage(named: "ctrl-right")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = ThemeManager.currentTheme().buttonIconColor
        
        button.cornerRadius = 30
        button.layer.cornerCurve = .circular
        
        return button
    }()
    
    var doneButtonConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor

        codeField.delegate = self
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: 50 - 1, width: codeField.bounds.width, height: 0.7)
        bottomLine.backgroundColor = UIColor.black.cgColor
        codeField.borderStyle = .none
        codeField.layer.addSublayer(bottomLine)
        
        addSubview(codeField)
        addSubview(titleLabel)
        addSubview(infoLabel)
//        addSubview(doneButton)
        
        ind.setDefaultMaskType(.clear)
        
//        doneButtonConstraint = doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
//        doneButtonConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            infoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            infoLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0),
            
            codeField.widthAnchor.constraint(equalTo: widthAnchor, constant: -40),
            codeField.heightAnchor.constraint(equalToConstant: 50),
            codeField.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 55),
            codeField.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            
//            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            doneButton.heightAnchor.constraint(equalToConstant: 55),
//            doneButton.widthAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    func setColors() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        codeField.textColor = ThemeManager.currentTheme().generalTitleColor
        infoLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
//        doneButton.backgroundColor = ThemeManager.currentTheme().buttonColor
//        doneButton.tintColor = ThemeManager.currentTheme().buttonIconColor
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count < 7
    }
    
}

