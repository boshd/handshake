//
//  InteractiveModalTransitioningDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-04.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

final class InteractiveModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveDismiss = true
    init(from presented: UIViewController, to presenting: UIViewController) {
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return InteractiveModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
