//
//  ViewPlaceholder.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-21.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

enum ViewPlaceholderPriority: CGFloat {
  case low = 0.1
  case medium = 0.5
  case high = 1.0
}

enum ViewPlaceholderPosition {
  case top
  case center
}

enum ViewPlaceholderTitle: String {
    case noChannels = "You don't have any events yet."
    case searchForLocation = "Search for a place or address."
    case noUsers = "No users found. 😞"
    case deniedContacts = "✋ Access Denied."
    case nothingHere = "✋ Nothing to see here."
    // case deniedLocation = "✋ Access Denied."
}

enum ViewPlaceholderSubtitle: String {
    case noChannels = "Start by creating a new event. Tap the + button above."
    case noUsers = "Looks like none of your contacts are signed up and that's okay. Invite them through the contacts page."
    case deniedContacts = "Please go to your iPhone Settings –– Privacy –– Contacts. Then select ON for Handshake."
    case nothingHere = "Seriously, nothing to see here."
    case empty = ""
}

enum ViewPlaceholderImage: String {
    case noChannels = "looking_wo_legs.png"
    case nothing = ""
}

class ViewPlaceholder: UIView {
    
    var title = DynamicLabel(withInsets: 0, 0, 0, 0)
    var subtitle = DynamicLabel(withInsets: 0, 0, 0, 0)
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var placeholderPriority: ViewPlaceholderPriority = .low
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        title.font = ThemeManager.currentTheme().secondaryFontBold(with: 34)
        title.textColor = .lightGray
        title.textAlignment = .center
        title.numberOfLines = 2
        title.translatesAutoresizingMaskIntoConstraints = false
        
        subtitle.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        subtitle.textColor = .lightGray
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(title)
        addSubview(subtitle)
        
        NSLayoutConstraint.activate([
            
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            title.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
//             title.heightAnchor.constraint(equalToConstant: 85),
            
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 15),
            subtitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 35),
            subtitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -35),
//            subtitle.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    func add(for view: UIView, title: ViewPlaceholderTitle, subtitle: ViewPlaceholderSubtitle, priority: ViewPlaceholderPriority, position: ViewPlaceholderPosition) {
//        guard priority.rawValue >= placeholderPriority.rawValue else { return }
//        placeholderPriority = priority
//        self.title.text = title.rawValue
//        self.subtitle.text = subtitle.rawValue
//
//        if position == .center {
//            print("entered here ")
//            self.title.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
//        }
//        if position == .top {
//            self.title.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
//        }
//
//        DispatchQueue.main.async {
//            view.addSubview(self)
//            self.topAnchor.constraint(equalTo: view.topAnchor, constant: 135).isActive = true
//            self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
//            self.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
//        }
        
        guard priority.rawValue >= placeholderPriority.rawValue else { return }
        placeholderPriority = priority
        self.title.text = title.rawValue
        self.subtitle.text = subtitle.rawValue
        if position == .center {
            self.title.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        }
        if position == .top {
            self.title.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        }
        DispatchQueue.main.async {
            view.addSubview(self)
//            if #available(iOS 11.0, *) {
//                self.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
//            } else {
//                self.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
//            }
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true

            self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 30).isActive = true
        }
    }
    
    func remove(from view: UIView, priority: ViewPlaceholderPriority) {
        guard priority.rawValue >= placeholderPriority.rawValue else { return }
        for subview in view.subviews where subview is ViewPlaceholder {
            DispatchQueue.main.async {
                subview.removeFromSuperview()
            }
        }
    }
    
}
