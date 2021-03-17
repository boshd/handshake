////
////  FirebaseService.swift
////  space-ios
////
////  Created by Kareem Arab on 2019-05-31.
////  Copyright © 2019 Kareem Arab. All rights reserved.
////
//
//import Firebase
//import FirebaseFirestore
//
//class FirebaseService {
//    
//    static func createChannel(authorID: String?, participantIDs: [String], channelName: String, bio: String, dateTimestamp: Timestamp, completion: @escaping (_ channel: Channel?) -> Void) {
//        guard let uid = authorID else { return }
//        
//        let channelsRef = Firestore.firestore().collection("channels")
//        let newChannelRef = channelsRef.document()
//        let channelDict: [String: Any] = [
//            "lastMessage": "You created channel \(channelName)",
//            "lastMessageTimeStamp": NSNumber(value: Int(Date().timeIntervalSince1970)),
//            "channelName": channelName,
//            "authorID": uid,
//            "participantIDs": participantIDs,
//            "channelID": newChannelRef.documentID,
//            "channelImageURL": "",
//            "isGroup": true,
//            "adminID": uid,
//            "bio": bio,
//            "dateTimestamp": dateTimestamp
//        ]
//        newChannelRef.setData(channelDict)
//        
//        let usersRef = Firestore.firestore().collection("users")
//        
//        // Adds channel ID to user
//        let userRef = usersRef.document(uid)
//        userRef.updateData([
//            "channelIds": FieldValue.arrayUnion([newChannelRef.documentID])
//        ])
//
//        // Adds channel ID to all other users
//        for participantID in participantIDs {
//            let userRef = usersRef.document(participantID)
//            userRef.updateData([
//                "channelIds": FieldValue.arrayUnion([newChannelRef.documentID])
//            ])
//        }
//        completion(Channel(dictionary: channelDict as [String : AnyObject]))
//    }
//    
//    static func updateChannel(channelID: String, imageUrl: String, channelName: String, bio: String, date: Date, completion: @escaping () -> Void) {
//        Firestore.firestore().collection("channels").document(channelID).updateData([
//            "channelImageURL": imageUrl,
//            "channelName": channelName,
//            "bio": bio,
//            "date": date
//        ])
//    }
//    
//    static func createUser(name: String, email: String, password: String, phoneNumber: String, completion: @escaping () -> Void ) {
//        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
//            guard let user = authResult?.user, error == nil else {
//                print(error!.localizedDescription)
//                return
//            }
//            
//            // Add to database
//            let usersRef = Firestore.firestore().collection("users")
//            let newUserRef = usersRef.document(user.uid)
//            let userDict: [String: Any] = [
//                "id": user.uid,
//                "email": user.email ?? "",
//                "name": name ,
//                "bio": "take a chill pill",
//                "photoURL": "https://cdn.cultofmac.com/wp-content/uploads/2018/08/image-3.5ef142f065894e6bb1e906206cf0d407-780x585.jpg",
//                "thumbnailPhotoURL": "",
//                "phoneNumber": phoneNumber,
//                "onlineStatus": "Offline"
//            ]
//            newUserRef.setData(userDict)
//        }
//    }
//    
//    static func fetchAllCurrentIDChannels(completion: @escaping ([Channel]) -> Void ) {
//        
//
//    }
//    
//    static func saveMessage(_ channelID: String, message: Message, completion: @escaping () -> Void ) {
//
//        // Add to database
////        let channelsRef = Firestore.firestore().collection("channels")
////        let channelRef = channelsRef.document(channelID)
//        
////        let messageData = message.representation
//
////        channelRef.updateData([
////            "messages": FieldValue.arrayUnion([messageData])
////        ])
////
////        channelRef.updateData([
////            "lastMessage": message.text as Any,
////            "id": message.id as Any
////        ])
//        
//    }
//    
//    static func renameChannel(channel: Channel, newName: String) {
//        let data: [String : Any] = [
//            "name": newName
//        ]
//        Firestore.firestore().collection("channels").document(channel.id!).setData(data, merge: true)
//    }
//
//}
