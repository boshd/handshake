//
//  PhotoContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-09.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import PhoneNumberKit
import SVProgressHUD

final class OnboardingProfileImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            NotificationCenter.default.post(name: .profilePictureDidSet, object: nil)
        }
    }
}

class PhotoContainerView: UIView {
    
    let ind = SVProgressHUD.self
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = ThemeManager.currentTheme().primaryFont(with: 26)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.text = "Details"
        
        return titleLabel
    }()
    
//    lazy var profileImageView: OnboardingProfileImageView = {
//        let profileImageView = OnboardingProfileImageView()
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.layer.masksToBounds = true
//        profileImageView.layer.borderWidth = 1
//        profileImageView.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
////         profileImageView.layer.cornerRadius = 25
//        profileImageView.isUserInteractionEnabled = true
//        profileImageView.backgroundColor = .lighterGray()
//
//        return profileImageView
//    }()
    
    lazy var imageView: OnboardingProfileImageView = {
        let profileImageView = OnboardingProfileImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
//         profileImageView.layer.cornerRadius = 25
        profileImageView.isUserInteractionEnabled = true
        profileImageView.backgroundColor = .lighterGray()
        
        return profileImageView
    }()
    
    let addPhotoLabel: UILabel = {
      let addPhotoLabel = UILabel()
      addPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
      addPhotoLabel.text = "📷"
      addPhotoLabel.numberOfLines = 2
      addPhotoLabel.textColor = .gray
      addPhotoLabel.font = ThemeManager.currentTheme().secondaryFont(with: 16)
      addPhotoLabel.textAlignment = .center
      
      return addPhotoLabel
    }()
    
    let infoLabel: DynamicLabel = {
        let infoLabel = DynamicLabel(withInsets: 0, 0, 0, 0)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        infoLabel.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        infoLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        infoLabel.textAlignment = .center
        infoLabel.text = "Capture or choose a profile picture for your account"
        infoLabel.numberOfLines = 2
        
        return infoLabel
    }()
    
    let nameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.placeholder = "Display name"
        field.font = ThemeManager.currentTheme().secondaryFont(with: 15)
        field.tintColor = ThemeManager.currentTheme().tintColor
        field.textColor = ThemeManager.currentTheme().generalTitleColor
        field.textAlignment = .center
        field.autocapitalizationType = .words
//        field.defaultTextAttributes = attribure
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(profilePictureDidSet), name: .profilePictureDidSet, object: nil)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: 50 - 1, width: 200, height: 0.7)
        bottomLine.backgroundColor = UIColor.black.cgColor
        nameField.borderStyle = .none
        nameField.layer.addSublayer(bottomLine)
        
//        addSubview(titleLabel)
        addSubview(imageView)
//        addSubview(infoLabel)
        addSubview(nameField)
        
        imageView.addSubview(addPhotoLabel)
        
        ind.setDefaultMaskType(.clear)
        
        NSLayoutConstraint.activate([
//            titleLabel.heightAnchor.constraint(equalToConstant: 60),
//            titleLabel.widthAnchor.constraint(equalToConstant: 300),
//            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            
//            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
//            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            infoLabel.widthAnchor.constraint(equalToConstant: 200),
//
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 100),
            
            addPhotoLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            addPhotoLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            addPhotoLabel.widthAnchor.constraint(equalToConstant: 100),
            addPhotoLabel.heightAnchor.constraint(equalToConstant: 100),
            
            nameField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            nameField.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            nameField.widthAnchor.constraint(equalToConstant: 200),
            
//            imageButton.heightAnchor.constraint(equalToConstant: 200),
//            imageButton.widthAnchor.constraint(equalToConstant: 200),
//            imageButton.centerXAnchor.constraint(equalTo: centerXAnchor),
//            imageButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    @objc func profilePictureDidSet() {
        if imageView.image == nil {
            addPhotoLabel.isHidden = false
        } else {
            addPhotoLabel.isHidden = true
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}

