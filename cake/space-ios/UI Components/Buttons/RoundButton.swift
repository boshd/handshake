//
//  File.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-07-11.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    
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
    
    // MARK: - Setup
    
    /// Sets up the default properties
    open func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        titleLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        titleLabel?.font = UIFont(name: "PlayfairDisplay-BoldItalic", size: 18)
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.cornerRadius = 40
    }
 
    
}
