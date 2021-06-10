////
////  ChannelDetailsDataDatabaseUpdater.swift
////  space-ios
////
////  Created by Kareem Arab on 2019-11-24.
////  Copyright © 2019 Kareem Arab. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class ChannelDetailsDataDatabaseUpdater: NSObject {
//    
//    typealias UpdateChannelDetailsCompletionHandler = (_ success: Bool) -> Void
//    func updateChannelDetails(with channelID: String?, image: UIImage, completion: @escaping UpdateChannelDetailsCompletionHandler) {
//        guard let channelID = channelID else { return }
//        let channelReference = Firestore.firestore().collection("channels").document(channelID)
//
//        let thumbnailImage = createImageThumbnail(image)
//        var images = [(image: UIImage, quality: CGFloat, key: String)]()
//        images.append((image: image, quality: 0.5, key: "imageUrl"))
//        images.append((image: thumbnailImage, quality: 1, key: "thumbnailImageUrl"))
//
//        let imageUpdatingGroup = DispatchGroup()
//        for _ in images { imageUpdatingGroup.enter() }
//
//        imageUpdatingGroup.notify(queue: DispatchQueue.main, execute: {
//            completion(true)
//        })
//
//        for imageElement in images {
//            uploadImageForChannelToFirebaseStorageUsingImage(imageElement.image, quality: imageElement.quality) { (url) in
//                channelReference.updateData([imageElement.key: url]) { (_) in
//                    imageUpdatingGroup.leave()
//                }
//            }
//        }
//    }
//    
//    typealias DeleteCurrentPhotoCompletionHandler = (_ success: Bool) -> Void
//    func deleteCurrentPhoto(with channelID: String?, completion: @escaping DeleteCurrentPhotoCompletionHandler) {
//        guard currentReachabilityStatus != .notReachable, let channelID = channelID else {
//          completion(false)
//          return
//        }
//        
//        let channelReference = Firestore.firestore().collection("channels").document(channelID)
//        
//        channelReference.getDocument { (documentSnapshot, error) in
//            guard let channelData = documentSnapshot?.data() else {
//                if error != nil {
//                    print("error // ", error!)
//                }
//                return
//            }
//            
//            guard let imageURL = channelData["imageUrl"] as? String, let thumbnailImageURL = channelData["thumbnailImageUrl"] as? String, imageURL != "", thumbnailImageURL != "" else {
//                completion(true)
//                return
//            }
//            
//            let storage = Storage.storage()
//            let imageURLStorageReference = storage.reference(forURL: imageURL)
//            let thumbnailImageURLStorageReference = storage.reference(forURL: thumbnailImageURL)
//            
//            let imageRemovingGroup = DispatchGroup()
//            imageRemovingGroup.enter()
//            imageRemovingGroup.enter()
//            
//            imageRemovingGroup.notify(queue: DispatchQueue.main) {
//                completion(true)
//            }
//            
//            imageURLStorageReference.delete { (_) in
//                channelReference.updateData(["imageUrl":""]) { (_) in
//                    imageRemovingGroup.leave()
//                }
//            }
//            
//            thumbnailImageURLStorageReference.delete { (_) in
//                channelReference.updateData(["thumbnailImageUrl":""]) { (_) in
//                    imageRemovingGroup.leave()
//                }
//            }
//            
//        }
//    }
//    
//}
//
