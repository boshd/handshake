//
//  CustomAlertAction.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-03.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation

class CustomAlertAction: NSObject {
    
    var title_: String?
    var style: Style?
    let handler: (() -> Void)?
    
    var isEnabled: Bool = true
    
    init(title: String?, style: CustomAlertAction.Style, handler: (() -> Void)? = nil) {
        self.title_ = title
        self.style = style
        self.handler = handler
    }
    
}

extension CustomAlertAction {
    enum Style : Int {
        case `default` = 0
        case cancel = 1
        case destructive = 2
    }
}
