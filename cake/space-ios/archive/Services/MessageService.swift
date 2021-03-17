//
//  MessagesService.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-06-05.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

protocol MessagesDelegate: class {
    func messages(shouldBeUpdatedTo messages: [Message], channel: Channel)
    func messages(shouldChangeMessageStatusToRead: Bool)
}

class MessagesService: NSObject {
    
    var messages = [Message]()
    let messagesToLoad = 50
    
    weak var delegate: MessagesDelegate?

    func loadMessages(for channel: Channel) {
        guard let channelID = channel.channelID else { return }
        
        Firestore.firestore().collection("channels/\(channelID)/thread").getDocuments { (documentSnapshot, error) in
            if error != nil {
                print("error // ", error!.localizedDescription)
                return
            }
            let dataArray = documentSnapshot?.documents
            for data in dataArray! {
                print(data)
            }
        }
    }
    
    static func save(message: Message, channel: Channel, completion: @escaping () -> Void) {
        guard message.id != nil, channel.channelID != nil, Auth.auth().currentUser != nil else { return }
        let id = channel.channelID
        
        let reference = Firestore.firestore().collection("channels/\(id ?? "noid")/thread")
        reference.addDocument(data: message.representation) { (error) in
            if error != nil {
                print("error // ", error?.localizedDescription as Any)
                return
            }
            print("Data saved!")
        }
    }
    
}
