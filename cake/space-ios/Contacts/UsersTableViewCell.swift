//
//  UsersTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import SDWebImage
import Contacts

class UsersTableViewCell: InteractiveTableViewCell {

    var icon: UIImageView = {
        var icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        icon.layer.cornerRadius = 25
        icon.layer.masksToBounds = true
        icon.image = UIImage(named: "UserpicIcon")
        icon.backgroundColor = .lighterGray()

        return icon
    }()

    var title: DynamicLabel = {
        var title = DynamicLabel(withInsets: 0, 0, 0, 0)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        title.textColor = ThemeManager.currentTheme().generalTitleColor

        return title
    }()

    var subtitle: UILabel = {
        var subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.font = UIFont.systemFont(ofSize: 14.5)
        subtitle.textColor = ThemeManager.currentTheme().generalSubtitleColor

        return subtitle
    }()

    let spacing: CGFloat = 15

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        backgroundColor = .clear
        title.backgroundColor = backgroundColor
        icon.backgroundColor = backgroundColor

        contentView.addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 50).isActive = true

        contentView.addSubview(title)
        title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: spacing).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing).isActive = true
        title.heightAnchor.constraint(equalToConstant: 25).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
  }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        icon.image = UIImage(named: "UserpicIcon")
        icon.sd_cancelCurrentImageLoad()
        title.text = ""
        subtitle.text = ""
        title.textColor = ThemeManager.currentTheme().generalTitleColor
        subtitle.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }

    func configureCell(for parameter: NSObject?) {
        guard let parameter = parameter else { return }
        if let contact = parameter as? CNContact {
            configureContact(contact)
        } else if let user = parameter as? User {
            configureUser(user)
        }
    }

    fileprivate func configureUser(_ user: User) {
        
        if let name = user.localName {
            title.text = name
        } else if let name = user.name {
            title.text = name
        }

        guard let urlString = user.userThumbnailImageUrl else { return }
        let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
        let placeholder = UIImage(named: "UserpicIcon")
        icon.sd_setImage(with: URL(string: urlString),
        placeholderImage: placeholder,
        options: options) { (image, error, cacheType, _) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            guard image != nil else { return }
            guard cacheType != .memory, cacheType != .disk else {
                self.icon.image = image
                return
            }
            UIView.transition(with: self.icon, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.icon.image = image
            }, completion: nil)
        }
    }

    fileprivate func configureContact(_ contact: CNContact) {
        title.text = contact.givenName + " " + contact.familyName

        if let thumbnail = contact.thumbnailImageData {
            icon.image = UIImage(data: thumbnail)
        } else {
            icon.image = UIImage(named: "UserpicIcon")
        }

        if contact.phoneNumbers.indices.contains(0) {
            let phoneNumber = contact.phoneNumbers[0].value.stringValue
            subtitle.text = phoneNumber
        } else {
            subtitle.text = "No phone number provided"
        }
    }
}
