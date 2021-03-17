//
//  VerticalTitleSubtitleView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-03.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class VerticalTitleSubtitleView: UIView {
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var caption: DynamicLabel = {
        var caption = DynamicLabel(withInsets: 0, 0, 0, 0)
        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.font = ThemeManager.currentTheme().primaryFont(with: 15)
        caption.textColor = .black
        caption.text = "event date"
        
        return caption
    }()
    
//   
    
    // MARK: - Setup
    
    /// Sets up the default properties
    open func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.cornerRadius = 40
    }
 
    
}
