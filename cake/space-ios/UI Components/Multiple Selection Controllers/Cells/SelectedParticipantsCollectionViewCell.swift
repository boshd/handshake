//
//  SelectedParticipantsCollectionViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class SelectedParticipantsCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lighterGray()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22.5
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "UserpicIcon")
        
        return imageView
    }()
    
    var title: DynamicLabel = {
        var title = DynamicLabel(withInsets: 0, 0, 0, 0)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        title.textColor = ThemeManager.currentTheme().generalTitleColor
        title.textAlignment = .center
        title.numberOfLines = 2
        return title
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 10
        backgroundColor = .clear
        title.backgroundColor = backgroundColor
        
        contentView.addSubview(imageView)
        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalToConstant: 45),
            imageView.widthAnchor.constraint(equalToConstant: 45),
            
            title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = ""
        imageView.image = UIImage(named: "UserpicIcon")
    }

}
