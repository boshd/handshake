//
//  CustomAlertButton.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-04.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class CustomAlertButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.backgroundColor = self.isHighlighted ? ThemeManager.currentTheme().controlButtonHighlightingColor : ThemeManager.currentTheme().generalModalControllerBackgroundColor
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
        }
    }
    
    var action: CustomAlertAction?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 40, y: 40, width: 200, height: 50))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
        titleLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        setTitleColor(ThemeManager.currentTheme().secondaryButtonTitleColor, for: .normal)
        setTitleColor(.lightGray, for: .disabled)
        
        layer.cornerCurve = .continuous
        layer.borderColor = ThemeManager.currentTheme().alertControllerSeperatorColor.cgColor
        layer.borderWidth = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAction(_ selector: Selector) {
        addTarget(self, action: selector, for: .touchUpInside)
    }
    
}

