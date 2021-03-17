//
//  Validators.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-06.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

struct TextFieldValidator {
    // Check for the existence of an empty text field, variadic input
    static func emptyFieldExists(_ textFields: UITextField...) -> Bool {
        for field in textFields {
            if field.text!.isEmpty {
                return true
            }
        }
        return false
    }
    
    // Check for the existence of an empty text field, array input
    static func emptyFieldExists(_ textFields: [UITextField]) -> Bool {
        for field in textFields {
            if field.text!.isEmpty {
                return true
            }
        }
        return false
    }
}

struct EmailValidator {
    // Checks if an email is an invalid email
    static func invalidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return !test.evaluate(with: email)
    }
}

struct PasswordValidator {
    
    // Checks if a password is greater than 6 characters
    static func passwordInvalidLength(_ password: String) -> Bool {
        return password.count < 6
    }
    
    // Checks if password contains atleast one number and one capital letter
    static func passwordTooWeak(_ password: String) -> Bool {
        let capitalSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let numberSet = CharacterSet(charactersIn: "0123456789")
        return password.rangeOfCharacter(from: capitalSet) == nil || password.rangeOfCharacter(from: numberSet) == nil
    }
}

struct NameValidator {
    
    // Checks if username only uses valid characters: A-Z, a-z, and _
    static func invalidCharactersIn(name: String) -> Bool {
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
        return name.rangeOfCharacter(from: characterSet.inverted) != nil
    }
//    
//    // Checks if username is between 4 & 15 characters
//    static func nameInvalidLength(_ name: String) -> Bool {
//        return name.count < 4 || name.count > 15
//    }
}
