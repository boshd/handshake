//
//  CurrentUserTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class CurrentUserTableViewCell: UITableViewCell {

    var icon: UIImageView = {
        var icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        icon.layer.cornerRadius = iconDefaultCornerRadius
        icon.layer.masksToBounds = true
        // icon.image = ThemeManager.currentTheme().personalStorageImage

        return icon
    }()

    var title: UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = ThemeManager.currentTheme().secondaryFontBold(with: 15)
        title.textColor = ThemeManager.currentTheme().generalTitleColor
        return title
    }()

    var iconWidthAnchor: NSLayoutConstraint!
    var iconHeightAnchor: NSLayoutConstraint!

    static let iconSizeDefaultConstant: CGFloat = 50
    static let iconSizeLargeConstant: CGFloat = 70
    static let iconDefaultCornerRadius: CGFloat = iconSizeDefaultConstant * 0.5
    static let iconLargreCornerRadius: CGFloat = iconSizeLargeConstant * 0.5

    let spacing: CGFloat = 15
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        title.backgroundColor = backgroundColor
        icon.backgroundColor = backgroundColor

        contentView.addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
        iconWidthAnchor = icon.widthAnchor.constraint(equalToConstant: CurrentUserTableViewCell.iconSizeDefaultConstant)
        iconWidthAnchor.isActive = true
        iconHeightAnchor = icon.heightAnchor.constraint(equalToConstant: CurrentUserTableViewCell.iconSizeDefaultConstant)
        iconHeightAnchor.isActive = true

        contentView.addSubview(title)
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor, constant: 0).isActive = true
        title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: spacing).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
        title.heightAnchor.constraint(equalToConstant: CurrentUserTableViewCell.iconSizeDefaultConstant).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // icon.image = ThemeManager.currentTheme().personalStorageImage
        title.text = ""
        title.textColor = ThemeManager.currentTheme().generalTitleColor
    }
}
