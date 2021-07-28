//
//  BaseMessageCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-06-02.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

struct CellSizes {

    static func timestampWidth() -> CGFloat {
        return 47
    }

    static func bubbleViewMaxWidth() -> CGFloat {
        return ScreenSize.minLength * 0.75
    }
    
}

struct MessageFontsAppearance {

    static var defaultMessageTextFont: UIFont {
        return ThemeManager.currentTheme().secondaryFont(with: 12)
    }

    static var defaultInformationMessageTextFont: UIFont {
        return ThemeManager.currentTheme().secondaryFont(with: 14)
    }

    static var defaultTimeLabelTextFont: UIFont {
        return ThemeManager.currentTheme().secondaryFont(with: 8)
    }

    static var defaultMessageAuthorNameFont: UIFont {
        return ThemeManager.currentTheme().secondaryFontBold(with: 11)
    }
    
    static var defaultDeliveryStatusTextFont: UIFont {
        return ThemeManager.currentTheme().secondaryFontBold(with: 10)
    }
    
}
class BaseMessageCell: UICollectionViewCell {
    
    weak var channelLogController: ChannelLogController? {
        didSet {
            resendButton.addTarget(channelLogController, action: #selector(ChannelLogController.presentResendActions(_:)), for: .touchUpInside)
        }
    }
    
    static let scrollIndicatorInset: CGFloat = 5

    static let textViewTopInset: CGFloat = 7
    static let textViewBottomInset: CGFloat = 15
    
    static let bubbleViewMaxWidth: CGFloat = CellSizes.bubbleViewMaxWidth()
    static let bubbleViewMaxHeight: CGFloat = 10000
    
    static let messageTimeHeight: CGFloat = 20
    static var messageTimeWidth: CGFloat = 68

    static let outgoingTextViewLeftInset: CGFloat = 8
    static let outgoingTextViewRightInset: CGFloat = 5
    static let outgoingMessageHorisontalInsets = (2 * (outgoingTextViewLeftInset + outgoingTextViewRightInset)) + 6
    
    static let incomingTextViewLeftInset: CGFloat = 10
    static let incomingTextViewRightInset: CGFloat = 3
    static let incomingTextViewTopInset: CGFloat = incomingMessageAuthorNameLabelHeight
    static let incomingMessageHorisontalInsets = 2 * (incomingTextViewLeftInset + incomingTextViewRightInset)
    static let incomingMessageAuthorNameLeftInset = incomingTextViewLeftInset + 5
    static let incomingMessageAuthorNameLabelMaxWidth = bubbleViewMaxWidth - incomingMessageHorisontalInsets
    static let incomingMessageAuthorNameLabelHeight: CGFloat = 25 // 25
    static let incomingGroupMessageAuthorNameLabelHeightWithInsets: CGFloat = incomingMessageAuthorNameLabelHeight
    static let incomingBubbleOrigin = CGPoint(x: 12, y: 0)

    static let textMessageInsets = incomingTextViewTopInset + textViewBottomInset
    static let defaultTextMessageInsets = textViewBottomInset + textViewTopInset
    
    static let messageTextSize: CGFloat = 13
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 15
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
        
        return view
    }()
    
    lazy var resendButton: UIButton = {
        let resendButton = UIButton(type: .infoDark)
        resendButton.tintColor = .red
        resendButton.isHidden = true
        
        return resendButton
    }()
    
    lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.font = MessageFontsAppearance.defaultMessageAuthorNameFont
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.textColor = ThemeManager.currentTheme().authorNameTextColor
        label.frame.size.height = BaseMessageCell.incomingMessageAuthorNameLabelHeight
        label.frame.origin = CGPoint(x: BaseMessageCell.incomingMessageAuthorNameLeftInset, y: BaseMessageCell.textViewTopInset)

        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = MessageFontsAppearance.defaultTimeLabelTextFont
        label.numberOfLines = 1
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.frame.size.height = BaseMessageCell.messageTimeHeight
        label.frame.size.width = BaseMessageCell.messageTimeWidth
        label.backgroundColor = ThemeManager.currentTheme().inputTextViewColor
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.alpha = 0.85
        label.text = "10:46 AM"

        return label
    }()
    
    lazy var deliveryStatus: UILabel = {
        var deliveryStatus = UILabel()
        deliveryStatus.text = "status"
        deliveryStatus.font = MessageFontsAppearance.defaultDeliveryStatusTextFont
        deliveryStatus.textColor =  ThemeManager.currentTheme().tintColor
        deliveryStatus.isHidden = true
        deliveryStatus.textAlignment = .right
        deliveryStatus.backgroundColor = .clear
        return deliveryStatus
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resendButtonFrame(message: Message) {
        if message.status == messageStatusNotSent {
            resendButton.sizeToFit()
            resendButton.frame.origin = CGPoint(x: frame.width - resendButton.frame.width - 10, y: frame.height - resendButton.frame.height)
            resendButton.isHidden = false
        } else {
            resendButton.frame = CGRect.zero
            resendButton.isHidden = true
        }
    }

    func resendButtonWidth() -> CGFloat {
        if resendButton.frame.width > 0 {
            return resendButton.frame.width + 10
        } else {
            return 0
        }
    }
    
    func setupViews() {
        contentView.addSubview(bubbleView)
        prepareViewsForReuse()
    }

    private func prepareViewsForReuse() {
        nameLabel.text = ""
        nameLabel.textColor = ThemeManager.currentTheme().authorNameTextColor
        timeLabel.backgroundColor = .clear
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        prepareViewsForReuse()
    }
    
    func setupFrameWithLabel(_ x: CGFloat,
                             _ bubbleMaxWidth: CGFloat,
                             _ estimate: CGFloat,
                             _ insets: CGFloat,
                             _ cellHeight: CGFloat,
                             _ spacer: CGFloat = 10) -> CGRect {
        
        var x = x
        if (estimate + BaseMessageCell.messageTimeWidth <=  bubbleMaxWidth) ||
            estimate <= BaseMessageCell.messageTimeWidth {
            x = x - BaseMessageCell.messageTimeWidth + spacer
        }

        var width: CGFloat = estimate + insets
        if (estimate + BaseMessageCell.messageTimeWidth <=  bubbleMaxWidth) ||
            estimate <= BaseMessageCell.messageTimeWidth {
            width = width + BaseMessageCell.messageTimeWidth - spacer
        }

        let rect = CGRect(x: x, y: 0, width: width, height: cellHeight).integral
        
        
        return rect
    }
    
    func configureDeliveryStatus(at indexPath: IndexPath, groupMessages: [MessageSection], message: Message) {

        guard let lastItem = groupMessages.last else { return }
        let lastRow = lastItem.messages.count - 1
        let lastSection = groupMessages.count - 1

        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)

        switch indexPath == lastIndexPath {
        case true:
            deliveryStatus.frame = CGRect(x: frame.width - 80, y: bubbleView.frame.height + 2, width: 70, height: 12)//.integral
            deliveryStatus.text = message.status
            deliveryStatus.isHidden = false
            deliveryStatus.layoutIfNeeded()
        default:
            deliveryStatus.isHidden = true
            deliveryStatus.layoutIfNeeded()
        }
    }
    
}
