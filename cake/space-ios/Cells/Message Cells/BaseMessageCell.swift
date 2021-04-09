//
//  BaseMessageCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-06-02.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
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
        return ThemeManager.currentTheme().secondaryFont(with: 9)
    }

    static var defaultMessageAuthorNameFont: UIFont {
        return ThemeManager.currentTheme().secondaryFontBold(with: 9)
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

    static let textViewTopInset: CGFloat = 10
    static let textViewBottomInset: CGFloat = 25
    
    static let bubbleViewMaxWidth: CGFloat = CellSizes.bubbleViewMaxWidth()
    static let bubbleViewMaxHeight: CGFloat = 10000
    
    static let messageTimeHeight: CGFloat = 20
    static var messageTimeWidth: CGFloat = 68

    static let outgoingTextViewLeftInset: CGFloat = 10
    static let outgoingTextViewRightInset: CGFloat = 8
    static let outgoingMessageHorisontalInsets = (2 * (outgoingTextViewLeftInset + outgoingTextViewRightInset))
    
    static let incomingTextViewLeftInset: CGFloat = 10
    static let incomingTextViewRightInset: CGFloat = 3
    static let incomingTextViewTopInset: CGFloat = incomingMessageAuthorNameLabelHeight
    static let incomingMessageHorisontalInsets = 2 * (incomingTextViewLeftInset + incomingTextViewRightInset)
    static let incomingMessageAuthorNameLeftInset = incomingTextViewLeftInset + 5
    static let incomingMessageAuthorNameLabelMaxWidth = bubbleViewMaxWidth - incomingMessageHorisontalInsets
    static let incomingMessageAuthorNameLabelHeight: CGFloat = 25 // 25
    static let incomingGroupMessageAuthorNameLabelHeightWithInsets: CGFloat = incomingMessageAuthorNameLabelHeight
    static let incomingBubbleOrigin = CGPoint(x: 5, y: 0)

    static let textMessageInsets = incomingTextViewTopInset + textViewBottomInset
    static let defaultTextMessageInsets = textViewBottomInset + textViewTopInset
    
    static let messageTextSize: CGFloat = 12
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.cornerRadius = 20
        view.layer.cornerCurve = .continuous

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
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        label.alpha = 0.85
        label.text = "10:46 AM"

        return label
    }()
    
    lazy var deliveryStatus: UILabel = {
        var deliveryStatus = UILabel()
        deliveryStatus.text = "status"
        deliveryStatus.font = MessageFontsAppearance.defaultDeliveryStatusTextFont
        deliveryStatus.textColor =  ThemeManager.currentTheme().generalSubtitleColor
        deliveryStatus.isHidden = true
        deliveryStatus.textAlignment = .right

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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(bubbleView)
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
//    
//    static let landscapeBubbleViewMaxWidth: CGFloat = CellSizes.landscapeBubbleViewMaxWidth()
//    static let bubbleViewMaxWidth: CGFloat = CellSizes.bubbleViewMaxWidth()
//    static let messageTimeHeight: CGFloat = 0
//    
//    static let textViewBottomInset: CGFloat = 6
//    static let incomingGroupMessageAuthorNameLabelHeight: CGFloat = 25
//    static let incomingMessageAuthorNameLeftInset = incomingTextViewLeftInset
//    static let groupIncomingTextViewTopInset: CGFloat = incomingGroupMessageAuthorNameLabelHeight
//    
//    static let outgoingTextViewLeftInset: CGFloat = 2
//    
//    static let outgoingTextViewRightInset: CGFloat = 2
//    
//    static let bubbleViewMaxHeight: CGFloat = 10000
//    
//    static let textViewTopInset: CGFloat = 6
//    
//    static let groupTextMessageInsets = groupIncomingTextViewTopInset + textViewBottomInset
//    
//    static let defaultTextMessageInsets = textViewBottomInset + textViewTopInset
//    
//    static let scrollIndicatorInset: CGFloat = 10
//    
//    static let incomingBubbleOrigin = CGPoint(x: 5, y: 0)
//    
//    static let incomingMessageHorisontalInsets = 2 * (incomingTextViewLeftInset + incomingTextViewRightInset) - 40
//    
//    static let incomingGroupMessageAuthorNameLabelMaxWidth = bubbleViewMaxWidth - incomingMessageHorisontalInsets
//    
//    static let outgoingMessageHorisontalInsets = (2 * (outgoingTextViewLeftInset + outgoingTextViewRightInset))
//    
//    static let textMessageInsets = groupIncomingTextViewTopInset + textViewBottomInset
//    
//    static var messageTimeWidth: CGFloat {
//        if DeviceType.IS_IPAD_PRO {
//            return 95
//        } else {
//            return 68
//        }
//    }
//    
//    weak var message: Message?
//    weak var channelLogController: ChannelLogController?
//
//    static let incomingTextViewTopInset: CGFloat = 10
//    static let incomingTextViewBottomInset: CGFloat = 10
//    static let incomingTextViewLeftInset: CGFloat = 12
//    static let incomingTextViewRightInset: CGFloat = 7
//
//    let nameLabel: UILabel = {
//        let nameLabel = UILabel()
//        nameLabel.font = UIFont.systemFont(ofSize: 13)
//        nameLabel.numberOfLines = 1
//        nameLabel.backgroundColor = .clear
//        nameLabel.textColor = .green
//
//        return nameLabel
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame.integral)
//        
//        setupViews()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setupTimestampView(message: Message, isOutgoing: Bool) {
//        DispatchQueue.main.async {
//            let view = self.channelLogController?.collectionView.dequeueReusableRevealableView(withIdentifier: "timestamp") as? TimestampView ?? TimestampView()
//            view.titleLabel.text = message.convertedTimestamp
//            view.backgroundColor = .black
//            let style: RevealStyle = isOutgoing ? .over : .over
//            self.setRevealableView(view, style: style, direction: .left)
//        }
//    }
//
//    func setupViews() {
//        contentView.backgroundColor = .green
////        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//    }
//
//    func prepareViewsForReuse() {}
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        prepareViewsForReuse()
//    }
//    
//}
//    
//    
//    var message: Message?
//    var channelLogController: ChannelLogController?
//
//    static let incomingTextViewTopInset: CGFloat = 15
//    static let incomingTextViewBottomInset: CGFloat = 15
//    static let incomingTextViewLeftInset: CGFloat = 15
//    static let incomingTextViewRightInset: CGFloat = 15
    

