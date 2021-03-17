////
////  UsersService.swift
////  space-ios
////
////  Created by Kareem Arab on 2019-06-07.
////  Copyright © 2019 Kareem Arab. All rights reserved.
////
//
//import Foundation
//import Firebase
//import Contacts
//import FirebaseFirestore
//
//class UsersService: NSObject {
//    
//    static func getUserWith(_ id: String, completion: @escaping (User) -> Void ) {
//        guard (Auth.auth().currentUser?.uid) != nil else { print("its nil"); return }
//        let userReference = Firestore.firestore().collection("users").document(id)
//        
//        userReference.getDocument { (snapshot, error) in
//            if error != nil {
//                print("error // \(error?.localizedDescription ?? "err")")
//                return
//            }
//            
//            guard let dictionary = snapshot?.data() else { return }
//            
//            let user = User(dictionary: dictionary as [String : AnyObject])
//            
//            completion(user)
//        }
//       
//    }
//    
//    static func getCurrentUserChannelIDs(completion: @escaping ([String]) -> Void) {
//        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//        var channelIDs: [String] = []
//        let reference = Firestore.firestore().collection("users").document(currentUserID)
//        
//        reference.collection("channelIds").getDocuments { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("error // ", error!)
//                return
//            }
//
//            for document in documents {
//                channelIDs.append(document.documentID)
//            }
//            completion(channelIDs)
//        }
//    }
//    
//}
