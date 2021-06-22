//
//  ParticipantsController+SelectedUsersDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-08.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension ParticipantsController: SelectedUsersDelegate {
    func selectedUsers(shouldBeUpdatedTo selectedUsers: [User]) {
        if self.participants != nil {
            self.reloadTable()
        }
    }
}
