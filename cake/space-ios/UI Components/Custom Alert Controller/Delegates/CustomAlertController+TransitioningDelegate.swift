//
//  CustomAlertController+TransitioningDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-07.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension CustomAlertController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        switch preferredStyle {
            case .actionSheet:
                return InteractiveModalPresentationController(presentedViewController: presented, presenting: presenting)
            case .alert:
                return AlertPresentationController(presentedViewController: presented, presenting: presenting)
            case .none:
                return InteractiveModalPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
}

