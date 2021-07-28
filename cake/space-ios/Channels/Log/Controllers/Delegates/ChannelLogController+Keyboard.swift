//
//  ChannelLogController+Keyboard.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelLogController: InputAccessoryViewPlaceholderDelegate {
    
    func inputAccessoryPlaceholderKeyboardDidChangeFrame(beginFrame: CGRect, endFrame: CGRect, animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve) {
        print("beginFrame", beginFrame)
        print("endFrame", endFrame)
//        channelLogContainerView.headerTopConstraint?.constant = endFrame.height
        handleKeyboardStateChange(animationDuration: animationDuration,
                                  animationCurve: animationCurve)
    }

    func inputAccessoryPlaceholderKeyboardIsPresenting(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve, beginFrame: CGRect, endFrame: CGRect) {
        print("isPresenting")
        //handleKeyboardStateChange(animationDuration: animationDuration, animationCurve: animationCurve)
        
        adjustContentForKeyboard(animationDuration: animationDuration, animationCurve: animationCurve, beginFrame: beginFrame, endFrame: endFrame, shown: true)
    }
    
    func inputAccessoryPlaceholderKeyboardDidPresent() {
        print("didPresent")
        animateHeaderView(shouldCollapse: true)
//        updateContentInsets(animated: false)
    }
    
    func inputAccessoryPlaceholderKeyboardIsDismissing(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve, beginFrame: CGRect, endFrame: CGRect) {
        //handleKeyboardStateChange(animationDuration: animationDuration, animationCurve: animationCurve)
        
        adjustContentForKeyboard(animationDuration: animationDuration, animationCurve: animationCurve, beginFrame: beginFrame, endFrame: endFrame, shown: false)
    }
    
    func inputAccessoryPlaceholderKeyboardDidDismiss() {
        animateHeaderView(shouldCollapse: false)
//        updateContentInsets(animated: false)
    }
    
    func inputAccessoryPlaceholderKeyboardIsDismissingInteractively() {}
    
    
    func adjustContentForKeyboard(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve, beginFrame: CGRect, endFrame: CGRect, shown: Bool) {
//       guard shouldAdjustForKeyboard else { return }
    
       let keyboardHeight = shown ? endFrame.size.height : inputAccessoryPlaceholder.bounds.size.height
       if collectionView.contentInset.bottom == keyboardHeight {
           return
       }
    
       let distanceFromBottom = bottomOffset().y - collectionView.contentOffset.y
    
       var insets = collectionView.contentInset
       insets.bottom = keyboardHeight
    
       UIView.animate(withDuration: animationDuration, animations: {
    
           self.collectionView.contentInset = insets
           self.collectionView.scrollIndicatorInsets = insets
    
           if distanceFromBottom < 10 {
               self.collectionView.contentOffset = self.bottomOffset()
           }
       }, completion: nil)
   }
    
    func animateHeaderView(shouldCollapse: Bool) {
        if shouldCollapse {
            channelLogContainerView.headerTopConstraint?.constant = -75
//            channelLogContainerView.headerHeightConstraint?.constant = 0
        } else {
            if channelLogContainerView.headerTopConstraint?.constant == -75 {
                channelLogContainerView.headerTopConstraint?.constant = 10
            }
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
//        UIView.animate(withDuration: animationDuration) { [weak self] in
//            self?.view.layoutIfNeeded()
//        }
        
    }
    
    private func handleKeyboardStateChange(animationDuration: TimeInterval,
                                           animationCurve: UIView.AnimationCurve) {
        
        if let transitionCoordinator = self.transitionCoordinator,
           transitionCoordinator.isInteractive {
            return
        }
        
        if shouldAnimateKeyboardChanges, animationDuration > 0 {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.updateContentInsets(animated: true)
            }
        } else {
            // from start, before shouldAnimateKeyboardChanges is set
            updateContentInsets(animated: false)
        }
        
    }
    
    @objc(updateContentInsetsAnimated:)
    public func updateContentInsets(animated: Bool) {

        // Don't update the content insets if an interactive pop is in progress
        guard let navigationController = self.navigationController else {
            return
        }
        if let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer {
            print("interactivePopGestureRecognizer.state", interactivePopGestureRecognizer.state.rawValue)
            switch interactivePopGestureRecognizer.state {
            case .possible, .failed:
                break
            default:
                return
            }
        }

        view.layoutIfNeeded()

        let oldInsets = collectionView.contentInset
        var newInsets = oldInsets

        let keyboardOverlap = inputAccessoryPlaceholder.keyboardOverlap
        newInsets.bottom = (keyboardOverlap)
        // TODO:
//         newInsets.top = messageActionsExtraContentInsetPadding + (bannerView?.height ?? 0)

         let wasScrolledToBottom = self.isScrollViewAtTheBottom()

        // Changing the contentInset can change the contentOffset, so make sure we
        // stash the current value before making any changes.
        let oldYOffset = collectionView.contentOffset.y

        let didChangeInsets = oldInsets != newInsets
        print("didChangeInsets", didChangeInsets)
        UIView.performWithoutAnimation {
            if didChangeInsets {
                let contentOffset = self.collectionView.contentOffset
                self.collectionView.contentInset = newInsets
                self.collectionView.setContentOffset(contentOffset, animated: false)
            }
            self.collectionView.scrollIndicatorInsets = newInsets
        }

        // Adjust content offset to prevent the presented keyboard from obscuring content.
        if !didChangeInsets {
            // Do nothing.
            //
            // If content inset didn't change, no need to update content offset.
        } else if !hasAppearedAndHasAppliedFirstLoad {
            // Do nothing.
        } else if wasScrolledToBottom {
             // If we were scrolled to the bottom, don't do any fancy math. Just stay at the bottom.
            scrollToBottom(animated: false)
        } else {
            // If we were scrolled away from the bottom, shift the content in lockstep with the
            // keyboard, up to the limits of the content bounds.
            let insetChange = Double(newInsets.bottom).rounded(toPlaces: 5) - Double(oldInsets.bottom).rounded(toPlaces: 5)
            print("newInsets.bottom", newInsets.bottom)
            print("oldInsets.bottom", oldInsets.bottom)
            
            // Only update the content offset if the inset has changed.
            if insetChange != 0 {
                // The content offset can go negative, up to the size of the top layout guide.
                // This accounts for the extended layout under the navigation bar.
                print("insetChange", insetChange)
                print("oldYOffset", oldYOffset)
                let minYOffset = -view.safeAreaInsets.top
                let newYOffset = (oldYOffset + CGFloat(insetChange)).clamped(to: minYOffset...safeContentHeight)
                let newOffset = CGPoint(x: 0, y: newYOffset)

                // This offset change will be animated by UIKit's UIView animation block
                // which updateContentInsets() is called within
                collectionView.setContentOffset(newOffset, animated: false)
                print("new offset", newYOffset)
                print(collectionView.contentInset)
                print(collectionView.contentOffset)
            }
        }
    }

}
