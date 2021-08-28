//
//  ChannelLogController+ProfileOpening.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-08-28.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation

extension ChannelLogController: ProfileOpeningDelegate {
    func openProfile(fromId: String) {
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(CustomAlertAction(title: "View profile", style: .default , handler: { [unowned self] in
            globalIndicator.show()
            let destination = ParticipantProfileController()

            if let user = realm.object(ofType: User.self, forPrimaryKey: fromId) {
                globalIndicator.dismiss()
                destination.member = user
                destination.userProfileContainerView.addPhotoLabel.isHidden = true
                destination.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(destination, animated: true)
            } else {
                UsersFetcher.fetchUser(id: fromId) { user, error in
                    globalIndicator.dismiss()
                    if error != nil {
                        print(error?.localizedDescription ?? "error")
                        return
                    }
                    destination.member = user
                    destination.userProfileContainerView.addPhotoLabel.isHidden = true
                    destination.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(destination, animated: true)
                }
            }

        }))

        present(alert, animated: true, completion: nil)
    }
}
