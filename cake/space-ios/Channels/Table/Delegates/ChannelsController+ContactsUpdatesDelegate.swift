//
//  ChannelsController+ContactsUpdatesDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Contacts

extension ChannelsController: ContactsUpdatesDelegate {
    func contacts(shouldPerformSyncronization: Bool) {
        
        isSyncingUsers = true
        
        guard shouldPerformSyncronization else { print("stuck in return"); return }
        showActivityTitle(title: .updatingUsers)
//        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadAndSyncUsers()
        }
    }

    func contacts(updateDatasource contacts: [CNContact]) {
        self.contacts = contacts
        self.filteredContacts = contacts
    }

    func contacts(handleAccessStatus: Bool) {
        contactsPermissionGranted = true
    }
}
