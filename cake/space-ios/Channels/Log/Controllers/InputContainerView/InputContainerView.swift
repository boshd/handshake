//
//  InputContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import AVFoundation


//@objc
//public protocol InputContainerViewDelegate: AnyObject {
//    func inputContainerViewKeyboardIsPresenting(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve)
//    func inputContainerViewKeyboardDidPresent()
//    func inputContainerViewKeyboardIsDismissing(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve)
//    func inputContainerViewKeyboardDidDismiss()
//    func inputContainerViewKeyboardIsDismissingInteractively()
//}

@objc
final class InputContainerView: UIView {
    
    public init() {
        super.init(frame: .zero)

        addSubview(inputTextView)
        addSubview(sendButton)
        addSubview(placeholderLabel)
        
        setColors()

        tap = UITapGestureRecognizer(target: self, action: #selector(toggleTextView))
        tap.delegate = self

        inputTextView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -5).isActive = true

        inputTextView.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        inputTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true

        inputTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor , constant: -7).isActive = true

        placeholderLabel.font = UIFont.systemFont(ofSize: (inputTextView.font!.pointSize))
        placeholderLabel.isHidden = !inputTextView.text.isEmpty
        placeholderLabel.leftAnchor.constraint(equalTo: inputTextView.leftAnchor, constant: 12).isActive = true
        placeholderLabel.rightAnchor.constraint(equalTo: inputTextView.rightAnchor).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor, constant: 0).isActive = true
        placeholderLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        sendButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -9).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        if #available(iOS 11.0, *) {
            sendButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        } else {
            sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        }
        
//        blurEffectView = UIVisualEffectView(effect: ThemeManager.currentTheme().tabBarBlurEffect)
//
//        let blurEffect = ThemeManager.currentTheme().tabBarBlurEffect
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
        
//        self.blurEffectView = UIVisualEffectView(effect: ThemeManager.currentTheme().tabBarBlurEffect)
//        backgroundColor = ThemeManager.currentTheme().inputBarContainerViewBackgroundColor
        
//        addSubview(blurEffectView)
        
//        sendSubviewToBack(blurEffectView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  fileprivate var tap = UITapGestureRecognizer()
  static let messagePlaceholder = "Aa"
    
    func setColors() {
        backgroundColor = ThemeManager.currentTheme().inputBarContainerViewBackgroundColor

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
        sendButton.contentMode = .scaleAspectFit
        return sendButton
    }()

    var heightConstraint_: NSLayoutConstraint!

    private func addHeightConstraints() {
        // TBD
        
        if !heightConstraint_.isActive {
            heightConstraint_ = heightAnchor.constraint(equalToConstant: InputTextViewLayout.minHeight())
            heightConstraint_.isActive = true
        }
    }

    func confirugeHeightConstraint() {}
    
//    public override func observeValue(
//        forKeyPath keyPath: String?,
//        of object: Any?,
//        change: [NSKeyValueChangeKey: Any]?,
//        context: UnsafeMutableRawPointer?
//    ) {
//        // Do nothing unless the keyboard is currently presented.
//        // We're only checking for interactive dismissal, which
//        // can only happen while presented.
//        guard case .presented = keyboardState else { return }
//
//        guard superview != nil else { return }
//
//        // While the visible keyboard height is greater than zero,
//        // and the keyboard is presented, we can safely assume
//        // an interactive dismissal is in progress.
//        if visibleKeyboardHeight > 0 {
//            delegate?.inputContainerViewKeyboardIsDismissingInteractively()
//        }
//    }
    
    
    
    override var intrinsicContentSize: CGSize {
        // Calculate intrinsicContentSize that will fit all the text
        let textSize = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: self.bounds.width, height: textSize.height)
    }
//
//    public override var intrinsicContentSize: CGSize {
//        return .zero
//    }
//
//    public override func willMove(toSuperview newSuperview: UIView?) {
//        super.willMove(toSuperview: newSuperview)
//        print("WILLMOVE")
//        // By observing the "center" property of our superview, we can
//        // follow along as the keyboard moves up and down.
//        superview?.removeObserver(self, forKeyPath: "center")
//        newSuperview?.addObserver(self, forKeyPath: "center", options: [.initial, .new], context: nil)
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            channelLogController.scrollToBottom(animated: false)
        }
        return true
    }
}

//extension InputContainerView {
//    @objc
//    public dynamic func keyboardDidPresent(_ notification: Notification) {
//        keyboardState = .presented
//        delegate?.inputContainerViewKeyboardDidPresent()
//    }
//
//    @objc
//    public dynamic func keyboardWillPresent(_ notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
//            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
//            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
//            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
//            let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve)
//        else { return }
//
//        // We only want to do an animated presentation if either a) the height changed or b) the view is
//        // starting from off the bottom of the screen (a full presentation). This provides the best experience
//        // when canceling an interactive dismissal or changing orientations.
//        guard beginFrame.height != endFrame.height || beginFrame.minY == UIScreen.main.bounds.height else { return }
//
//        keyboardState = .presenting(frame: endFrame)
//
//        delegate?.inputContainerViewKeyboardIsPresenting(animationDuration: animationDuration, animationCurve: animationCurve)
//    }
//
//    @objc
//    public dynamic func keyboardDidDismiss(_ notification: Notification) {
//        keyboardState = .dismissed
//        delegate?.inputContainerViewKeyboardDidDismiss()
//    }
//
//    @objc
//    public dynamic func keyboardWillDismiss(_ notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
//            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
//            let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve)
//        else { return }
//        keyboardState = .dismissing
//        delegate?.inputContainerViewKeyboardIsDismissing(animationDuration: animationDuration, animationCurve: animationCurve)
//    }
//}
//
