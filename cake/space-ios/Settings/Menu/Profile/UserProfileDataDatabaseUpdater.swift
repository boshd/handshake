//
//  UserProfileDataDatabaseUpdater.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-23.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class UserProfileDataDatabaseUpdater: NSObject {
    
    typealias UpdateUserProfileCompletionHandler = (_ success: Bool) -> Void
    func updateUserProfile(with image: UIImage, completion: @escaping UpdateUserProfileCompletionHandler) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userReference = Firestore.firestore().collection("users").document(currentUserID)

        let thumbnailImage = createImageThumbnail(image)
        var images = [(image: UIImage, quality: CGFloat, key: String)]()
        images.append((image: image, quality: 0.5, key: "userImageUrl"))
        images.append((image: thumbnailImage, quality: 1, key: "userThumbnailImageUrl"))

        let imageUpdatingGroup = DispatchGroup()
        for _ in images { imageUpdatingGroup.enter() }

        imageUpdatingGroup.notify(queue: DispatchQueue.main, execute: {
            completion(true)
        })

        for imageElement in images {
            uploadImageForUserToFirebaseStorageUsingImage(imageElement.image, quality: imageElement.quality) { (url) in
                userReference.updateData([imageElement.key: url]) { (_) in
                    imageUpdatingGroup.leave()
                }
            }
        }
    }
    
    typealias DeleteCurrentPhotoCompletionHandler = (_ success: Bool) -> Void
    func deleteCurrentPhoto(completion: @escaping DeleteCurrentPhotoCompletionHandler) {
        guard currentReachabilityStatus != .notReachable, let currentUser = Auth.auth().currentUser?.uid else {
          completion(false)
          return
        }
        
        let userReference = Firestore.firestore().collection("users").document(currentUser)
        
        userReference.getDocument { (documentSnapshot, error) in
            guard let userData = documentSnapshot?.data() else {
                if error != nil {
                    print("error // ", error!)
                }
                return
            }
            
            guard let imageURL = userData["userImageUrl"] as? String, let thumbnailImageURL = userData["userThumbnailImageUrl"] as? String, imageURL != "", thumbnailImageURL != "" else {
                completion(true)
                return
            }
            
            let storage = Storage.storage()
            let imageURLStorageReference = storage.reference(forURL: imageURL)
            let thumbnailImageURLStorageReference = storage.reference(forURL: thumbnailImageURL)
            
            let imageRemovingGroup = DispatchGroup()
            imageRemovingGroup.enter()
            imageRemovingGroup.enter()
            
            imageRemovingGroup.notify(queue: DispatchQueue.main) {
                completion(true)
            }
            
            imageURLStorageReference.delete { (_) in
                userReference.updateData(["userImageUrl":""]) { (_) in
                    imageRemovingGroup.leave()
                }
            }
            
            thumbnailImageURLStorageReference.delete { (_) in
                userReference.updateData(["userThumbnailImageUrl":""]) { (_) in
                    imageRemovingGroup.leave()
                }
            }
            
        }
    }
    
}
