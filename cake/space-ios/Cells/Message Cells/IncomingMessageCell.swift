//
//  IncomingMessageCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import SafariServices
import SDWebImage

protocol ProfileOpeningDelegate: class {
    func openProfile(fromId: String)
}

class IncomingMessageCell: BaseMessageCell {
    
    weak var delegate: ProfileOpeningDelegate?
    
    var fromId: String?
    
    lazy var textView: MessageTextView = {
        let textView = MessageTextView()
        textView.textContainerInset =  UIEdgeInsets(top: BaseMessageCell.textViewTopInset,
                                                    left: BaseMessageCell.incomingTextViewLeftInset,
                                                    bottom: BaseMessageCell.textViewBottomInset,
                                                    right: BaseMessageCell.incomingTextViewRightInset)
        textView.backgroundColor = .clear
        textView.textColor = ThemeManager.currentTheme().incomingMessageCellTextColor
//        textView.font = ThemeManager.currentTheme().secondaryFont(with: IncomingMessageCell.messageTextSize)
        return textView
    }()
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        // not using autolayout
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12.5
        imageView.layer.cornerCurve = .circular
        //imageView.image = UIImage(named: "GroupIcon")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()

    override func setupViews() {
        super.setupViews()
        
//        let interaction = UIContextMenuInteraction(delegate: self)
//        bubbleView.addInteraction(interaction)
        
        textView.delegate = self
        bubbleView.addSubview(textView)
        contentView.addSubview(nameLabel)
        bubbleView.addSubview(timeLabel)
        contentView.addSubview(userImageView)

        
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = ThemeManager.currentTheme().incomingTimestampTextColor
        bubbleView.tintColor = ThemeManager.currentTheme().incomingMessageBackgroundColor
        //bubbleView.tintColor = ThemeManager.currentTheme().incomingBubbleTintColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.backgroundColor = .clear
        textView.textColor = ThemeManager.currentTheme().incomingMessageCellTextColor
        textView.font = ThemeManager.currentTheme().secondaryFont(with: IncomingMessageCell.messageTextSize)
        userImageView.image = nil
        bubbleView.frame.origin = BaseMessageCell.incomingBubbleOrigin
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = ThemeManager.currentTheme().incomingTimestampTextColor
//        bubbleView.backgroundColor = ThemeManager.currentTheme().incomingMessageBackgroundColor
        bubbleView.tintColor = ThemeManager.currentTheme().incomingMessageBackgroundColor
    }

