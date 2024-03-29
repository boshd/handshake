//
//  CountriesTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-11.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

final class CountriesTableViewCell: UITableViewCell {

    fileprivate var name: UILabel = {
    var name = UILabel()
    name.translatesAutoresizingMaskIntoConstraints = false
        name.font = ThemeManager.currentTheme().secondaryFont(with: 16)
    name.textColor = ThemeManager.currentTheme().generalTitleColor
    name.lineBreakMode = .byTruncatingMiddle

    return name
  }()

  fileprivate var dialCode: UILabel = {
    var dialCode = UILabel()
    dialCode.translatesAutoresizingMaskIntoConstraints = false
    dialCode.font = ThemeManager.currentTheme().secondaryFont(with: 17)
    dialCode.textColor = ThemeManager.currentTheme().generalSubtitleColor
    dialCode.sizeToFit()
    dialCode.textAlignment = .right

    return dialCode
  }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
    selectionStyle = .none

    addSubview(name)
    addSubview(dialCode)

    dialCode.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    dialCode.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 0).isActive = true
    dialCode.rightAnchor.constraint(equalTo: rightAnchor, constant: -70).isActive = true

    name.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    name.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
    name.rightAnchor.constraint(greaterThanOrEqualTo: dialCode.leftAnchor).isActive = true
    name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupCell(for country: Country) {
    name.text = country.name
    dialCode.text = country.dialCode
    accessoryType = country.isSelected ? .checkmark : .none
  }
}
