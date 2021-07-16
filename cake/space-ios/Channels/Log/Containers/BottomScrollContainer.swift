//
//  BottomScrollContainer.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class BottomScrollContainer: UIView {

    var scrollButton: UIButton = {
        let scrollButton = UIButton(type: .custom)
        scrollButton.translatesAutoresizingMaskIntoConstraints = false
        
        scrollButton.backgroundColor = .clear
        scrollButton.layer.shadowOpacity = 0.8
        scrollButton.cornerRadius = 20
        scrollButton.layer.cornerCurve = .circular
        scrollButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        scrollButton.setImage(UIImage(named: "arrowDownWhite")?.withRenderingMode(.alwaysTemplate), for: .normal)
        scrollButton.backgroundColor = ThemeManager.currentTheme().tintColor
        scrollButton.tintColor = .white
        
        scrollButton.imageView?.contentMode = .scaleAspectFit
        scrollButton.contentMode = .center
        
        scrollButton.borderWidth = 0.5
        scrollButton.borderColor = ThemeManager.currentTheme().generalBackgroundColor
        
        scrollButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 13, bottom: 3, right: 13)

        return scrollButton
    }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        changeTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)

        addSubview(scrollButton)
//        scrollButton.layer.cornerRadius = 22.5
        scrollButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc fileprivate func changeTheme() {
//        scrollButton.backgroundColor = .offBlack()
    }
}
