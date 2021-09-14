//
//  GeneralUpdatesController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-09-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class GeneralUpdatesController: UIViewController {
    
    let generalUpdatesContainerView = GeneralUpdatesContainerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(generalUpdatesContainerView)
        generalUpdatesContainerView.frame = view.bounds
        
        configureContainerView()
    }
    
    fileprivate func configureContainerView() {
        generalUpdatesContainerView.doneButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
    }
    
    @objc
    fileprivate func dismissController() {
        dismiss(animated: true, completion: nil)
    }
}
