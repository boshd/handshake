//
//  ChannelsController+UsersUpdatesDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelsController: UsersUpdatesDelegate {
    func users(shouldBeUpdatedTo users: [User]) {
        hideActivityTitle(title: .updatingUsers)
        isSyncingUsers = false
        
        if users.count > 0 {
            autoreleasepool {
                if !realm.isInWriteTransaction {
                    realm.beginWrite()
                    for user in users {
                        realm.create(User.self, value: user, update: .modified)
                    }
                    try! realm.commitWrite()
                }
            }
        }

        let syncronizationStatus = userDefaults.currentBoolObjectState(for: userDefaults.contactsSyncronizationStatus)
        guard syncronizationStatus == true else { return }
        addContactsObserver()
//        DispatchQueue.main.async { [weak self] in
//            self?.hideActivityTitle(title: .updatingUsers)
//        }
        
    }
}
