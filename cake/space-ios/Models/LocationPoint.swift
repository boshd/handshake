//
//  LocationPoint.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-28.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import RealmSwift

class Location: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var locationDescription: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
}
