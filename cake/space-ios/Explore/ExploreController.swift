//
//  ExploreController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-04-30.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class ExploreController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        configureNavigationBar()
    }
    
    fileprivate func configureNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    
    
}
