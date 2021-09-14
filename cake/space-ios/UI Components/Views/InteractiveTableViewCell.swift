//
//  InteractiveTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class InteractiveTableViewCell: UITableViewCell {
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        shrink(down: highlighted)
    }
    
    func shrink(down: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction], animations: {
            if down {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } else {
                self.transform = .identity
            }
        }, completion: nil)
        
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

