//
//  ChannelLogController+Keyboard.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelLogController: InputContainerViewDelegate {
    func inputContainerViewKeyboardIsPresenting(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve) {
        handleKeyboardStateChange(animationDuration: animationDuration,
                                  animationCurve: animationCurve)
    }
    
    func inputContainerViewKeyboardDidPresent() {
        updateContentInsets(animated: false)
    }
    
    func inputContainerViewKeyboardIsDismissing(animationDuration: TimeInterval, animationCurve: UIView.AnimationCurve) {
        handleKeyboardStateChange(animationDuration: animationDuration,
                                  animationCurve: animationCurve)
    }
    
    func inputContainerViewKeyboardDidDismiss() {
        updateContentInsets(animated: false)
    }
    
    func inputContainerViewKeyboardIsDismissingInteractively() {
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
            print("99999999")
            // from start, before shouldAnimateKeyboardChanges is set
            updateContentInsets(animated: false)
        }
        
    }
    
    @objc(updateContentInsetsAnimated:)
    public func updateContentInsets(animated: Bool) {
        
//        guard !isMeasuringKeyboardHeight else {
//            return
//        }

        // Don't update the content insets if an interactive pop is in progress
        guard let navigationController = self.navigationController else {
            return
        }
        if let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer {
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

        let keyboardOverlap = inputContainerView.keyboardOverlap
        newInsets.bottom = (keyboardOverlap + inputContainerView.frame.height - view.safeAreaInsets.bottom)
        // TODO:
        // newInsets.top = messageActionsExtraContentInsetPadding + (bannerView?.height ?? 0)

         let wasScrolledToBottom = self.isScrollViewAtTheBottom()

        // Changing the contentInset can change the contentOffset, so make sure we
        // stash the current value before making any changes.
        let oldYOffset = collectionView.contentOffset.y

        let didChangeInsets = oldInsets != newInsets

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
//        } else if wasScrolledToBottom {
            // If we were scrolled to the bottom, don't do any fancy math. Just stay at the bottom.
//            collectionView.scrollToBottom(animated: false)
        } else if hasAppearedAndHasAppliedFirstLoad {
            // If we were scrolled away from the bottom, shift the content in lockstep with the
            // keyboard, up to the limits of the content bounds.
            let insetChange = newInsets.bottom - oldInsets.bottom
            print("IN HERE ", insetChange)
            // Only update the content offset if the inset has changed.
            if insetChange != 0 {
                // The content offset can go negative, up to the size of the top layout guide.
                // This accounts for the extended layout under the navigation bar.
                let minYOffset = -view.safeAreaInsets.top
                let newYOffset = (oldYOffset + insetChange).clamped(to: .zero...safeContentHeight)
                let newOffset = CGPoint(x: 0, y: newYOffset)

                // This offset change will be animated by UIKit's UIView animation block
                // which updateContentInsets() is called within
                collectionView.setContentOffset(newOffset, animated: false)
                
                print(collectionView.contentInset)
                print(collectionView.contentOffset)
            }
        }
    }
    
    @objc
    public func updateContentInsets_(animated: Bool) {
        
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
