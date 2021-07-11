//
//  TypingIndicatorManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-08.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

//import UIKit
//import Firebase

//protocol TypingIndicatorDelegate {
//    func typingIndicator(isActive: Bool, for channelID: String)
//}
//
//private let typingIndicatorDatabaseID = "typingIndicator"
//
//let typingIndicatorManager = TypingIndicatorManager()
//
//class TypingIndicatorManager: NSObject {
//
//    weak var delegate: TypingIndicatorDelegate?
//
//    var channelTypingIndicatorReference: DocumentReference!
//
//    func observeChangesForGroupTypingIndicator(with channelID: String) {
//        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//        channelTypingIndicatorReference = Firestore.firestore().collection("channelsTemp").document(channelID).addSnapshotListener({ (snapshot, error) in
//            if error != nil {
//                return
//            }
//
//            guard let dict = snapshot?.data(),
//                  let firstKey = delse { return }
//
//
//        }) as! DocumentReference
//    }
//
//}
