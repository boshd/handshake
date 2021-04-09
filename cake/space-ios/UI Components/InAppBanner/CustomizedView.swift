//
//  CustomizedView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class CustomizedView: UIView {
    
//    override var cornerRadius: CGFloat {
//        didSet {
//            self.layer.cornerRadius = cornerRadius
//        }
//    }
//
//    override var borderWidth: CGFloat {
//        didSet {
//            self.layer.borderWidth = borderWidth
//        }
//    }
    
//    override var borderColor: UIColor {
//        didSet {
//            self.layer.borderColor = borderColor.cgColor
//        }
//    }
    
    func removeGestureRecgonizers() {
        guard let _gestureReognizers = gestureRecognizers else { return }
        for gestureRecognizer in _gestureReognizers {
            removeGestureRecognizer(gestureRecognizer)
        }
    }
}

