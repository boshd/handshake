//
//  TimestampView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-06-02.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit

class TimestampView: RevealableView {
    
    @IBOutlet var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textColor = .green
        titleLabel.backgroundColor = .black
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
