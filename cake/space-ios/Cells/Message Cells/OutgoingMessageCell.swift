//
//  OutgoingMessageCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-06-02.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import SafariServices

class OutgoingMessageCell: BaseMessageCell {
 
    lazy var textView: MessageTextView = {
        let textView = MessageTextView()
        textView.textContainerInset = UIEdgeInsets(top: BaseMessageCell.textViewTopInset,
                                                   left: BaseMessageCell.outgoingTextViewLeftInset,
                                                   bottom: BaseMessageCell.textViewBottomInset,
                                                   right: BaseMessageCell.outgoingTextViewRightInset)

        textView.textColor = ThemeManager.currentTheme().outgoingMessageCellTextColor
//        textView.backgroundColor = ThemeManager.currentTheme().outgoingMessageBackgroundColor
        textView.backgroundColor = .clear
        
        return textView
    }()

    override func setupViews() {
    super.setupViews()
        textView.delegate = self
        
        let interaction = UIContextMenuInteraction(delegate: self)
        bubbleView.addInteraction(interaction)
        
        bubbleView.addSubview(textView)
        bubbleView.addSubview(timeLabel)
        contentView.addSubview(deliveryStatus)
        addSubview(resendButton)
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = ThemeManager.currentTheme().outgoingTimestampTextColor
        bubbleView.tintColor = ThemeManager.currentTheme().outgoingMessageBackgroundColor
        //bubbleView.tintColor = ThemeManager.currentTheme().outgoingBubbleTintColor
    }
    
    func setupData(message: Message) {
        guard let messageText = message.text else { return }
        textView.text = messageText
        timeLabel.text = message.convertedTimestamp
        resendButtonFrame(message: message)
        bubbleView.frame = setupBubbleViewFrame(message: message)
        textView.frame.size = CGSize(width: bubbleView.frame.width, height: bubbleView.frame.height)
        timeLabel.frame.origin = CGPoint(x: bubbleView.frame.width-timeLabel.frame.width, y: bubbleView.frame.height-timeLabel.frame.height-5)

        if let isCrooked = message.isCrooked.value, isCrooked {
            bubbleView.image = ThemeManager.currentTheme().outgoingBubble
        } else {
            bubbleView.image = ThemeManager.currentTheme().outgoingPartialBubble
        }
    }
    
    fileprivate func setupBubbleViewFrame(message: Message) -> CGRect {
        guard let portaritEstimate = message.estimatedFrameForText?.width.value else { return CGRect() }

        let portraitX = frame.width - CGFloat(portaritEstimate) - BaseMessageCell.outgoingMessageHorisontalInsets - BaseMessageCell.scrollIndicatorInset - resendButtonWidth()
        
        let portraitFrame = setupFrameWithLabel(portraitX,
                                                BaseMessageCell.bubbleViewMaxWidth,
                                                CGFloat(portaritEstimate),
                                                BaseMessageCell.outgoingMessageHorisontalInsets,
                                                frame.size.height)
        return portraitFrame.integral
//        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = ThemeManager.currentTheme().outgoingTimestampTextColor
        textView.textColor = ThemeManager.currentTheme().outgoingMessageCellTextColor
        textView.backgroundColor = .clear
        bubbleView.tintColor = ThemeManager.currentTheme().outgoingMessageBackgroundColor
        
    }
    
}

