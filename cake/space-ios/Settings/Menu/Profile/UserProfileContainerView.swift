//
//  UserProfileContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-23.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

final class ProfileImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            NotificationCenter.default.post(name: .profilePictureDidSet, object: nil)
        }
    }
}

class UserProfileContainerView: UIView {
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("close", for: .normal)
        button.titleLabel?.textColor = .black
        
        return button
    }()
  
    lazy var profileImageView: ProfileImageView = {
        let profileImageView = ProfileImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
        profileImageView.layer.cornerRadius = 62.5
        profileImageView.layer.cornerCurve = .circular
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
  
  var name: PasteRestrictedTextField = {
    let name = PasteRestrictedTextField()
    name.font = ThemeManager.currentTheme().secondaryFontBold(with: 30)
    name.enablesReturnKeyAutomatically = true
    name.translatesAutoresizingMaskIntoConstraints = false
    name.textAlignment = .center
    name.placeholder = "Enter name"
    name.borderStyle = .none
    name.autocorrectionType = .no
    name.returnKeyType = .done
    name.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    name.textColor = ThemeManager.currentTheme().generalTitleColor
    name.isUserInteractionEnabled = true
  
    return name
  }()
  
  let phone: PasteRestrictedTextField = {
    let phone = PasteRestrictedTextField()
    phone.font = ThemeManager.currentTheme().secondaryFont(with: 16)
    phone.translatesAutoresizingMaskIntoConstraints = false
    phone.textAlignment = .center
    phone.keyboardType = .numberPad
    phone.placeholder = "Phone number"
    phone.borderStyle = .none
    phone.isEnabled = false
    phone.textColor = ThemeManager.currentTheme().generalSubtitleColor
    phone.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
   
    return phone
  }()
  
  let bioPlaceholderLabel: UILabel = {
    let bioPlaceholderLabel = UILabel()
    bioPlaceholderLabel.text = "Bio"
    bioPlaceholderLabel.sizeToFit()
    bioPlaceholderLabel.textAlignment = .left
    bioPlaceholderLabel.backgroundColor = .clear
    bioPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
    bioPlaceholderLabel.font = ThemeManager.currentTheme().secondaryFont(with: 15)
    bioPlaceholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor

    return bioPlaceholderLabel
  }()
  
  let userData: UIView = {
    let userData = UIView()
    userData.translatesAutoresizingMaskIntoConstraints = false
    userData.isUserInteractionEnabled = true
    
    return userData
  }()

  let bio: BioTextView = {
    let bio = BioTextView()
    bio.translatesAutoresizingMaskIntoConstraints = false
    bio.layer.borderWidth = 1
    bio.textAlignment = .center
    bio.font = ThemeManager.currentTheme().secondaryFont(with: 13)
    bio.isScrollEnabled = false
    bio.textContainerInset = UIEdgeInsets(top: 15, left: 35, bottom: 15, right: 35)
    bio.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    bio.backgroundColor = .clear
    bio.textColor = ThemeManager.currentTheme().generalTitleColor
    bio.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
    bio.layer.borderColor = UIColor.nude().cgColor
    bio.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    bio.textContainer.lineBreakMode = .byTruncatingTail
    bio.returnKeyType = .done
   
    return bio
  }()
  
  let countLabel: UILabel = {
    let countLabel = UILabel()
    countLabel.translatesAutoresizingMaskIntoConstraints = false
    countLabel.sizeToFit()
    countLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
    countLabel.isHidden = true
    countLabel.font = ThemeManager.currentTheme().secondaryFont(with: 14)
    
    return countLabel
  }()
  
  let bioMaxCharactersCount = 70

  override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = true
    backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    
    NotificationCenter.default.addObserver(self, selector: #selector(profilePictureDidSet), name: .profilePictureDidSet, object: nil)
    
    profileImageView.addSubview(addPhotoLabel)
    addSubview(profileImageView)
    addSubview(userData)
    addSubview(countLabel)
    userData.addSubview(name)
    userData.addSubview(phone)
  
      NSLayoutConstraint.activate([
        profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
        profileImageView.widthAnchor.constraint(equalToConstant: 125),
        profileImageView.heightAnchor.constraint(equalToConstant: 125),
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
        
        addPhotoLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
        addPhotoLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
        addPhotoLabel.widthAnchor.constraint(equalToConstant: 125),
        addPhotoLabel.heightAnchor.constraint(equalToConstant: 125),

        userData.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
        userData.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        userData.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        userData.heightAnchor.constraint(equalToConstant: 80),
        
        name.topAnchor.constraint(equalTo: userData.topAnchor, constant: 0),
        name.leftAnchor.constraint(equalTo: userData.leftAnchor, constant: 0),
        name.rightAnchor.constraint(equalTo: userData.rightAnchor, constant: 0),
        name.heightAnchor.constraint(equalToConstant: 45),
        
        phone.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 0),
        phone.leftAnchor.constraint(equalTo: userData.leftAnchor, constant: 0),
        phone.rightAnchor.constraint(equalTo: userData.rightAnchor, constant: 0),
        phone.heightAnchor.constraint(equalToConstant: 35),
        
//        bio.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
//
//        bioPlaceholderLabel.centerXAnchor.constraint(equalTo: bio.centerXAnchor, constant: 0),
//        bioPlaceholderLabel.centerYAnchor.constraint(equalTo: bio.centerYAnchor, constant: 0),
      ])
    
//    bioPlaceholderLabel.font = UIFont.systemFont(ofSize: 20)//(bio.font!.pointSize - 1)
//    bioPlaceholderLabel.isHidden = !bio.text.isEmpty
   
    
//    if #available(iOS 11.0, *) {
//      NSLayoutConstraint.activate([
//        profileImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
////        bio.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
////        bio.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
//        userData.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
//      ])
//    } else {
//      NSLayoutConstraint.activate([
//        profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
////        bio.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
////        bio.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
//        userData.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
//      ])
//    }
  }
    
    @objc func profilePictureDidSet() {
        if profileImageView.image == nil {
            addPhotoLabel.isHidden = false
        } else {
            addPhotoLabel.isHidden = true
        }
    }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
}
