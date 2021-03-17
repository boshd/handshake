//
//  GlobalSettings.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-08.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {

            if let data = UserDefaults.standard.object(forKey: key) as? Data,
                let user = try? JSONDecoder().decode(T.self, from: data) {
                return user

            }

            return  defaultValue
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }
}

//enum GlobalSettings {
//    @UserDefault("currentUser", defaultValue: User()) static var currentUser: User
//}
