//
//  InformationMessageCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-22.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class InformationMessageCell: RevealableCollectionViewCell {
    
    var blurView:BlurView {
        let  blurview = BlurView()
        blurview.translatesAutoresizingMaskIntoConstraints = false
        
        return blurview
    }
    
    lazy var information: DynamicLabel = {
        var information = DynamicLabel(withInsets: 3, 3, 3, 3)
        information.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        information.textAlignment = .center
        information.textColor = ThemeManager.currentTheme().informationMessageTextColor
        information.numberOfLines = 0
        information.translatesAutoresizingMaskIntoConstraints = false
        information.layer.masksToBounds = true

        return information
    }()

    func setupData(message: Message) {
        guard let messageText = message.text else { return }
        information.text = messageText
    }

    override init(frame: CGRect) {
        super.init(frame: frame.integral)
        backgroundColor = .clear

        addSubview(information)

        NSLayoutConstraint.activate([
            information.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            information.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            information.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        information.textColor = ThemeManager.currentTheme().informationMessageTextColor
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
