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

    fileprivate func addMembersPlease(participantIDs: [String], channelID: String) {
        navigationController?.backToViewController(viewController: ChannelLogController.self)
        globalIndicator.show()
        
        ChannelManager.addMembers(memberIds: participantIDs, channelID: channelID) { error in
            if error != nil {
                print(error?.localizedDescription ?? "error addMembersPlease")
                return
            }
            
            hapticFeedback(style: .success)
            globalIndicator.showSuccess(withStatus: "Added")

            var printableNameList: String?
            for selectedUser in self.selectedUsers {
                if let name = selectedUser.name {
                    if printableNameList == nil { printableNameList = name } else { printableNameList! += ", " + name }
                }
            }
            if let nameList = printableNameList {
                if  self.selectedUsers.count > 1 {
                    self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: self.channel?.name ?? "", participantIDs: [], text: "\(nameList) have been added to the event", channel: self.channel)
                } else {
                    self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: self.channel?.name ?? "", participantIDs: [], text: "\(nameList) has been added to the event", channel: self.channel)
                }
            }
            self.delegate?.selectedUsers(shouldBeUpdatedTo: self.selectedUsers)
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    
    @objc fileprivate func popController() {
        hapticFeedback(style: .impact)
        navigationController?.popViewController(animated: true)
    }
}
