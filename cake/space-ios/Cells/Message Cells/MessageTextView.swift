//
//  MessageTextView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-06-02.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class MessageTextView: UITextView {
    
    convenience init() {
        self.init(frame: .zero)
        
        backgroundColor = .clear
        isEditable = false
        isScrollEnabled = false
        isUserInteractionEnabled = true
        isSelectable =  true
        
        dataDetectorTypes = .all
        linkTextAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 12)
        ]
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let pos = closestPosition(to: point) else { return false }
        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: UITextDirection(rawValue: UITextLayoutDirection.left.rawValue)) else { return false }
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        
        return attributedText.attribute(NSAttributedString.Key.link, at: startIndex, effectiveRange: nil) != nil
    }
}
