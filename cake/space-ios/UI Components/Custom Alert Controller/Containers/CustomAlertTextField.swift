//
//  CustomAlertTextField.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-07.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class CustomAlertTextField: UITextField {
    var action: CustomAlertAction?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 40, y: 40, width: 200, height: 50))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        textColor = ThemeManager.currentTheme().generalTitleColor
        textAlignment = .center
        tintColor = ThemeManager.currentTheme().tintColor
        font = ThemeManager.currentTheme().secondaryFont(with: 12)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
