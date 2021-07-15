//
//  KeyboardLayoutGuide.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-15.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

public class KeyboardLayoutGuide : UILayoutGuide {
    
    private var observer: KeyboardFrameObserver?

    public var topConstant: CGFloat?
    
    public override var owningView: UIView? {
        didSet {
            guard let view = owningView else {
                observer = nil
                return
            }
            
            let topConstraint = view.bottomAnchor.constraint(equalTo: topAnchor)
            topConstraint.priority = .defaultHigh
            
            let heightConstraint = heightAnchor.constraint(equalToConstant: 0)
          
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: view.leadingAnchor),
                trailingAnchor.constraint(equalTo: view.trailingAnchor),
                topConstraint,
                heightConstraint,
            ])
            
//            if #available(iOS 13.0, *) {
//                let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
//                if let bottom = window?.safeAreaInsets.bottom {
//                    topAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: bottom).isActive = true
//                }
//            } else
            if #available(iOS 11.0, *) {
                topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            } else {
                topAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
            }
            
            observer = KeyboardFrameObserver(view: view) { [weak view] keyboardFrame, animated in
                guard let view = view else { return }
            
                topConstraint.constant = view.bounds.height - keyboardFrame.origin.y
                self.topConstant = topConstraint.constant
                heightConstraint.constant = keyboardFrame.height
                
                if animated {
                    view.layoutIfNeeded()
                }
            }
        }
    }
}
