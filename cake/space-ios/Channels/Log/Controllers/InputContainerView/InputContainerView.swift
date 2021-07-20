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
  static let messagePlaceholder = "Aa"
    
    func setColors() {
//        backgroundColor = .red
        placeholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
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
//        sendButton.backgroundColor = ThemeManager.currentTheme().tintColor
//        sendButton.layer.cornerRadius = 16
//        sendButton.contentMode = .center
        sendButton.contentMode = .scaleAspectFit
//        sendButton.clipsToBounds = true
//        sendButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 3)
        
        return sendButton
    }()

    var heightConstraint_: NSLayoutConstraint!

    private func addHeightConstraints() {
        
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
//            if let bottom = window?.safeAreaInsets.bottom {
//                heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight() + bottom)
//            }
//        } else {
////        heightConstraint_ = heightAnchor.constraint(equalToConstant: self.frame.height)
////            heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight())
//        }
//
        
        if !heightConstraint_.isActive {
            heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight())
            heightConstraint_.isActive = true
        }
    }

    func confirugeHeightConstraint() {
        
        print(hexStringFromColor(color: .handshakeBlue))
        
//        let size = inputTextView.sizeThatFits(CGSize(width: inputTextView.bounds.size.width, height: .infinity))
//        var height = CGFloat()
//        height = size.height + 12
//
//        if height >= InputTextViewLayout.maxHeight() {
//            if heightConstraint_ != nil {
//                heightConstraint_.constant = InputTextViewLayout.maxHeight()
//            } else {
//                heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.maxHeight())
//            }
//            heightConstraint_.isActive = true
//        } else {
//            print("htcrrdrydddttdtrdtrrdrtdrtrtdrttr")
//            if heightConstraint_ != nil {
//                print("pre is active? \(heightConstraint_.isActive)")
//                print("pre is nil? \(heightConstraint_ == nil)")
//                removeConstraint(heightConstraint_)
//                reloadInputViews()
//                print("is active? \(heightConstraint_.isActive)")
//                print("is nil? \(heightConstraint_ == nil)")
////                heightConstraint_ = nil
////                heightConstraint_.isActive = false
//            }
//        }
//        heightConstraint_.constant = height < InputTextViewLayout.maxHeight() ? height : InputTextViewLayout.maxHeight()
        
//        let maxHeight: CGFloat = InputTextViewLayout.maxHeight()
//        guard height >= maxHeight else { inputTextView.isScrollEnabled = false; return }
//        inputTextView.isScrollEnabled = true
    }
    
//    open override func didMoveToWindow() {
//        super.didMoveToWindow()
//        print("DID MOVE")
//        if #available(iOS 11.0, *) {
//            guard let window = window else { return }

            // bottomAnchor must be set to the window to avoid a memory leak issue
//            bottomStackViewLayoutSet?.bottom?.isActive = false
//            bottomStackViewLayoutSet?.bottom = bottomStackView.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1)
//            bottomStackViewLayoutSet?.bottom?.isActive = true
            
//            heightConstraint_ = heightAnchor.constraint(equalToConstant: frame.height)
//
//            heightConstraint_.isActive = true
//        }
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // This is required to make the view grow vertically
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        
        // this is where the fram magic happens
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputViewResigned),
        name: .inputViewResigned, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(inputViewResponded),
        name: .inputViewResponded, object: nil)
//        addHeightConstraints()
        
        addSubview(inputTextView)
        addSubview(sendButton)
        addSubview(placeholderLabel)
        
        setColors()

        tap = UITapGestureRecognizer(target: self, action: #selector(toggleTextView))
        tap.delegate = self

        inputTextView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -5).isActive = true

        inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        inputTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
//            if let bottom = window?.safeAreaInsets.bottom {
                inputTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor , constant: -7).isActive = true
//            }
//        }

        placeholderLabel.font = UIFont.systemFont(ofSize: (inputTextView.font!.pointSize))
        placeholderLabel.isHidden = !inputTextView.text.isEmpty
        placeholderLabel.leftAnchor.constraint(equalTo: inputTextView.leftAnchor, constant: 12).isActive = true
        placeholderLabel.rightAnchor.constraint(equalTo: inputTextView.rightAnchor).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor, constant: 0).isActive = true
        placeholderLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

//        sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -9).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        if #available(iOS 11.0, *) {
            sendButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        } else {
            sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        }
        
        let blurEffect = ThemeManager.currentTheme().tabBarBlurEffect
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        sendSubviewToBack(blurEffectView)
    }
    
    override var intrinsicContentSize: CGSize {
        // Calculate intrinsicContentSize that will fit all the text
        let textSize = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: self.bounds.width, height: textSize.height)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    @objc func toggleTextView () {
//        inputTextView.inputView = nil
//        inputTextView.reloadInputViews()
        print("sdckmd1")
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

