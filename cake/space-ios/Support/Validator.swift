//
//  Validator.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation

struct ChannelValidator {
    
    public func isChannelNameGood(name: String) -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty || name.count > 25 {
            return false
        }
        return true
    }
    
    public func areDatesValid(start: Int, end: Int) -> Bool {
        if start > end {
            return false
        }
        return true
    }
    
}
