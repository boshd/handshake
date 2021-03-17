//
//  ChatInputContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-01-05.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Foundation

public func getInputTextViewMaxHeight() -> CGFloat? {
    if UIDevice.current.orientation.isLandscape {
        if DeviceType.iPhone5orSE {
            return InputContainerViewConstants.maxContainerViewHeightLandscape4Inch
        } else if DeviceType.iPhone678 {
            return InputContainerViewConstants.maxContainerViewHeightLandscape47Inch
        } else if DeviceType.iPhone678p || DeviceType.iPhoneX {
            return InputContainerViewConstants.maxContainerViewHeightLandscape5558inch
        } else {
            return InputContainerViewConstants.maxContainerViewHeightLandscape4Inch
        }
    } else {
        return InputContainerViewConstants.maxContainerViewHeight
    }
}

struct InputContainerViewConstants {
    static let maxContainerViewHeight: CGFloat = 220.0
    static let maxContainerViewHeightLandscape4Inch: CGFloat = 88.0
    static let maxContainerViewHeightLandscape47Inch: CGFloat = 125.0
    static let maxContainerViewHeightLandscape5558inch: CGFloat = 125.0
    static let containerInsetsWithAttachedImages = UIEdgeInsets(top: 175, left: 8, bottom: 8, right: 30)
    static let containerInsetsDefault = UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 30)
}


class ChannelInputContainerView: UIView {

    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout! = nil
    var maxTextViewHeight: CGFloat = 0.0
    
    weak var channelLogController: ChannelLogController? {
        didSet {
            sendButton.addTarget(channelLogController, action: #selector(ChannelLogController.sendMessage), for: .touchUpInside)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            let textSize = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            let maxTextViewHeightRelativeToOrientation: CGFloat! = getInputTextViewMaxHeight()

            if textSize.height >= maxTextViewHeightRelativeToOrientation {
                maxTextViewHeight = maxTextViewHeightRelativeToOrientation
                inputTextView.isScrollEnabled = true
            } else {
                inputTextView.isScrollEnabled = false
                maxTextViewHeight = textSize.height + 12
            }
            return CGSize(width: self.bounds.width, height: maxTextViewHeight)
        }
    }
    
    lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        textView.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 18
        textView.textColor = ThemeManager.currentTheme().generalTitleColor
        textView.textContainerInset = InputContainerViewConstants.containerInsetsDefault
        textView.backgroundColor = .clear
        textView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle

        return textView
    }()
    
    let placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.font = ThemeManager.currentTheme().secondaryFont(with: 14)

        return placeholderLabel
    }()
    
    let sendButton: UIButton = {
        let sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.isEnabled = false

        return sendButton
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = ThemeManager.currentTheme().generalSubtitleColor
        separator.isHidden = false

        return separator
    }()

    deinit {
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        if centeredCollectionViewFlowLayout == nil {
            centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
        }
        
        backgroundColor = ThemeManager.currentTheme().barBackgroundColor
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        
        backgroundColor = .clear

        addSubview(inputTextView)
        addSubview(sendButton)
        addSubview(placeholderLabel)
        inputTextView.addSubview(separator)

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.3).isActive = true

        inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        inputTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true

        placeholderLabel.font = UIFont.systemFont(ofSize: (inputTextView.font!.pointSize - 1))
        placeholderLabel.isHidden = !inputTextView.text.isEmpty
        placeholderLabel.leftAnchor.constraint(equalTo: inputTextView.leftAnchor, constant: 12).isActive = true
        placeholderLabel.rightAnchor.constraint(equalTo: inputTextView.rightAnchor).isActive = true
        placeholderLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: inputTextView.font!.pointSize / 2).isActive = true
        placeholderLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        sendButton.rightAnchor.constraint(equalTo: inputTextView.rightAnchor, constant: -4).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: -4).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = window {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
    }
}


extension ChannelInputContainerView {

    func prepareForSend() {
        inputTextView.text = ""
        sendButton.isEnabled = false
        placeholderLabel.isHidden = false
        inputTextView.isScrollEnabled = false
        resetChatInputConntainerViewSettings()
    }

    func resetChatInputConntainerViewSettings () {
        self.inputTextView.textContainerInset = InputContainerViewConstants.containerInsetsDefault

        separator.isHidden = true
        placeholderLabel.text = "Message"

        if inputTextView.text == "" {
            sendButton.isEnabled = false
        }

        let textBeforeUpdate = inputTextView.text

        inputTextView.text = " "
        inputTextView.invalidateIntrinsicContentSize()
        invalidateIntrinsicContentSize()
        inputTextView.text = textBeforeUpdate
    }
}

extension ChannelInputContainerView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension ChannelInputContainerView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        channelLogController?.collectionView.scrollToBottom(animated: true)
    }

    func textViewDidChange(_ textView: UITextView) {

        placeholderLabel.isHidden = !textView.text.isEmpty

        if textView.text == nil || textView.text == "" {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }

        if textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            sendButton.isEnabled = false
        }

        invalidateIntrinsicContentSize()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            if ChannelLogController.channelLogContainerView.collectionView.contentOffset.y >= (chatLogController!.collectionView!.contentSize.height - chatLogController!.collectionView!.frame.size.height - 200) {
//
//                if chatLogController?.collectionView?.numberOfSections == 2 {
//                    chatLogController?.scrollToBottomOfTypingIndicator()
//                } else {
//                    chatLogController?.scrollToBottom(at: .bottom)
//                }
//            }
//        }
        return true
    }
}

//extension UIColor {
//
//  convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
//    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
//  }
//}



