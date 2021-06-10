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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.text = "So how did the classical Latin become so incoherent? According to McClintock, a 15th century typesetter likely scrambled part of Cicero's De Finibus in order to provide placeholder text to mockup various fonts for a type specimen book.\n\n It's difficult to find examples of lorem ipsum in use before Letraset made it popular as a dummy text in the 1960s, although McClintock says he remembers coming across the lorem ipsum passage in a book of old metal type samples. So far he hasnt relocated where he once saw the passage, but the popularity of Cicero in the 15th century supports the theory that the filler text has been used for centuries."
        
        backgroundColor = .clear
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }
    
}

