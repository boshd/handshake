//
//  GlobalVariables.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-09.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Contacts

let globalVariables = GlobalVariables()

final class GlobalVariables: NSObject {
    // let reportDatabaseURL = "https://pigeon-project-79c81-d6fdd.firebaseio.com/"
    var isInsertingCellsToTop: Bool = false
    var contentSizeWhenInsertingToTop: CGSize?
    var localPhones: [String] = [] {
        didSet {
            NotificationCenter.default.post(name: .localPhonesUpdated, object: nil)
        }
    }
    
    var localContacts: [CNContact] = [] {
        didSet {
            NotificationCenter.default.post(name: .localContactsUpdated, object: nil)
        }
    }
    
    var localContactsDict: [String:CNContact] = [:] {
        didSet {
            NotificationCenter.default.post(name: .localContactsUpdated, object: nil)
        }
    }
    
    var localIdPhoneDict: [String:[String]] = [:] {
        didSet {
            NotificationCenter.default.post(name: .localNamePhoneDictUpdated, object: nil)
        }
    }
    
    var fetchedLocalIdPhoneDict: [String:String] = [:] {
        didSet {
            //NotificationCenter.default.post(name: .localNamePhoneDictUpdated, object: nil)
        }
    }
}

extension NSNotification.Name {
    static let profilePictureDidSet = NSNotification.Name(Bundle.main.bundleIdentifier! + ".profilePictureDidSet")
    static let blockedListUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".blacklistUpdated")
    static let localPhonesUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".localPhones")
    static let localContactsUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".localContacts")
    static let localNamePhoneDictUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".localNamePhoneDict")
    static let authenticationSucceeded = NSNotification.Name(Bundle.main.bundleIdentifier! + ".authenticationSucceeded")
    static let inputViewResigned = NSNotification.Name(Bundle.main.bundleIdentifier! + ".inputViewResigned")
    static let inputViewResponded = NSNotification.Name(Bundle.main.bundleIdentifier! + ".inputViewResponded")
    static let messageSent = NSNotification.Name(Bundle.main.bundleIdentifier! + ".messageSent")
    static let currentUserDidChange = NSNotification.Name(Bundle.main.bundleIdentifier! + ".currentUserDidChange")
    
    static let memberAdded = NSNotification.Name(Bundle.main.bundleIdentifier! + ".memberAdded")
    static let memberRemoved = NSNotification.Name(Bundle.main.bundleIdentifier! + ".memberRemoved")
    static let channelUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".channelUpdated")
    
    static let channelRemoved = NSNotification.Name(Bundle.main.bundleIdentifier! + ".channelRemoved")
    static let channelAdded = NSNotification.Name(Bundle.main.bundleIdentifier! + ".channelAdded")
    
    static let channlStatusUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".channlStatusUpdated")
    
    static let deleteAndExit = NSNotification.Name(Bundle.main.bundleIdentifier! + ".deleteAndExit")
    
    static let eventCancelled = NSNotification.Name(Bundle.main.bundleIdentifier! + ".eventCancelled")
}

