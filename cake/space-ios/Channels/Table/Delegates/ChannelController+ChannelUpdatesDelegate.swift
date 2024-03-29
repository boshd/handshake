//
//  ChannelController+ChannelUpdatesDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Firebase
import UIKit

extension ChannelsController: ChannelUpdatesDelegate {
  
    func channels(didStartFetching: Bool) {
        guard !isAppLoaded else { return }
        showActivityTitle(title: .updating)
        
    }

    func channels(didStartUpdatingData: Bool) {
        showActivityTitle(title: .updating)
    }

    func channels(didFinishFetching: Bool, channels: [Channel]) {
        notificationsManager.observersForNotifications(channels: channels)
        if !isAppLoaded {
            observeDataSourceChanges()
        }
        guard let token1 = realmChannelsNotificationToken else { return }
        realmManager.update(channels: channels, tokens: [token1])
        handleReloadTable()
        hideActivityTitle(title: .updating)
    }

    func channels(update channel: Channel, reloadNeeded: Bool) {
        realmManager.update(channel: channel)
        if let realmChannels = realmChannels {
            notificationsManager.updateChannels(to: Array(realmChannels))
        }
//        if reloadNeeded {
//            handleReloadTable()
//        }
        
        hideActivityTitle(title: .updating)
    }

    func channels(didRemove: Bool, channelID: String) {
        //typingIndicatorManager.removeTypingIndicator(for: channelID)
    }

    func channels(addedNewChannel: Bool, channelID: String) {
        guard isAppLoaded else { return }
    }
}
