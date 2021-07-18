//
//  InputContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import AVFoundation

final class InputContainerView: UIControl {

  fileprivate var tap = UITapGestureRecognizer()
  static let messagePlaceholder = "Message..."
    
    func setColors() {
        placeholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
//        sendButton.setTitleColor(ThemeManager.currentTheme().tintColor, for: .normal)
//        sendButton.setTitleColor(.lightGray, for: .disabled)
//        sendButton.backgroundColor = .clear
        
        
//        sendButton.setImage(UIImage(named: "Send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.tintColor = ThemeManager.currentTheme().chatLogSendButtonColor
        sendButton.imageView?.tintColor = ThemeManager.currentTheme().chatLogSendButtonColor
        
        
    }

    weak var channelLogController: ChannelLogController? {
        didSet {
            sendButton.addTarget(channelLogController, action: #selector(channelLogController?.sendMessage), for: .touchUpInside)
        }
    }
  
    lazy var inputTextView: InputTextView = {
        let textView = InputTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.borderColor = ThemeManager.currentTheme().chatInputTextViewBorder
        textView.borderWidth = 2

        return textView
    }()
    
    let placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = messagePlaceholder
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        return placeholderLabel
    }()
    
    let sendButton: InteractiveButton = {
        let sendButton = InteractiveButton(type: .custom)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setImage(UIImage(named: "Send-1")?.withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.isEnabled = false
        sendButton.tintColor = ThemeManager.currentTheme().chatLogSendButtonColor
        sendButton.imageView?.tintColor = ThemeManager.currentTheme().chatLogSendButtonColor

        return sendButton
    }()

    private var heightConstraint_: NSLayoutConstraint!

    private func addHeightConstraints() {
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            if let bottom = window?.safeAreaInsets.bottom {
                heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight + bottom)
            }
        } else {
            heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight)
        }
        
        heightConstraint_.isActive = true
    }

    func confirugeHeightConstraint() {
        let size = inputTextView.sizeThatFits(CGSize(width: inputTextView.bounds.size.width, height: .infinity))
        var height = CGFloat()
            
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            if let bottom = window?.safeAreaInsets.bottom {
                height = size.height + 12 + bottom
            }
        } else {
            height = size.height + 12
        }
        heightConstraint_.constant = height < InputTextViewLayout.maxHeight() ? height : InputTextViewLayout.maxHeight()
        let maxHeight: CGFloat = InputTextViewLayout.maxHeight()
        guard height >= maxHeight else { inputTextView.isScrollEnabled = false; return }
        inputTextView.isScrollEnabled = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputViewResigned),
        name: .inputViewResigned, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(inputViewResponded),
        name: .inputViewResponded, object: nil)
        addHeightConstraints()
        backgroundColor = .clear
        //    sendButton.tintColor = ThemeManager.generalTintColor
        addSubview(inputTextView)
        addSubview(sendButton)
        addSubview(placeholderLabel)
        sendButton.layer.cornerRadius = 15
        sendButton.clipsToBounds = true
        
        setColors()

        tap = UITapGestureRecognizer(target: self, action: #selector(toggleTextView))
        tap.delegate = self

//        if #available(iOS 11.0, *) {
//            inputTextView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
//        } else {
            inputTextView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -5).isActive = true
//        }

        inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        inputTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 6).isActive = true
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            if let bottom = window?.safeAreaInsets.bottom {
                inputTextView.bottomAnchor.constraint(equalTo: bottomAnchor , constant: -6 - bottom).isActive = true
            }
        }

        placeholderLabel.font = UIFont.systemFont(ofSize: (inputTextView.font!.pointSize))
        placeholderLabel.isHidden = !inputTextView.text.isEmpty
        placeholderLabel.leftAnchor.constraint(equalTo: inputTextView.leftAnchor, constant: 12).isActive = true
        placeholderLabel.rightAnchor.constraint(equalTo: inputTextView.rightAnchor).isActive = true
//        placeholderLabel.topAnchor.constraint(equalTo: attachCollectionView.bottomAnchor,
//                                              constant: inputTextView.font!.pointSize / 2.3).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor, constant: 0).isActive = true
        placeholderLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        sendButton.rightAnchor.constraint(equalTo: inputTextView.rightAnchor, constant: -4).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: -4).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        if #available(iOS 11.0, *) {
            sendButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
        } else {
            sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    @objc func toggleTextView () {
        inputTextView.inputView = nil
        inputTextView.reloadInputViews()
        UIView.performWithoutAnimation {
            inputTextView.resignFirstResponder()
            inputTextView.becomeFirstResponder()
        }
    }

    @objc fileprivate func inputViewResigned() {
        inputTextView.removeGestureRecognizer(tap)
    }

    @objc fileprivate func inputViewResponded() {
        guard let recognizers = inputTextView.gestureRecognizers else { return }
        
        guard !recognizers.contains(tap) else { return }
        inputTextView.addGestureRecognizer(tap)
    }

    func resignAllResponders() {
        inputTextView.resignFirstResponder()
    }
}

extension InputContainerView {
  
    func prepareForSend() {
        inputTextView.text = ""
        sendButton.isEnabled = false
        placeholderLabel.isHidden = false
        inputTextView.isScrollEnabled = false
        resetChatInputConntainerViewSettings()
      }

    func resetChatInputConntainerViewSettings() {
        inputTextView.textContainerInset = InputTextViewLayout.defaultInsets
        placeholderLabel.text = InputContainerView.messagePlaceholder
        sendButton.isEnabled = !inputTextView.text.isEmpty
        confirugeHeightConstraint()
    }

      func expandCollection() {
        sendButton.isEnabled = (!inputTextView.text.isEmpty)
        inputTextView.textContainerInset = InputTextViewLayout.extendedInsets
        confirugeHeightConstraint()
      }
}

extension InputContainerView: UIGestureRecognizerDelegate {
  
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false
    }
    
}

extension InputContainerView: UITextViewDelegate {

    private func handleSendButtonState() {
       let whiteSpaceIsEmpty = inputTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
       if (inputTextView.text != "" && !whiteSpaceIsEmpty) {
         sendButton.isEnabled = true
       } else {
         sendButton.isEnabled = false
       }
     }

     func textViewDidChange(_ textView: UITextView) {
        confirugeHeightConstraint()
        placeholderLabel.isHidden = !textView.text.isEmpty
        channelLogController?.isTyping = !textView.text.isEmpty
        handleSendButtonState()
     }

     func textViewDidEndEditing(_ textView: UITextView) {
     }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n", let channelLogController = self.channelLogController else { return true }
        if channelLogController.isScrollViewAtTheBottom() {
            channelLogController.collectionView.scrollToBottom(animated: false)
        }
        return true
    }
}

