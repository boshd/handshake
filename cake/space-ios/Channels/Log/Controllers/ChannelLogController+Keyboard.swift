//
//  ChannelLogController+Keyboard.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelLogController {
    
    @objc open dynamic func keyboardDidShow(_ notification: Notification) {
    }
    
    @objc open dynamic func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: rawAnimationCurve) else {
                return
        }
        // We only want to do an animated presentation if either a) the height changed or b) the view is
        // starting from off the bottom of the screen (a full presentation). This provides the best experience
        // when canceling an interactive dismissal or changing orientations.
        guard beginFrame.height != endFrame.height || beginFrame.minY == UIScreen.main.bounds.height else { return }
        
        handleKeyboardStateChange(animationDuration: animationDuration, animationCurve: animationCurve)
    }
    
    @objc open dynamic func keyboardDidHide(_ notification: Notification) {
    }

    @objc open dynamic func keyboardWillHide(_ notification: Notification) {
    }
    
    private func handleKeyboardStateChange(animationDuration: TimeInterval,
                                           animationCurve: UIView.AnimationCurve) {
        
        if let transitionCoordinator = self.transitionCoordinator,
           transitionCoordinator.isInteractive {
            return
        }
        
        if shouldAnimateKeyboardChanges, animationDuration > 0 {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                print("shouldAnimateKeyboardChanges")
                self?.updateContentInsets(animated: true)
            }
        } else {
            updateContentInsets(animated: false)
        }
        
    }
    
    @objc(updateContentInsetsAnimated:)
    public func updateContentInsets(animated: Bool) {
        
    }
}
