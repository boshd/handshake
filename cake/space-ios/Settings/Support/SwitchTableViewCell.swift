//
//  SwitchTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit


class SwitchTableViewCell: UITableViewCell {
  
  weak var currentViewController: UIViewController?
  
  static let viewsXPos: CGFloat = 15
  
  var title: UILabel = {
    var title = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.font = ThemeManager.currentTheme().secondaryFont(with: 13)
    title.textColor = ThemeManager.currentTheme().generalTitleColor
    
    return title
  }()
  
    var switchAccessory: UISwitch = {
        var switchAccessory = UISwitch()
        switchAccessory.translatesAutoresizingMaskIntoConstraints = false
        switchAccessory.onTintColor = ThemeManager.currentTheme().tintColor
        switchAccessory.isUserInteractionEnabled = true
        
        return switchAccessory
    }()
  
  var switchTapAction: ((Bool) -> Void)?
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        switchAccessory.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        selectionStyle = .none
        isUserInteractionEnabled = true
        contentView.addSubview(switchAccessory)
        addSubview(title)
        
        contentView.isUserInteractionEnabled = true

        switchAccessory.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchAccessory.widthAnchor.constraint(equalToConstant: 60).isActive = true

        if #available(iOS 11.0, *) {
            switchAccessory.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
        } else {
            switchAccessory.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        }

        title.centerYAnchor.constraint(equalTo: switchAccessory.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: switchAccessory.leftAnchor).isActive = true

        if #available(iOS 11.0, *) {
            title.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: SwitchTableViewCell.viewsXPos).isActive = true
        } else {
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: SwitchTableViewCell.viewsXPos).isActive = true
        }
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        title.textColor = ThemeManager.currentTheme().generalTitleColor
    }
  
    @objc func switchStateDidChange(_ sender: UISwitch) {
        switchTapAction?(sender.isOn)
    }
  
    func setupCell(object: SwitchObject, index: Int) {
        title.text = object.title
        switchAccessory.isOn = object.state

        switchTapAction = { (isOn) in
            if let notificationsController = self.currentViewController as? NotificationsController {
                notificationsController.notificationElements[index].state = isOn
                print(userDefaults.currentBoolObjectState(for: userDefaults.inAppVibration))
            }
        }
    }
}


