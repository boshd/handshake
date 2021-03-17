//
//  UIView+Extensions.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-02.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

extension UIView {
  var safeYCoordinate: CGFloat {
    let y: CGFloat
    if #available(iOS 11.0, *) {
      y = safeAreaInsets.top
    } else {
      y = 0
    }

    return y
  }

  var isiPhoneX: Bool {
    return safeYCoordinate > 20
  }
}
