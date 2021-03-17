//
//  ParticipantCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-10-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class ParticipantCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
        
        contentView.addSubview(imageView)
        
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
        ])
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        //imageView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = ThemeManager.currentTheme().generalBackgroundColor.cgColor
        
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.layer.borderColor = ThemeManager.currentTheme().generalBackgroundColor.cgColor
        backgroundColor = .clear
//        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
    }
    
}
