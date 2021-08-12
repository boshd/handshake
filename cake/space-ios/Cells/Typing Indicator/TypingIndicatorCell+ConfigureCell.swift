//
//  TypingIndicatorCell+ConfigureCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-08-12.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation
import RealmSwift

extension TypingIndicatorCell {
    
    func configureCell(for typingUserIds: [String]) {
        
        if typingUserIds.count == 1 {
            print("its 1 person")
            if let typingUserId = typingUserIds.first {
                getName(for: typingUserId) { name in
//                    self.label.text = "\(name)"
                    print("arrive")
                    self.currentLabelText = name
                }
            }
        } else if typingUserIds.count > 1 {
            let group = DispatchGroup()
            var names = [String]()
            
            for typingUserId in typingUserIds {
                group.enter()
                getName(for: typingUserId) { name in
                    group.leave()
                    names.append(name)
                }
            }
            
            group.notify(queue: .main) {
                // strigify names
                self.currentLabelText = "\(names)"
                var printableNameList: String?
                
                if names.count > 3 {
                    for (index, name) in names.enumerated() {
                        if index < 3 {
                            if printableNameList == nil {
                                printableNameList = name
                            } else {
                                printableNameList! += ", " + name
                            }
                        } else {
                            printableNameList! += " and \(names.count - 3) more"
                            return
                        }
                    }
                } else {
                    for name in names {
                        if printableNameList == nil {
                            printableNameList = name
                        } else {
                            printableNameList! += ", " + name
                        }
                    }
                }
                

            }
            
        }
        
        
    }
    
    func getName(for id: String, completion: @escaping (String) -> ()) {
        if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == id }),
           let name = realmUser.localName {
            completion(name)
        } else if let nonLocalRealmUser = RealmKeychain.realmNonLocalUsersArray().first(where: { $0.id == id }),
                  let phone = nonLocalRealmUser.phoneNumber {
            completion(phone)
        } else {
            // fetch user once and add to non local realm
            UsersFetcher.fetchUser(id: id) { user, error in
                guard error == nil else { print(error?.localizedDescription ?? ""); completion("somoene"); return }
                // issues w/ initial state
                if let user = user {
                    if let number = user.phoneNumber {
                        completion(number)
                    } else {
                        completion("somoene")
                    }
                    self.addToRealm(user: user)
                } else {
                    completion("somoene")
                }
            }
        }
    }
    
    fileprivate func addToRealm(user: User) {
        let nonLocalRealm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
        autoreleasepool {
            if !nonLocalRealm.isInWriteTransaction {
                nonLocalRealm.beginWrite()
                nonLocalRealm.create(User.self, value: user, update: .modified)
                try! nonLocalRealm.commitWrite()
            }
        }
    }
    
}

/*
 var printableNameList: String?
 for name in names {
     if printableNameList == nil {
         printableNameList = name
     } else {
         printableNameList! += ", " + name
     }
 }
 
 return "\(printableNameList ?? "") are typing..."
 
 */