    func setupData(message: Message) {
        guard let messageText = message.text else { return }
        
        fromId = message.fromId
        
        if let isFirst = message.isFirstInSection.value, isFirst {
//            bubbleView.frame.origin = BaseMessageCell.incomingFirstBubbleOrigin
            bubbleView.frame.origin = CGPoint(x: 20 + CGFloat(BaseMessageCell.userImageViewWidth), y: BaseMessageCell.incomingMessageAuthorNameLabelHeight)

            nameLabel.text = message.senderName ?? ""
            nameLabel.sizeToFit()
            
            if let name = RealmKeychain.realmUsersArray().first(where: { $0.id == message.fromId })?.localName {
                nameLabel.text = name
            } else if let name = RealmKeychain.realmUsersArray().first(where: { $0.id == message.fromId })?.name {
                nameLabel.text = name
            } else {
                nameLabel.text = message.senderName ?? ""
            }
            
        } else {
            bubbleView.frame.origin = BaseMessageCell.incomingBubbleOrigin
        }
        
        bubbleView.frame.size = setupGroupBubbleViewSize(message: message)
        
        textView.text = messageText

        textView.textContainerInset.top = BaseMessageCell.incomingTextViewTopInset
        textView.frame.size = CGSize(width: bubbleView.frame.width.rounded(), height: bubbleView.frame.height.rounded())
        

        timeLabel.frame.origin = CGPoint(x: bubbleView.frame.width-timeLabel.frame.width,
                                         y: bubbleView.frame.height-timeLabel.frame.height-5)
        timeLabel.text = message.convertedTimestamp
        
        userImageView.frame.size = CGSize(width: BaseMessageCell.userImageViewWidth, height: BaseMessageCell.userImageViewHeight)
        userImageView.frame.origin = CGPoint(x: 10, y: bubbleView.frame.height - CGFloat(BaseMessageCell.userImageViewHeight))
        
        if let isCrooked = message.isCrooked.value, isCrooked {
            bubbleView.image = ThemeManager.currentTheme().incomingBubble
            if RealmKeychain.realmUsersArray().map({ $0.id }).contains(message.fromId) {
                guard let url = RealmKeychain.realmUsersArray().first(where: { $0.id == message.fromId })?.userThumbnailImageUrl else { return }
                userImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "UserpicIcon"), options: [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage], completed: { [weak self] (image, _, cacheType, _) in
                    guard image != nil else { return }

                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self?.imageTapped(tapGestureRecognizer:)))
                    self?.userImageView.isUserInteractionEnabled = true
                    self?.userImageView.addGestureRecognizer(tapGestureRecognizer)

                    guard cacheType != SDImageCacheType.memory, cacheType != SDImageCacheType.disk else {
                        self?.userImageView.image = image
                        return
                    }

                    UIView.transition(with: self?.userImageView ?? UIImageView(image: UIImage(named: "UserpicIcon")),
                                      duration: 0.2,
                                      options: .transitionCrossDissolve,
                                      animations: { self?.userImageView.image = image },
                                      completion: nil)
                })
            }
            
            if let isFirst = message.isFirstInSection.value, isFirst {
                userImageView.frame.origin = CGPoint(x: 10, y: bubbleView.frame.height - CGFloat(BaseMessageCell.userImageViewHeight) + CGFloat(BaseMessageCell.incomingMessageAuthorNameLabelHeight))
            }
        } else {
            bubbleView.image = ThemeManager.currentTheme().incomingPartialBubble
        }
        
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if let fromId = fromId {
            delegate?.openProfile(fromId: fromId)
        }
    }
    
    fileprivate func setupGroupBubbleViewSize(message: Message) -> CGSize {
        guard let portaritWidth = message.estimatedFrameForText?.width.value else { return CGSize() }
        let portraitBubbleMaxW = BaseMessageCell.bubbleViewMaxWidth
        let portraitAuthorMaxW = BaseMessageCell.incomingMessageAuthorNameLabelMaxWidth
        
        if let isFirst = message.isFirstInSection.value, isFirst {
            return getGroupBubbleSizeForFirst(messageWidth: CGFloat(portaritWidth),
                                      bubbleMaxWidth: portraitBubbleMaxW,
                                      authorMaxWidth: portraitAuthorMaxW)
        
        } else if let isCrooked = message.isCrooked.value, isCrooked {
            return getGroupBubbleSizeForLast(messageWidth: CGFloat(portaritWidth),
                                      bubbleMaxWidth: portraitBubbleMaxW,
                                      authorMaxWidth: portraitAuthorMaxW)
        } else {
            return getGroupBubbleSize(messageWidth: CGFloat(portaritWidth),
                                      bubbleMaxWidth: portraitBubbleMaxW,
                                      authorMaxWidth: portraitAuthorMaxW)
        }
        
    }

    fileprivate func getGroupBubbleSize(messageWidth: CGFloat, bubbleMaxWidth: CGFloat, authorMaxWidth: CGFloat) -> CGSize {
        let horisontalInsets = BaseMessageCell.incomingMessageHorisontalInsets

        let rect = setupFrameWithLabel(bubbleView.frame.origin.x,
                                               bubbleMaxWidth,
                                               messageWidth,
                                               horisontalInsets,
                                       frame.size.height, 10).integral

        return rect.size
    }
    
    fileprivate func getGroupBubbleSizeForFirst(messageWidth: CGFloat, bubbleMaxWidth: CGFloat, authorMaxWidth: CGFloat) -> CGSize {
        let horisontalInsets = BaseMessageCell.incomingMessageHorisontalInsets

        let rect = setupFrameWithLabelForFirst(bubbleView.frame.origin.x,
                                       bubbleMaxWidth,
                                       messageWidth,
                                       horisontalInsets,
                                       frame.size.height, 10).integral

        return rect.size
    
    }
    
    fileprivate func getGroupBubbleSizeForLast(messageWidth: CGFloat, bubbleMaxWidth: CGFloat, authorMaxWidth: CGFloat) -> CGSize {
        let horisontalInsets = BaseMessageCell.incomingMessageHorisontalInsets

        let rect = setupFrameWithLabelForLast(bubbleView.frame.origin.x,
                                       bubbleMaxWidth,
                                       messageWidth,
                                       horisontalInsets,
                                       frame.size.height, 10).integral

        return rect.size
    
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
