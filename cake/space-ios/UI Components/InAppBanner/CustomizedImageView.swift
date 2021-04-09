//
//  CustomizedImageView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class CustomizedImageView: UIImageView {
//    override var cornerRadius: CGFloat = 0.0 {
//        didSet {
//          self.layer.cornerRadius = cornerRadius
//        }
//    }
//    
//    override var borderWidth: CGFloat = 0.0 {
//        didSet {
//          self.layer.borderWidth = borderWidth
//        }
//    }
//    
//    var borderColor: UIColor = UIColor.clear {
//        didSet {
//          self.layer.borderColor = borderColor.cgColor
//        }
//    }
//    
    func removeGestureRecgonizers() {
        guard let _gestureReognizers = gestureRecognizers else { return }
        for gestureRecognizer in _gestureReognizers {
          removeGestureRecognizer(gestureRecognizer)
        }
    }
}
