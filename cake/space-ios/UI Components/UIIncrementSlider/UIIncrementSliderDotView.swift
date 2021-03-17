//
//  UIIncrementSliderDotView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class UIIncrementSliderDotView: UIView {

    static let dotSize: CGFloat = 6

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = UIIncrementSliderDotView.dotSize / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

