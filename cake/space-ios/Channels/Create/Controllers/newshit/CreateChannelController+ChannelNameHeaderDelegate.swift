//
//  CreateChannelController+ChannelNameHeaderDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-15.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation

extension CreateChannelController: ChannelNameHeaderCellDelegate {
    func channelNameHeaderCell(_ cell: ChannelNameHeaderCell, didTapImageView: Bool) {
    }
    
    func channelNameHeaderCell(_ cell: ChannelNameHeaderCell, updatedChannelName: String) {
        channelName = updatedChannelName
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}
