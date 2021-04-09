//
//  Utils.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation

class Utils {
    static let shared = Utils()
    private init() {}
    
    var bundle: Bundle { return Bundle(for: type(of: self)) }
}