//    
//    let bubbleView: UIView = {
//        let bubbleView = UIView()
//        bubbleView.backgroundColor = .blue
//        bubbleView.isUserInteractionEnabled = true
//        
//        return bubbleView
//    }()
//    
//    var deliveryStatus: UILabel = {
//        var deliveryStatus = UILabel()
//        deliveryStatus.translatesAutoresizingMaskIntoConstraints = false
//        deliveryStatus.text = "status"
//        deliveryStatus.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
//        deliveryStatus.textColor = .systemBlue
//        deliveryStatus.isHidden = true
//        deliveryStatus.textAlignment = .right
//        
//        return deliveryStatus
//    }()
//    
//    lazy var timeLabel: UILabel = {
//        let timeLabel = UILabel()
//        timeLabel.font = MessageFontsAppearance.defaultTimeLabelTextFont
//        timeLabel.numberOfLines = 1
//        timeLabel.textColor = .gray
//        timeLabel.frame.size.height = BaseMessageCell.messageTimeHeight
//        timeLabel.frame.size.width = BaseMessageCell.messageTimeWidth
//        // timeLabel.backgroundColor = .darkGray
//        timeLabel.layer.masksToBounds = true
//        timeLabel.layer.cornerRadius = 10
//        timeLabel.textAlignment = .center
//        timeLabel.alpha = 0.85
//
//        return timeLabel
//    }()
//    
//    let nameLabel: UILabel = {
//        let nameLabel = UILabel()
//        nameLabel.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
//        nameLabel.numberOfLines = 1
//        nameLabel.backgroundColor = .clear
//        nameLabel.textColor = .priorityNavyBlue()
//        nameLabel.frame.size.height = BaseMessageCell.incomingGroupMessageAuthorNameLabelHeight
//        nameLabel.frame.origin = CGPoint(x: BaseMessageCell.incomingMessageAuthorNameLeftInset, y: BaseMessageCell.textViewTopInset)
//        
//        return nameLabel
//    }()
//
//    
//    func setupViews() {
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//    }
//    
//    func setupTimestampView(message: Message, isOutgoing:Bool) {
//        DispatchQueue.main.async {
//            if let view = self.channelLogController?.collectionView.dequeueReusableRevealableView(withIdentifier: "timestamp") as? TimestampView {
//                view.titleLabel.text = message.convertedTimestamp
//                let style: RevealStyle = isOutgoing ? .slide : .over
//                self.setRevealableView(view, style: style, direction: .left)
//            }
//        }
//    }
//    
//    func setupFrameWithLabel(_ x: CGFloat, _ bubbleMaxWidth: CGFloat, _ estimate: CGFloat,
//                             _ insets: CGFloat, _ cellHeight: CGFloat, _ spacer: CGFloat = 10) -> CGRect {
//        var x = x
//        if (estimate + BaseMessageCell.messageTimeWidth <=  bubbleMaxWidth) ||
//        estimate <= BaseMessageCell.messageTimeWidth {
//            x = x - BaseMessageCell.messageTimeWidth + spacer
//        }
//
//        var width: CGFloat = estimate + insets
//        if (estimate + BaseMessageCell.messageTimeWidth <=  bubbleMaxWidth) ||
//        estimate <= BaseMessageCell.messageTimeWidth {
//             width = width + BaseMessageCell.messageTimeWidth - spacer
//        }
//
//        let rect = CGRect(x: x, y: 0, width: width, height: cellHeight).integral
//        return rect
//        
//        
//    }
//    
//    func configureDeliveryStatus(at indexPath: IndexPath, groupMessages: [MessageSection], message: Message) {
//
//        guard let lastItem = groupMessages.last else { return }
//        let lastRow = lastItem.messages.count - 1
//        let lastSection = groupMessages.count - 1
//
//        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
//
//        switch indexPath == lastIndexPath {
//            case true:
//                deliveryStatus.frame = CGRect(x: frame.width - 80, y: bubbleView.frame.height + 2, width: 70, height: 12)
//                deliveryStatus.text = message.status
//                deliveryStatus.isHidden = false
//                deliveryStatus.layoutIfNeeded()
//
//            default:
//                deliveryStatus.isHidden = true
//                deliveryStatus.layoutIfNeeded()
//        }
//    }
//    
//    func prepareViewsForReuse() {
//        nameLabel.text = ""
//        nameLabel.textColor = .priorityNavyBlue()
////        timeLabel.backgroundColor = .clear
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        prepareViewsForReuse()
//    }
//    
//}
