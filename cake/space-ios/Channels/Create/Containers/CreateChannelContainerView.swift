//
//  CreateChannelContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class CreateChannelContainerView: UIView {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let selectUsersButtonView = SelectUsersButtonView()
    let selectLocationButtonView = SelectUsersButtonView()
    let selectDateAndTimeButtonView = SelectUsersButtonView()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    let nameTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .red
        textView.isScrollEnabled = false
        textView.font = ThemeManager.currentTheme().secondaryFont(with: 28)
        textView.text = "Give me a name"
        textView.textColor = UIColor.lightGray
        textView.returnKeyType = .done
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.tintColor = .black
        
        return textView
    }()
    
    let channelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .fabGold()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "search")
        
        return imageView
    }()
    
    let channelImagePlaceholderLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 2, 2, 6, 6)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add image"
        label.backgroundColor = .black
        label.textColor = .white
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    let floatingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        // add a white arrow icon ->
        button.layer.cornerRadius = 35
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = ThemeManager.currentTheme().primaryFontItalic(with: 18)
        button.titleLabel?.textColor = .white
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        
        addSubview(scrollView)
    
        scrollView.addSubview(nameTextView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            nameTextView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            nameTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            nameTextView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0),
            nameTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
        ])
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