extension OutgoingMessageCell: UITextViewDelegate {
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
    
//  
//    let textView: MessageTextView = {
//        let textView = MessageTextView()
//        textView.font = UIFont.systemFont(ofSize: 13)
//        textView.backgroundColor = .purple
//        textView.isEditable = false
//        textView.isScrollEnabled = false
//        textView.textContainerInset = UIEdgeInsets(top: 10, left: 7, bottom: 10, right: 7)
//        textView.dataDetectorTypes = .all
//        textView.textColor = .blue
//        textView.linkTextAttributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single]
//
//        return textView
//    }()
//
//    func setupData(message: Message) {
//        self.message = message
//        guard let messageText = message.text else { return }
//        textView.text = messageText
//
//        textView.frame = CGRect(x: frame.width - CGFloat(message.estimatedFrameForText!.width.value!) - 40, y: 0,
//                           width: CGFloat(message.estimatedFrameForText!.width.value!) + 30, height: frame.size.height).integral
//        // textView.frame.size = CGSize(width: bubbleView.frame.width.rounded(), height: bubbleView.frame.height.rounded())
//        setupTimestampView(message: message, isOutgoing: true)
//    }
//
//    override func setupViews() {
//        // textView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap(_:))) )
//        contentView.addSubview(textView)
//        //contentView.addSubview(deliveryStatus)
//        //bubbleView.image = blueBubbleImage
//    }
//
//    override func prepareViewsForReuse() {
//    }
//    
//}
//    let textView: MessageTextView = {
//        let textView = MessageTextView()
//        textView.textContainerInset = UIEdgeInsets(top: BaseMessageCell.textViewTopInset,
//                                                   left: BaseMessageCell.outgoingTextViewLeftInset,
//                                                   bottom: BaseMessageCell.textViewBottomInset,
//                                                   right: BaseMessageCell.outgoingTextViewRightInset)
//        textView.font = ThemeManager.currentTheme().secondaryFont(with: 13)
//        textView.backgroundColor = .clear
//        textView.isEditable = false
//        textView.isScrollEnabled = false
//        textView.isSelectable = true
//        textView.isUserInteractionEnabled = true
//        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right:20)
//        textView.dataDetectorTypes = .all
////        textView.linkTextAttributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single]
//        textView.textColor = .white
//
//        return textView
//    }()
//
//    let textViewContainer: UIView = {
//        let someview = UIView()
//        someview.translatesAutoresizingMaskIntoConstraints = false
//        someview.backgroundColor = UIColor(red: 0.19, green: 0.51, blue: 1.00, alpha: 1.00)
//        someview.layer.cornerRadius = 25
//        someview.layer.cornerCurve = .continuous
//
//        return someview
//    }()
//
//    override func setupViews() {
//        super.setupViews()
//
//        let interaction = UIContextMenuInteraction(delegate: self)
//        textViewContainer.addInteraction(interaction)
//
//        contentView.addSubview(textViewContainer)
//        textViewContainer.addSubview(textView)
//        //timeLabel.textColor = .white
//        //textView.addSubview(timeLabel)
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        textView.backgroundColor = .clear
//        contentView.backgroundColor = .clear
//        nameLabel.text = ""
//        textView.text = ""
//    }
//
//    func setupData(message: Message) {
//        self.message = message
//        guard let messageText = message.text else { return }
//        textView.text = messageText
//
//        textViewContainer.frame = setupBubbleViewFrame(message: message)
//        textViewContainer.frame.size = CGSize(width: textViewContainer.frame.width,
//                                              height: textViewContainer.frame.height)
//        textView.frame.size = CGSize(width: textViewContainer.frame.width,
//                                     height: textViewContainer.frame.height)
////        timeLabel.text = message.convertedTimestamp
////        timeLabel.frame.origin = CGPoint(x: textViewContainer.frame.width-timeLabel.frame.width,
////                                         y: textViewContainer.frame.height-timeLabel.frame.height)
////
//        setupTimestampView(message: message, isOutgoing: true)
//
//    }
//
//    fileprivate func setupBubbleViewFrame(message: Message) -> CGRect {
//        guard let portaritEstimate = message.estimatedFrameForText?.width.value else { return CGRect() }
//
//        let portraitX = frame.width - CGFloat(portaritEstimate) - BaseMessageCell.outgoingMessageHorisontalInsets - BaseMessageCell.scrollIndicatorInset
//        let portraitFrame = setupFrameWithLabel(portraitX, BaseMessageCell.bubbleViewMaxWidth, CGFloat(portaritEstimate), BaseMessageCell.outgoingMessageHorisontalInsets, frame.size.height)
//
//        return portraitFrame.integral
//    }
//
//}
//
extension OutgoingMessageCell: UIContextMenuInteractionDelegate {

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

