//
//  ChannelDescriptionCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelDescriptionCell: UITableViewCell {
    /*
     must be an expandable cell for "Read more.." functionality
     */
    
    //let originalText = "So how did the classical Latin become so incoherent? According to McClintock, a 15th century typesetter likely scrambled part of Cicero's De Finibus in order to provide placeholder text to mockup various fonts for a type specimen book. It's difficult to find examples of lorem ipsum in use before Letraset made it popular as a dummy text in the 1960s, although McClintock says he remembers coming across the lorem ipsum passage in a book of old metal type samples. So far he hasnt relocated where he once saw the passage, but the popularity of Cicero in the 15th century supports the theory that the filler text has been used for centuries. So how did the classical Latin become so incoherent? According to McClintock, a 15th century typesetter likely scrambled part of Cicero's De Finibus in order to provide placeholder text to mockup various fonts for a type specimen book.\n\nIt's difficult to find examples of lorem ipsum in use before Letraset made it popular as a dummy text in the 1960s, although McClintock says he remembers coming across the lorem ipsum passage in a book of old metal type samples. So far he hasnt relocated where he once saw the passage, but the popularity of Cicero in the 15th century supports the theory that the filler text has been used for centuries. It's difficult to find examples of lorem ipsum in use before Letraset made it popular as a dummy text in the 1960s, although McClintock says he remembers coming across the lorem ipsum passage in a book of old metal type samples. So far he hasnt relocated where he once saw the passage, but the popularity of Cicero in the 15th century supports the theory that the filler text has been used for centuries. It's difficult to find examples of lorem ipsum in use before Letraset made it popular as a dummy text in the 1960s, although McClintock says he remembers coming across the lorem ipsum passage in a book of old metal type samples.\n\nSo far he hasnt relocated where he once saw the passage, but the popularity of Cicero in the 15th century supports the theory that the filler text has"
    
    lazy var textView: ReadMoreTextView = {
        let textView = ReadMoreTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        textView.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textView.textColor = ThemeManager.currentTheme().generalSubtitleColor
        let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().tintColor,
            NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 12)
        ]
        let readLessTextAttributes = [
            NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().tintColor,
            NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 12)
        ]
        textView.attributedReadMoreText = NSAttributedString(string: "... Read more", attributes: readMoreTextAttributes)
        textView.attributedReadLessText = NSAttributedString(string: " Read less", attributes: readLessTextAttributes)
        textView.maximumNumberOfLines = 3
        textView.shouldTrim = true
        textView.layoutIfNeeded()
        textView.isSelectable = false
        return textView
    }()
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        userInteractionEnabledWhileDragging = false
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none
        
        contentView.addSubview(textView)
 
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        textView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    }
    
}


