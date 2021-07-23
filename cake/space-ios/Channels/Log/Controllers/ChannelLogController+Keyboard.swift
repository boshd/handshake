//
//  ChannelLogController+Keyboard.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelLogController {
    
    @objc
    open dynamic func keyboardDidShow(_ notification: Notification) {
        keyboardState = .presented
        guard let userInfo = notification.userInfo,
            let keyboardFrame: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.keyboardHeight = keyboardHeight
        
    }
    
    @objc
    open dynamic func keyboardWillShow(_ notification: Notification) {
        if first {
            first = false
            return
        }
        print("Keyboard will show")
        guard let userInfo = notification.userInfo,
            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let keyboardFrame: NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let rawAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        // We only want to do an animated presentation if either a) the height changed or b) the view is
        // starting from off the bottom of the screen (a full presentation). This provides the best experience
        // when canceling an interactive dismissal or changing orientations.
        guard beginFrame.height != endFrame.height || beginFrame.minY == UIScreen.main.bounds.height else { return }
        
        self.collectionView.contentInset.bottom = keyboardHeight
        self.collectionView.contentOffset.y = (collectionView.contentSize.height - collectionView.bounds.size.height) + (collectionView.contentInset.bottom) + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc
    open dynamic func keyboardDidHide(_ notification: Notification) {
        keyboardHeight = .zero
    }

    @objc
    open dynamic func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        print("keyboardWillHide")
        self.collectionView.contentInset.bottom = (keyboardHeight + inputContainerView.frame.height)
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
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
            // from start, before shouldAnimateKeyboardChanges is set
            updateContentInsets(animated: false)
        }
        
    }
    
    @objc
    public func updateContentInsets(animated: Bool) {
        
        view.layoutIfNeeded()
        
        let oldInsets = collectionView.contentInset
        var newInsets = oldInsets

        // if keyboard is collapsed, inputContainerView.frame.height will include
        // bottom safe area inset.
        
        
        newInsets.bottom = (keyboardHeight + inputContainerView.frame.height)
        
        print("keyboardHeight", keyboardHeight)
        
        //newInsets.bottom = inputContainerView.frame.height
        
        // we'll figure this part out later
        // if isChannelLogHeaderShowing {
        //     newInsets.top = channelLogContainerView.channelLogHeaderView.frame.height
        // }
        
        // (collectionView.contentSize.height - collectionView.bounds.size.height) + (collectionView.contentInset.bottom) + view.safeAreaInsets.bottom)

        // Changing the contentInset can change the contentOffset, so make sure we
        // stash the current value before making any changes.
        let oldYOffset = collectionView.contentOffset.y

        let didChangeInsets = oldInsets != newInsets
        
        // CONTENT INSETTING
        UIView.performWithoutAnimation {
            if didChangeInsets {
                let contentOffset = collectionView.contentOffset
                self.collectionView.contentInset = newInsets
                //self.collectionView.setContentOffset(contentOffset, animated: false)
                self.collectionView.contentOffset.y = (collectionView.contentSize.height - collectionView.bounds.size.height) + (collectionView.contentInset.bottom) + view.safeAreaInsets.bottom
            }
            self.collectionView.scrollIndicatorInsets = newInsets
        }


        // If we were scrolled away from the bottom, shift the content in lockstep with the
        // keyboard, up to the limits of the content bounds.
//        let insetChange = newInsets.bottom - oldInsets.bottom
//
//        // CONTENT OFFSETTING
//
//        // Only update the content offset if the inset has changed.
//        if insetChange != 0 {
//            print("will offset")
//            // The content offset can go negative, up to the size of the top layout guide.
//            // This accounts for the extended layout under the navigation bar.
//            var minYOffset = -view.safeAreaInsets.top
//
//            if !channelLogContainerView.channelLogHeaderView.isHidden {
//                minYOffset -= channelLogContainerView.channelLogHeaderView.frame.height
//            }
//
//            let newYOffset = (oldYOffset + insetChange).clamped(to: minYOffset...safeContentHeight)
//            let newOffset = CGPoint(x: 0, y: newYOffset)
//
//            // This offset change will be animated by UIKit's UIView animation block
//            // which updateContentInsets() is called within
//            collectionView.setContentOffset(newOffset, animated: false)
//        }
        
    }

}
