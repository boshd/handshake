//
//  UserExistenceChecker.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-11.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol UserExistenceDelegate: class {
    func user(userExists: Bool, channelIds: [String]?)
    func error()
}

final class UserExistenceChecker: NSObject {
    
    fileprivate var isNameExists: Bool?
    fileprivate var isBioExists: Bool?
    fileprivate var isPhotoExists: Bool?
    
    fileprivate var exists: Bool?

    fileprivate var name: String?
    fileprivate var bio: String?
    fileprivate var photo: UIImage?
    
    weak var delegate: UserExistenceDelegate?
    
//    fileprivate func checkUserData() {
//        guard let userExists = exists else { return }
//        delegate?.user(userExists: userExists)
        
//        guard let isNameExistsVal = isPhotoExists else { return }
//        delegate?.user(isAlreadyExists: isNameExistsVal, name: name , bio: bio, image: photo)
//    }
    
    func checkIfUserDataExists() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userReference = Firestore.firestore().collection("users").document(currentUserID)
        
        userReference.getDocument { (snapshot, error) in
            if error != nil {
                print("\(error?.localizedDescription ?? "error") nope")
                self.delegate?.error()
                return
            }
            guard let snapshot = snapshot else {
                self.delegate?.error()
                return
            }
            if snapshot.exists {
                userReference.collection("channelIds").getDocuments { (snapshot, error) in
                    if error != nil { print(error?.localizedDescription ?? "error"); self.delegate?.error(); return }
                    guard let snapshot = snapshot else { self.delegate?.error(); return }
                    if snapshot.isEmpty {
                        self.delegate?.user(userExists: true, channelIds: nil)
                    } else {
                        self.delegate?.user(userExists: true, channelIds: snapshot.documents.map({ $0.documentID }))
                    }
                }
            } else {
                self.delegate?.user(userExists: false, channelIds: nil)
            }
        }
    }
    
}
