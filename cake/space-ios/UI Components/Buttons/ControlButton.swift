//
//  ControlButton.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ControlButton: UIButton {

    static let cellHeight: CGFloat = 60

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.backgroundColor = self.isHighlighted ? ThemeManager.currentTheme().controlButtonHighlightingColor : ThemeManager.currentTheme().controlButtonColor
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.setTitleColor(self.isEnabled ? ThemeManager.currentTheme().controlButtonTintColor : ThemeManager.currentTheme().generalSubtitleColor, for: .normal)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 40, y: 40, width: 200, height: 50))
        translatesAutoresizingMaskIntoConstraints = false
//        layer.cornerRadius = 25
        titleLabel?.sizeToFit()
        setTitle("lkdkslmd", for: .normal)
        setTitleColor(ThemeManager.currentTheme().controlButtonTintColor, for: .normal)
    //    titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        backgroundColor = ThemeManager.currentTheme().controlButtonColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAction(_ selector: Selector) {
        addTarget(self, action: selector, for: .touchUpInside)
    }
}

