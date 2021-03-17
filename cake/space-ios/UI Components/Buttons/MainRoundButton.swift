//
//  MainRoundButton.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-08.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class MainRoundButton: UIButton {
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        shrink(down: highlighted)
//    }
  
    override var isHighlighted: Bool {
        didSet {
            shrink(down: isHighlighted)
        }
    }
    
    func shrink(down: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction], animations: {
            if down {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } else {
                self.transform = .identity
            }
        }, completion: nil)
        
    }
    
    // MARK: - Initialization
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().buttonColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        tintColor = ThemeManager.currentTheme().buttonIconColor
        imageView?.contentMode = .scaleAspectFit
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    
}

