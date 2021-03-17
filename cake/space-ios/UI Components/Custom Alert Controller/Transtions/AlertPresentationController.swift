//
//  AlertPresentationController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-07.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

final class AlertPresentationController: UIPresentationController {
    
    private let presentedYOffset: CGFloat = 150
    private var direction: CGFloat = 0
    private var state: ModalScaleState = .interaction
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }
        
        let view = UIView(frame: container.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        //view.addGestureRecognizer(
            // UITapGestureRecognizer(target: self, action: #selector(didTap(tap:)))
        //)
        
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    @objc
    func didTap(tap: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator else { return }
        
        dimmingView.alpha = 0
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            
            self.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let `self` = self else { return }
            
            self.dimmingView.alpha = 0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
}


