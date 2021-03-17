////
////  ChannelService.swift
////  space-ios
////
////  Created by Kareem Arab on 2019-06-07.
////  Copyright © 2019 Kareem Arab. All rights reserved.
////
//
//import Foundation
//import Firebase
//import FirebaseFirestore
//import RealmSwift
//
//class ChannelService: NSObject {
//    
//    static func getChannelParticipantIDs(channelID: String, completion: @escaping (_ ids: [String]) -> Void) {
//        var ids = [String]()
//        Firestore.firestore().collection("channels").document(channelID).collection("participantIDs").getDocuments { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("error // ", error!)
//                return
//            }
//            for document in documents {
//                let id = document.documentID
//                ids.append(id)
//            }
//            completion(ids)
//        }
//    }
//    
//    static func getUsersInChannel(channelID: String?, participantIDs: [String], completion: @escaping (_ users: [User]) -> Void) {
//        guard let channelID = channelID else { return }
//        let group = DispatchGroup()
//        var users = [User]()
//        
//        let channelIDsReference = Firestore.firestore().collection("channels").document(channelID).collection("participantIDs")
//        
//        channelIDsReference.getDocuments { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("error // ", error!)
//                return
//            }
//            for document in documents {
//                group.enter()
//                let id = document.documentID
//                UsersService.getUserWith(id) { (user) in
//                    users.append(user)
//                    group.leave()
//                }
//                
//            }
//            group.notify(queue: .main, execute: {
//                completion(users)
//            })
//        }
//    }
//    
//    static func CreateChannel(authorID: String?, selectedImageData: Data, adminIDs: [String], participantIDs: [String], channelName: String, description: String, latitude: Double, longitude: Double, dateTimestamp: Timestamp, completion: @escaping (_ channel: Channel?) -> Void) {
//        
//        let channelsReference = Firestore.firestore().collection("channels")
//        let usersReference = Firestore.firestore().collection("users")
//        
//        guard let authorID = authorID else { return }
//        
//        // Creates new channel ref that will be created for the channel.
//        let newChannelReference = channelsReference.document()
//        
//        // Create channel data
//        let channelData: [String: Any] = [
//            "lastMessage": "You created channel \(channelName)",
//            "lastMessageTimeStamp": NSNumber(value: Int(Date().timeIntervalSince1970)),
//            "channelName": channelName,
//            "authorID": authorID,
//            "participantIDs": participantIDs,
//            "adminIDs": adminIDs,
//            "channelID": newChannelReference.documentID,
//            "channelImageURL": "",
//            "isGroup": true,
//            "bio": description,
//            "dateTimestamp": dateTimestamp,
//            "latitude": latitude,
//            "longitude": longitude
//        ]
//        
//        // Set data
//        newChannelReference.setData(channelData)
//        for adminID in adminIDs {
//            newChannelReference.collection("adminIDs").document(adminID)
//        }
//        
//        // Adds channel ID to all other users
//        for participantID in participantIDs {
//            newChannelReference.collection("participantIDs").document(participantID).setData(["participantID":participantID])
//        
//            usersReference.document(participantID).collection("channelIds").document(newChannelReference.documentID).setData(["channelID":newChannelReference.documentID])
//        }
//        
//        let storageManager = StorageManager()
//        let group2 = DispatchGroup()
//        let group1 = DispatchGroup()
//        group1.enter()
//        
//        storageManager.uploadTheData(selectedImageData, named: "channelImage_\(newChannelReference.documentID)") { (url, error) in
//            if error != nil {
//                print("error // \(error!.localizedDescription)")
//                return
//            }
//            
//            guard let url = url else {
//                return
//            }
//            print("WAITING!!")
//            group2.enter()
//            newChannelReference.updateData(["channelImageURL": url.absoluteString], completion: { (error) in
//                if error != nil {
//                    print("error // ", error!.localizedDescription)
//                    return
//                }
//                print("updateeeeeeeeeeeeeee")
//                group2.leave()
//            })
//            
//            group2.notify(queue: .main) {
//                print("done with upload task")
//                group1.leave()
//            }
//            
//        }
//        group1.notify(queue: .main) {
//            print("notified and in completion")
//            completion(Channel(dictionary: channelData as [String : AnyObject]))
//        }
//        
//    }
//    
//}
