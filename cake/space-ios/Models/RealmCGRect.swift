//
//  RealmCGRect.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-09.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import RealmSwift

final class RealmCGRect: Object {
    @objc dynamic var id: String?
    let x =  RealmOptional<Double>()
    let y = RealmOptional<Double>()
    let width = RealmOptional<Double>()
    let height = RealmOptional<Double>()

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(_ cgRect: CGRect, id: String) {
        self.init()
        self.id = id
        x.value = Double(cgRect.origin.x)
        y.value = Double(cgRect.origin.y)
        width.value = Double(cgRect.size.width)
        height.value = Double(cgRect.size.height)
    }
}
