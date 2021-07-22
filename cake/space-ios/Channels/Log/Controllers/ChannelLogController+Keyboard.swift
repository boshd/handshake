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
        if first {
            first = false
            return
        }
        print("Keyboard will show")
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
        
        // newInsets.bottom = inputContainerView.frame.height + view.safeAreaInsets.bottom
        
        newInsets.bottom = inputContainerView.frame.height
        
        print("inputContainerView.frame.height", inputContainerView.frame.height)
        print("view.safeAreaInsets.bottom", view.safeAreaInsets.bottom)
        
        if isChannelLogHeaderShowing {
            newInsets.top = channelLogContainerView.channelLogHeaderView.frame.height
        }

        // Changing the contentInset can change the contentOffset, so make sure we
        // stash the current value before making any changes.
        let oldYOffset = collectionView.contentOffset.y

        let didChangeInsets = oldInsets != newInsets
        
        UIView.performWithoutAnimation {
            if didChangeInsets {
                var contentOffset = self.collectionView.contentOffset
                self.collectionView.contentInset = newInsets
                self.collectionView.setContentOffset(CGPoint(x: 0, y: (collectionView.contentSize.height - collectionView.bounds.size.height) + (collectionView.contentInset.bottom) + 300), animated: false)
            }
            self.collectionView.scrollIndicatorInsets = newInsets
        }


        // If we were scrolled away from the bottom, shift the content in lockstep with the
        // keyboard, up to the limits of the content bounds.
        let insetChange = newInsets.bottom - oldInsets.bottom

        // Only update the content offset if the inset has changed.
        if insetChange != 0 {
            // The content offset can go negative, up to the size of the top layout guide.
            // This accounts for the extended layout under the navigation bar.
            //let minYOffset = -view.safeAreaInsets.top
            
            print("oldYOffset", oldYOffset)
            print("insetChange", insetChange)
            print("oldYOffset", oldYOffset)
            print("safeContentHeight", safeContentHeight)
            
            //let newYOffset = (oldYOffset + insetChange).clamped(to: minYOffset...safeContentHeight)
            //let newOffset = CGPoint(x: 0, y: newYOffset)

            // This offset change will be animated by UIKit's UIView animation block
            // which updateContentInsets() is called within
            //collectionView.setContentOffset(newOffset, animated: false)
        }
        
        print("contentInset", collectionView.contentInset)
        print("contentOffset", collectionView.contentOffset)
        
    }

}
