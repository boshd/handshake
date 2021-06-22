//
//  WelcomeViewController
//  space-ios
//
//  Created by Kareem Arab on 2019-05-28.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

protocol WelcomeControllerDelegate: class {
    func onboardingFinished()
}

class WelcomeViewController: UIViewController {
    
    let welcomeContainerView = WelcomeContainerView()
    
    var delegate: WelcomeControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.addSubview(welcomeContainerView)
        welcomeContainerView.frame = view.bounds
        addObservers()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func toSignup() {
        let destination = PhoneController()
        navigationController?.pushViewController(destination, animated: true)
        hapticFeedback(style: .selectionChanged)
    }
    
    // responsible for changing theme based on system theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme))
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) &&
            userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            if traitCollection.userInterfaceStyle == .light {
                ThemeManager.applyTheme(theme: .normal)
            } else {
                ThemeManager.applyTheme(theme: .dark)
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        welcomeContainerView.setColors()
    }

}

extension WelcomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // By following the parent ViewController delegate methods,
        // you can reload the tableview, pass values and so on.
//        self.delegate?.editViewControllerDidFinish(self)
        self.delegate?.onboardingFinished()
    }
}
