//
//  InputBlockerContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-11.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class InputBlockerContainerView: UIView {

    let backButton: InteractiveButton = {
        let backButton = InteractiveButton()
        backButton.setTitleColor(.gray, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = .clear
        backButton.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 14)

        return backButton
    }()

    private var heightConstraint_: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)

        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            if let bottom = window?.safeAreaInsets.bottom {
                heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight() + bottom)
            }
        } else {
            heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight())
        }
        
        heightConstraint_.isActive = true
        
        backgroundColor = ThemeManager.currentTheme().barBackgroundColor

        //changeTheme()

        addSubview(backButton)
        backButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func changeTheme() {
        backgroundColor = ThemeManager.currentTheme().inputTextViewColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
