//
//  ChannelsController+DeleteAndExitDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-17.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import RealmSwift

extension ChannelsController: DeleteAndExitDelegate {
    func deleteAndExit(from channelID: String) {
        guard let row = conversationIndex(for: channelID, at: 0) else { return }
        let indexPath = IndexPath(row: row, section: 0)
        deleteChannel(at: indexPath)
    }
    
    func conversationIndex(for incomingChannelID: String, at section: Int) -> Int? {
        guard let theRealmChannels = theRealmChannels else { return nil }
        guard let index = theRealmChannels.firstIndex(where: { (channel) -> Bool in
            guard let channelID = channel.id else { return false }
            return channelID == incomingChannelID
        }) else { return nil }
        return index
    }
}
