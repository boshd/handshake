//
//  StorageManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-09.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import Firebase

class StorageManager {
    
    private let storageReference: StorageReference
    
    init() {
        
        // first we create a reference to our storage
        // replace the URL with your firebase URL
        self.storageReference = Storage.storage().reference(forURL: "gs://handshake-a55d9.appspot.com")
    }
    
    // MARK: - UPLOAD DATA
    open func uploadTheData(_ data: Data, named filename: String, completion: @escaping (URL? , Error?) -> Void) {
        
        let reference = self.storageReference.child(filename)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg" // in my example this was "PDF"
        
        // we create an upload task using our reference and upload the
        // data using the metadata object
        reference.putData(data, metadata: metadata) { metadata, error in
            
            // first we check if the error is nil
            if let error = error {
                
                completion(nil, error)
                return
            }
            
            // then we check if the metadata and path exists
            // if the error was nil, we expect the metadata and path to exist
            // therefore if not, we return an error
            guard let metadata = metadata, let path = metadata.path else {
                completion(nil, NSError(domain: "core", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected error. Path is nil."]))
                return
            }
            
            // now we get the download url using the path
            // and the basic reference object (without child paths)
            self.getDownloadURL(from: path, completion: { (url, error) in
                completion(url, nil)
                return
            })
        }
        
        // further we are able to use the uploadTask for example to
        // to get the progress
    }
    
    // MARK: - GET DOWNLOAD URL
    private func getDownloadURL(from path: String, completion: @escaping (URL?, Error?) -> Void) {
        self.storageReference.child(path).downloadURL { (url, error) in
            completion(url, error)
        }
    }
    
}
