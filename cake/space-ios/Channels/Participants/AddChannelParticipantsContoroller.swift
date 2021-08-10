//
//  AddChannelParticipantsContoroller.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddChannelParticipantsController: SelectParticipantsController {
    
    var indicator = SVProgressHUD.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        navigationItem.leftBarButtonItem = backButton

        setupRightBarButton(with: "Done")
        title = "Add Attendees"
        
        indicator.setDefaultMaskType(.clear)
    }
    
    

    override func rightBarButtonTapped() {
        super.rightBarButtonTapped()
        guard let channelID = channel?.id else { return }
        addMembersPlease(participantIDs: selectedUsers.map({ ($0.id ?? "") }), channelID: channelID)
    }
    
    func fetchMemeberFCMTokensMap() -> [String:String] {
        var membersFCMTokensDict = [String:String]()
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return membersFCMTokensDict }
        
        membersFCMTokensDict[currentUserID] = userDefaults.currentStringObjectState(for: userDefaults.fcmToken)
        
        for selectedUser in selectedUsers {
            guard let userId = selectedUser.id else { continue }
            Firestore.firestore().collection("fcmTokens").document(userId).getDocument { (snapshot, error) in
                guard let fcmDict = snapshot?.data(), let fcmToken = fcmDict["fcmToken"] as? String else { return }
                membersFCMTokensDict[userId] = fcmToken
            }
        }
        return membersFCMTokensDict
    }
    let addMembersGroup = DispatchGroup()
    fileprivate func addMembersPlease(participantIDs: [String], channelID: String) {
        navigationController?.backToViewController(viewController: ChannelLogController.self)
        globalIndicator.show()
        
        let currentChannelReference = Firestore.firestore().collection("channels").document(channelID)
        
        addMembersGroup.enter()
        addMembersGroup.enter()
        
        commitBatchUpdates(participantIDs: participantIDs, channelID: channelID, currentChannelReference: currentChannelReference)
        fetchAndUpdateMemeberFCMTokens(currentChannelReference: currentChannelReference)
        
        addMembersGroup.notify(queue: .main) {
            hapticFeedback(style: .success)
            globalIndicator.showSuccess(withStatus: "Added")
            
            var printableNameList: String?
            for selectedUser in self.selectedUsers {
                if let name = selectedUser.name {
                    if printableNameList == nil { printableNameList = name } else { printableNameList! += ", " + name }
                }
            }
            if let nameList = printableNameList {
                
//                if  self.selectedUsers.count > 1 {
//                    self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: self.channel?.name ?? "", participantIDs: [], text: "\(nameList) have been added to the event", channel: self.channel)
//                } else {
//                    self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: self.channel?.name ?? "", participantIDs: [], text: "\(nameList) has been added to the event", channel: self.channel)
//                }
            }
            self.delegate?.selectedUsers(shouldBeUpdatedTo: self.selectedUsers)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func commitBatchUpdates(participantIDs: [String], channelID: String, currentChannelReference: DocumentReference) {
        let usersReference = Firestore.firestore().collection("users")
        let currentChannelParticipantIDsReference = Firestore.firestore().collection("channels").document(channelID).collection("participantIds")
        let batch = Firestore.firestore().batch()
        
        
        for participantID in participantIDs {
            batch.setData(["participantId": participantID], forDocument: currentChannelParticipantIDsReference.document(participantID))
            batch.updateData([
                "participantIds": FieldValue.arrayUnion([participantID]),
            ], forDocument: currentChannelReference)
            batch.setData([
                "channelId": channelID
            ], forDocument: usersReference.document(participantID).collection("channelIds").document(channelID))
        }
        batch.commit { (error) in
            self.addMembersGroup.leave()
            if error != nil {
                print(error?.localizedDescription ?? "error")
                displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
        }
    }
    
    func fetchAndUpdateMemeberFCMTokens(currentChannelReference: DocumentReference) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        var membersFCMTokensDict = [String:String]()
        let fcmFetchingGroup = DispatchGroup()
        
        for _ in selectedUsers { fcmFetchingGroup.enter() }
        
        fcmFetchingGroup.notify(queue: DispatchQueue.main, execute: {
            
            self.fcmTokenMapTransaction(fcmTokensMap: membersFCMTokensDict, currentChannelReference: currentChannelReference) {
                // completed
                self.addMembersGroup.leave()
            }
        })
        membersFCMTokensDict[currentUserID] = userDefaults.currentStringObjectState(for: userDefaults.fcmToken)
        for selectedUser in selectedUsers {
            guard let userId = selectedUser.id else { continue }
            Firestore.firestore().collection("fcmTokens").document(userId).getDocument { (snapshot, error) in
                fcmFetchingGroup.leave()
                guard let fcmDict = snapshot?.data(), let fcmToken = fcmDict["fcmToken"] as? String else { return }
                membersFCMTokensDict[userId] = fcmToken
            }
        }
    }
    
    func fcmTokenMapTransaction(fcmTokensMap: [String:String], currentChannelReference: DocumentReference, completion: @escaping (() -> Void)) {
        Firestore.firestore().runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(currentChannelReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldFCMTokensMap = document.data()?["fcmTokens"] as? [String:String] else {
                   let error = NSError(
                       domain: "AppErrorDomain",
                       code: -1,
                       userInfo: [
                           NSLocalizedDescriptionKey: "Unable to retrieve fcmTokens from snapshot \(document)"
                       ]
                   )
                   errorPointer?.pointee = error
                   return nil
               }
            
            var newFCMTokensMap = oldFCMTokensMap
            newFCMTokensMap.merge(dict: fcmTokensMap)
            
            transaction.updateData(["fcmTokens": newFCMTokensMap], forDocument: currentChannelReference)
            return nil
        } completion: { (object, error) in
            completion()
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    @objc fileprivate func popController() {
        hapticFeedback(style: .impact)
        navigationController?.popViewController(animated: true)
    }
}
