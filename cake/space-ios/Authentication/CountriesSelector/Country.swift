//
//  Country.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-11.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

final class Country: NSObject {

  @objc var name: String?
  var code: String?
  var dialCode: String?
  var isSelected = false

  init(dictionary: [String: String]) {
    super.init()

    name = dictionary["name"]
    code = dictionary["code"]
    dialCode = dictionary["dial_code"]
  }
}

