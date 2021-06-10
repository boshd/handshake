//
//  InteractiveButton.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class InteractiveButton: UIButton {
    
    var scaler: CGFloat = 0.95
    
    override var isHighlighted: Bool {
        didSet {
            shrink(down: isHighlighted)
        }
    }
    
    func shrink(down: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction], animations: {
            if down {
                self.transform = CGAffineTransform(scaleX: self.scaler, y: self.scaler)
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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    
}
