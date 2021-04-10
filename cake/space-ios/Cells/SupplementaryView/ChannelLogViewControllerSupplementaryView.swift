//
//  ChannelLogViewControllerSupplementaryView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-14.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class SupplementaryLabel: UILabel {
  
  var topInset: CGFloat = 5.0
  var bottomInset: CGFloat = 5.0
  var leftInset: CGFloat = 10.0
  var rightInset: CGFloat = 10.0
  
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
  
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

class ChannelLogViewControllerSupplementaryView: UICollectionReusableView {

    let label: SupplementaryLabel = {
        let label = SupplementaryLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .center
        label.layer.masksToBounds = true
        
        label.sizeToFit()
//        label.layer.masksToBounds = false
//        label.layer.shadowColor = ThemeManager.currentTheme().generalTitleColor.cgColor
//        label.layer.shadowOpacity = 0.15
//        label.layer.shadowOffset = CGSize(width: 4, height: 6)
//        label.layer.shadowRadius = 15
        label.cornerRadius = 5
        // label.textColor = ThemeManager.currentTheme().supplementaryViewTextColor
        label.backgroundColor = ThemeManager.currentTheme().generalTitleColor
        label.textColor = ThemeManager.currentTheme().generalBackgroundColor
        label.font = ThemeManager.currentTheme().secondaryFont(with: 10)
     
        return label
    }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(label)
    label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
  }
  
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
  @objc func changeTheme() {
    label.backgroundColor = ThemeManager.currentTheme().inputBarContainerViewBackgroundColor
    label.textColor = ThemeManager.currentTheme().generalTitleColor
    label.layer.shadowColor = ThemeManager.currentTheme().generalTitleColor.cgColor
    label.layer.shadowOpacity = 0.25
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
