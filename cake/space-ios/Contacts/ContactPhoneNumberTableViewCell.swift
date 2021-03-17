//
//  ContactPhoneNumberTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Contacts

class ContactPhoneNumberTableViewCell: UITableViewCell {

    var title: UILabel = {
        var title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)

        return title
    }()

    var subtitle: UILabel = {
        var subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.font = UIFont.systemFont(ofSize: 15)
        subtitle.textColor = ThemeManager.currentTheme().generalTitleColor

        return subtitle
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        title.backgroundColor = backgroundColor

        contentView.addSubview(title)
        title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        title.heightAnchor.constraint(equalToConstant: 18).isActive = true

        contentView.addSubview(subtitle)
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5).isActive = true
        subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor).isActive = true
        subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor).isActive = true
        subtitle.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = ""
        subtitle.text = ""
        title.textColor = tintColor
        subtitle.textColor = ThemeManager.currentTheme().generalTitleColor
    }

    func configureCell(contact: CNLabeledValue<CNPhoneNumber>) {
        title.text = CNLabeledValue<NSString>.localizedString(forLabel: contact.label ?? "")
        subtitle.text = contact.value.stringValue
    }
}

