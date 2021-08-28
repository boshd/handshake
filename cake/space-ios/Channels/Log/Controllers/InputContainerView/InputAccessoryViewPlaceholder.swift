//
//  InputAccessoryViewPlaceholder.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-25.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol InputAccessoryViewPlaceholderDelegate: AnyObject {
    func inputAccessoryPlaceholderKeyboardIsPresenting(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve, beginFrame: CGRect, endFrame: CGRect)
    func inputAccessoryPlaceholderKeyboardDidPresent()
    func inputAccessoryPlaceholderKeyboardIsDismissing(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve, beginFrame: CGRect, endFrame: CGRect)
    func inputAccessoryPlaceholderKeyboardDidDismiss()
    func inputAccessoryPlaceholderKeyboardIsDismissingInteractively()
    func inputAccessoryPlaceholderKeyboardDidChangeFrame(beginFrame: CGRect, endFrame: CGRect, animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve)
}

// MARK: -

/// Input accessory views always render at the full width of the window.
/// This wrapper allows resizing the accessory view to fit within its
/// presenting view.
@objc
public class InputAccessoryViewPlaceholder: UIView {
    @objc
    public weak var delegate: InputAccessoryViewPlaceholderDelegate?

    /// The amount of the application frame that is overlapped
    /// by the keyboard.
    @objc
    public var keyboardOverlap: CGFloat {
        // Subtract our own height as this view is not actually
        // visible, but is represented in the keyboard.

        let ownHeight = superview != nil ? desiredHeight : 0

        return max(0, visibleKeyboardHeight - ownHeight)
    }

    @objc
    weak var referenceView: UIView?

    private var visibleKeyboardHeight: CGFloat {
        guard var keyboardFrame = transitioningKeyboardFrame ?? superview?.frame else { return 0 }

        guard keyboardFrame.height > 0 else { return 0 }

        let referenceFrame: CGRect

        if let referenceView = referenceView {
            keyboardFrame = referenceView.convert(keyboardFrame, from: nil)
            referenceFrame = referenceView.frame
        } else {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            referenceFrame = keyWindow?.frame ?? .zero
        }

        // Measure how much of the keyboard is currently offscreen.
        let offScreenHeight = keyboardFrame.maxY - referenceFrame.maxY

        // The onscreen region represents the overlap.
        return max(0, keyboardFrame.height - offScreenHeight)
    }

    private var transitioningKeyboardFrame: CGRect? {
        switch keyboardState {
        case .dismissing:
            return .zero
        case .presenting(let frame):
            return frame
        default:
            return nil
        }
    }

    /// The height that the accessory view should take up. This is
    /// automatically subtracted from the keyboard overlap and is
    /// intended to represent the extent to which you want the
    /// accessory view to overlap the presenting view, primarily
    /// for the purpose of defining the start point for interactive
    /// dismissals.
    @objc
    public var desiredHeight: CGFloat {
        set {
            guard newValue != desiredHeight else { return }
            heightConstraint.constant = newValue
            UIView.performWithoutAnimation {
                heightConstraintView.layoutIfNeeded()
                self.layoutIfNeeded()
                superview?.layoutIfNeeded()
            }
        }
        get {
            return heightConstraint.constant
        }
    }

    private let heightConstraintView = UIView()

    // TODO
    private lazy var heightConstraint: NSLayoutConstraint = {
        addSubview(heightConstraintView)
        //heightConstraintView.autoPinHeightToSuperview()
        //return heightConstraintView.autoSetDimension(.height, toSize: 0)
        return NSLayoutConstraint()
    }()

    enum KeyboardState: CustomStringConvertible {
        case dismissed
        case dismissing
        case presented
        case presenting(frame: CGRect)

        public var description: String {
            switch self {
            case .dismissed:
                return "dismissed"
            case .dismissing:
                return "dismissing"
            case .presented:
                return "presented"
            case .presenting:
                return "presenting"
            }
        }
    }
    var keyboardState: KeyboardState = .dismissed

    public init() {
        super.init(frame: .zero)

        // Disable user interaction, the accessory view
        // should never actually contain any UI.
        isUserInteractionEnabled = true
        autoresizingMask = .flexibleHeight

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDismiss),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidDismiss),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillPresent),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidPresent),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrame),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        return .zero
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        // By observing the "center" property of our superview, we can
        // follow along as the keyboard moves up and down.
        superview?.removeObserver(self, forKeyPath: "center")
        newSuperview?.addObserver(self, forKeyPath: "center", options: [.initial, .new], context: nil)
    }

    deinit {
        superview?.removeObserver(self, forKeyPath: "center")
    }

    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        // Do nothing unless the keyboard is currently presented.
        // We're only checking for interactive dismissal, which
        // can only happen while presented.
        guard case .presented = keyboardState else { return }

        guard superview != nil else { return }

        // While the visible keyboard height is greater than zero,
        // and the keyboard is presented, we can safely assume
        // an interactive dismissal is in progress.
        if visibleKeyboardHeight > 0 {
//            delegate?.inputAccessoryPlaceholderKeyboardIsDismissingInteractively()
        }
    }
    
    func add(_ inputView: UIView) {
        for subview in self.subviews
        where subview is InputContainerView {
            subview.removeFromSuperview()
        }

        inputView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(inputView)
        inputView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        inputView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        inputView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        inputView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    // MARK: - Presentation / Dismissal wrangling.

    @objc
    private func keyboardWillPresent(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve)
        else { return }

        // We only want to do an animated presentation if either a) the height changed or b) the view is
        // starting from off the bottom of the screen (a full presentation). This provides the best experience
        // when canceling an interactive dismissal or changing orientations.
        guard beginFrame.height != endFrame.height || beginFrame.minY == UIScreen.main.bounds.height else { return }

        keyboardState = .presenting(frame: endFrame)

        delegate?.inputAccessoryPlaceholderKeyboardIsPresenting(animationDuration: animationDuration, animationCurve: animationCurve, beginFrame: beginFrame, endFrame: endFrame)
    }

    @objc
    private func keyboardDidPresent(_ notification: Notification) {
        keyboardState = .presented
        delegate?.inputAccessoryPlaceholderKeyboardDidPresent()
    }

    @objc
    private func keyboardWillDismiss(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve)
        else { return }


        keyboardState = .dismissing

        delegate?.inputAccessoryPlaceholderKeyboardIsDismissing(animationDuration: animationDuration, animationCurve: animationCurve, beginFrame: beginFrame, endFrame: endFrame)
    }

    @objc
    private func keyboardDidDismiss(_ notification: Notification) {
        keyboardState = .dismissed
        delegate?.inputAccessoryPlaceholderKeyboardDidDismiss()
    }
    
    @objc
    private func keyboardDidChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve)
        else { return }
        
        // delegate?.inputAccessoryPlaceholderKeyboardDidChangeFrame(beginFrame: beginFrame, endFrame: endFrame, animationDuration: animationDuration, animationCurve: animationCurve)
        
    }
}
