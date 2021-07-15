//
//  IncomingMessageCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import SafariServices

class IncomingMessageCell: BaseMessageCell {
    
    lazy var textView: MessageTextView = {
        let textView = MessageTextView()
        textView.textContainerInset =  UIEdgeInsets(top: BaseMessageCell.textViewTopInset,
                                                    left: BaseMessageCell.incomingTextViewLeftInset,
                                                    bottom: BaseMessageCell.textViewBottomInset,
                                                    right: BaseMessageCell.incomingTextViewRightInset)
        textView.backgroundColor = ThemeManager.currentTheme().incomingMessageBackgroundColor
        textView.textColor = ThemeManager.currentTheme().incomingMessageCellTextColor
        textView.font = ThemeManager.currentTheme().secondaryFont(with: IncomingMessageCell.messageTextSize)
        return textView
    }()

    override func setupViews() {
        super.setupViews()
        
        let interaction = UIContextMenuInteraction(delegate: self)
        bubbleView.addInteraction(interaction)
        
        textView.delegate = self
        bubbleView.addSubview(textView)
        textView.addSubview(nameLabel)
        bubbleView.addSubview(timeLabel)

        bubbleView.frame.origin = BaseMessageCell.incomingBubbleOrigin
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = ThemeManager.currentTheme().incomingTimestampTextColor
        //bubbleView.tintColor = ThemeManager.currentTheme().incomingBubbleTintColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.backgroundColor = ThemeManager.currentTheme().incomingMessageBackgroundColor
        textView.textColor = ThemeManager.currentTheme().incomingMessageCellTextColor
        textView.font = ThemeManager.currentTheme().secondaryFont(with: IncomingMessageCell.messageTextSize)
        
        bubbleView.frame.origin = BaseMessageCell.incomingBubbleOrigin
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = ThemeManager.currentTheme().incomingTimestampTextColor
    }

    func setupData(message: Message) {
        guard let messageText = message.text else { return }
        textView.text = messageText

       
        nameLabel.text = message.senderName ?? ""
        nameLabel.sizeToFit()
        bubbleView.frame.size = setupGroupBubbleViewSize(message: message)

        textView.textContainerInset.top = BaseMessageCell.incomingTextViewTopInset
        textView.frame.size = CGSize(width: bubbleView.frame.width.rounded(), height: bubbleView.frame.height.rounded())
        

        timeLabel.frame.origin = CGPoint(x: bubbleView.frame.width-timeLabel.frame.width,
                                         y: bubbleView.frame.height-timeLabel.frame.height-5)
        timeLabel.text = message.convertedTimestamp

        
        // bubbleView.image = ThemeManager.currentTheme().incomingPartialBubble
    }
    
    fileprivate func setupGroupBubbleViewSize(message: Message) -> CGSize {
        guard let portaritWidth = message.estimatedFrameForText?.width.value else { return CGSize() }
        let portraitBubbleMaxW = BaseMessageCell.bubbleViewMaxWidth
        let portraitAuthorMaxW = BaseMessageCell.incomingMessageAuthorNameLabelMaxWidth


        return getGroupBubbleSize(messageWidth: CGFloat(portaritWidth),
                                  bubbleMaxWidth: portraitBubbleMaxW,
                                  authorMaxWidth: portraitAuthorMaxW)
        
    }

    fileprivate func getGroupBubbleSize(messageWidth: CGFloat, bubbleMaxWidth: CGFloat, authorMaxWidth: CGFloat) -> CGSize {
        let horisontalInsets = BaseMessageCell.incomingMessageHorisontalInsets

        let rect = setupFrameWithLabel(bubbleView.frame.origin.x,
                                       bubbleMaxWidth,
                                       messageWidth,
                                       horisontalInsets,
                                       frame.size.height, 10).integral

        if nameLabel.frame.size.width >= rect.width - horisontalInsets {
            if nameLabel.frame.size.width >= authorMaxWidth {
                nameLabel.frame.size.width = authorMaxWidth
                return CGSize(width: bubbleMaxWidth, height: frame.size.height.rounded())
            }
            return CGSize(width: (nameLabel.frame.size.width + horisontalInsets).rounded(),
                          height: frame.size.height.rounded())
        } else {
            return rect.size
        }
    }
    
}

extension IncomingMessageCell: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu()
        })
    }
    
    func makeContextMenu() -> UIMenu {
        
        let copy = UIAction(title: "Copy", image: UIImage(named: "copy")) { action in
            UIPasteboard.general.string = self.textView.text
        }
        
        return UIMenu(title: "", image: nil, identifier: .replace, options: .displayInline, children: [copy])
    }
}

extension IncomingMessageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard interaction != .preview else { return false }
        guard ["http", "https"].contains(URL.scheme?.lowercased() ?? "")  else { return true }
        var svc = SFSafariViewController(url: URL as URL)

        if #available(iOS 11.0, *) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true
            svc = SFSafariViewController(url: URL as URL, configuration: configuration)
        }

        svc.preferredControlTintColor = tintColor
        svc.preferredBarTintColor = ThemeManager.currentTheme().generalBackgroundColor
        channelLogController?.inputContainerView.resignAllResponders()
        channelLogController?.present(svc, animated: true, completion: nil)

        return false
    }
}
