//
//  BaseMessageCell+Handlers.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//


import UIKit
import FTPopOverMenu_Swift
import Firebase

struct ContextMenuItems {
    static let copyItem = "Copy"
    static let reportItem = "Report"

    static func contextMenuItems(for messageType: MessageType, _ isIncludedReport: Bool) -> [String] {
        guard isIncludedReport else {
            return defaultMenuItems(for: messageType)
        }
        switch messageType {
            case .textMessage:
                return [ContextMenuItems.copyItem, ContextMenuItems.reportItem]
            case .sendingMessage:
                return  [ContextMenuItems.copyItem]
        }
    }

    static func defaultMenuItems(for messageType: MessageType) -> [String] {
        return  [ContextMenuItems.copyItem]
    }
}

extension BaseMessageCell {

    func bubbleImage(currentColor: UIColor) -> UIColor {
        switch currentColor {
            case ThemeManager.currentTheme().outgoingMessageBackgroundColor:
                return ThemeManager.currentTheme().selectedOutgoingBubbleTintColor
            case ThemeManager.currentTheme().incomingMessageBackgroundColor:
                return ThemeManager.currentTheme().selectedIncomingBubbleTintColor
            default:
                return currentColor
        }
    }

    @objc func handleLongTap(_ longPressGesture: UILongPressGestureRecognizer) {
        guard longPressGesture.state == .began else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        guard let indexPath = self.channelLogController?.collectionView.indexPath(for: self) else { return }

        let message = channelLogController?.groupedMessages[indexPath.section].messages[indexPath.row]

        let isOutgoing = message?.fromId == Auth.auth().currentUser?.uid
        var contextMenuItems = ContextMenuItems.contextMenuItems(for: .textMessage, !isOutgoing)
        let config = channelLogController?.configureCellContextMenuView() ?? FTConfiguration()
        let expandedMenuWidth: CGFloat = 150
        let defaultMenuWidth: CGFloat = 100
        config.menuWidth = expandedMenuWidth

        if let cell = self.channelLogController?.collectionView.cellForItem(at: indexPath) as? OutgoingMessageCell {
            cell.bubbleView.tintColor = bubbleImage(currentColor: cell.bubbleView.tintColor)
        }

        if let cell = self.channelLogController?.collectionView.cellForItem(at: indexPath) as? IncomingMessageCell {
            cell.bubbleView.tintColor = bubbleImage(currentColor: cell.bubbleView.tintColor)
        }

        if message?.messageUID == nil || message?.status == messageStatusSending || message?.status == messageStatusNotSent {
            config.menuWidth = defaultMenuWidth
            contextMenuItems = ContextMenuItems.contextMenuItems(for: .sendingMessage, !isOutgoing)
        }

        FTPopOverMenu.showForSender(sender: bubbleView, with: contextMenuItems, menuImageArray: nil, popOverPosition: .automatic, config: config, done: { (selectedIndex) in
            guard contextMenuItems[selectedIndex] != ContextMenuItems.reportItem else {
                self.handleReport(indexPath: indexPath)
                print("handlong report")
                return
            }

//            guard contextMenuItems[selectedIndex] != ContextMenuItems.deleteItem else {
//                self.handleDeletion(indexPath: indexPath)
//                print("handling deletion")
//                return
//            }
            print("handling coly")
            self.handleCopy(indexPath: indexPath)
        }) {
            self.channelLogController?.collectionView.reloadItems(at: [indexPath])
        }
    }

    fileprivate func handleReport(indexPath: IndexPath) {
//        chatLogController?.collectionView.reloadItems(at: [indexPath])
//        chatLogController?.inputContainerView.resignAllResponders()
//
//        let reportAlert = ReportAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        reportAlert.controller = chatLogController
//        reportAlert.indexPath = indexPath
//        reportAlert.reportedMessage = chatLogController?.groupedMessages[indexPath.section].messages[indexPath.row]
//        reportAlert.popoverPresentationController?.sourceView = bubbleView
//        reportAlert.popoverPresentationController?.sourceRect = CGRect(x: bubbleView.bounds.midX, y: bubbleView.bounds.maxY,
//                               width: 0, height: 0)
//        chatLogController?.present(reportAlert, animated: true, completion: nil)
    }

    fileprivate func handleCopy(indexPath: IndexPath) {
        self.channelLogController?.collectionView.reloadItems(at: [indexPath])
        
        if let cell = self.channelLogController?.collectionView.cellForItem(at: indexPath) as? OutgoingMessageCell {
            UIPasteboard.general.string = cell.textView.text
        } else if let cell = self.channelLogController?.collectionView.cellForItem(at: indexPath) as? IncomingMessageCell {
            UIPasteboard.general.string = cell.textView.text
        } else {
            return
        }
    }

}

