//
//  ParticipantTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ParticipantTableViewCell: UITableViewCell {

    weak var selectParticipantsController: SelectParticipantsController!

    var gestureReconizer: UITapGestureRecognizer!

    var icon: UIImageView = {
        var icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFill
        icon.layer.cornerRadius = 30
        icon.layer.masksToBounds = true
        icon.image = UIImage(named: "UserpicIcon")

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
        subtitle.font = UIFont.systemFont(ofSize: 15)
        subtitle.textColor = ThemeManager.currentTheme().generalSubtitleColor

        return subtitle
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryView?.tintColor = ThemeManager.currentTheme().tintColor
        gestureReconizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(gestureReconizer)

        backgroundColor = .clear
        title.backgroundColor = backgroundColor
        icon.backgroundColor = backgroundColor

        contentView.addSubview(icon)
        icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true

        contentView.addSubview(title)
//        title.topAnchor.constraint(equalTo: icon.topAnchor, constant: 0).isActive = true
        title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 15).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
//        title.heightAnchor.constraint(equalToConstant: 23).isActive = true

//        contentView.addSubview(subtitle)
//        subtitle.bottomAnchor.constraint(equalTo: icon.bottomAnchor, constant: 0).isActive = true
//        subtitle.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 15).isActive = true
//        subtitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
//        subtitle.heightAnchor.constraint(equalToConstant: 23).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func cellTapped() {
        hapticFeedback(style: .selectionChanged)
        guard let indexPath = selectParticipantsController.tableView.indexPathForView(self) else { return }

        if isSelected {
            selectParticipantsController.didDeselectUser(at: indexPath)
            isSelected = false
        } else {
            selectParticipantsController.didSelectUser(at: indexPath)
        isSelected = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        icon.image = UIImage(named: "UserpicIcon")
        title.text = ""
        subtitle.text = ""
        title.textColor = ThemeManager.currentTheme().generalTitleColor
        subtitle.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
