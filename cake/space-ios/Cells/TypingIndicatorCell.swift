//
//  TypingIndicatorCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class TypingIndicatorCell: UICollectionViewCell {
  
static let typingIndicatorHeight: CGFloat = 30

    var typingIndicator: TypingBubble = {
        var typingIndicator = TypingBubble()
        typingIndicator.typingIndicator.isBounceEnabled = true
        typingIndicator.typingIndicator.isFadeEnabled = true
        typingIndicator.isPulseEnabled = true

        return typingIndicator
    }()
    
    var label: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Someone is typing..."
        label.textColor = .handshakeGreen
        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 10)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame.integral)
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
        
        //addSubview(typingIndicator)
        //typingIndicator.frame = CGRect(x: 10, y: 2, width: 72, height: TypingIndicatorCell.typingIndicatorHeight).integral
        label.frame = CGRect(x: 15, y: 2, width: 250, height: label.frame.height).integral
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        restart()
    }

    deinit {
        typingIndicator.stopAnimating()
    }

    func restart() {
//        typingIndicator.backgroundColor = ThemeManager.currentTheme().inputTextViewColor
//        if typingIndicator.isAnimating {
//        typingIndicator.stopAnimating()
//        typingIndicator.startAnimating()
//        } else {
//        typingIndicator.startAnimating()
//        }
    }
    
}
