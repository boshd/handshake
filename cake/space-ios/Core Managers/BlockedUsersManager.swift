//
//  BlockedUsersManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-09.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Foundation
import Firebase

let blockedUsersManager = BlockedUsersManager()

final class BlockedUsersManager: NSObject {

    let initialize = true
    
    fileprivate var currentUserBlockedBy = [String]()
    fileprivate(set) var blockedUsersByCurrentUser = [String]()
    
    override init() {
        super.init()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(getBlockedUsers), name: .authenticationSucceeded, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func getBlockedUsers() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentUserId = Auth.auth().currentUser?.uid else { return }
            
            let currentUserReference = Firestore.firestore().collection("users").document(currentUserId)
            
            currentUserReference.getDocument { (snapshot, error) in
                if error != nil {
                    print("error // \(String(describing: error?.localizedDescription))")
                    return
                }
                
                guard let userDict = snapshot?.data() else { return }
                guard let bannedIds = userDict["banned"] else { return }
                guard let bannedByIds = userDict["bannedBy"] else { return }
                
                self.blockedUsersByCurrentUser = bannedIds as! [String]
                self.currentUserBlockedBy = bannedByIds as! [String]
            }
        }
    }
    
    func removeBannedUsers(users: [User]) -> [User] {
        var users = users
        blockedUsersByCurrentUser.forEach { (blockedUID) in
            guard let index = users.firstIndex(where: { (user) -> Bool in
                return user.id == blockedUID
            }) else { return }
            users.remove(at: index)
        }
        return users
    }
}
