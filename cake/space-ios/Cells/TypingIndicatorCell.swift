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

    override init(frame: CGRect) {
        super.init(frame: frame.integral)

        addSubview(typingIndicator)
        typingIndicator.frame = CGRect(x: 10, y: 2, width: 72, height: TypingIndicatorCell.typingIndicatorHeight).integral
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
        typingIndicator.backgroundColor = ThemeManager.currentTheme().inputTextViewColor
        if typingIndicator.isAnimating {
        typingIndicator.stopAnimating()
        typingIndicator.startAnimating()
        } else {
        typingIndicator.startAnimating()
        }
    }
    
}
