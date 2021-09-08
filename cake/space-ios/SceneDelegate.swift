//
//  SceneDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-09-07.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var tabBarController: TabBarController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        let window = UIWindow(windowScene: windowScene)
////        window.rootViewController = UIViewController()
//        
//        print("IN HERE")
//        tabBarController = TabBarController()
//        
//        if #available(iOS 13, *), userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
//            tabBarController?.applyTheme()
//        } else {
//            ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
//        }
//        
////        window = UIWindow(frame: UIScreen.main.bounds)
////        if let tabBarController = tabBarController {
//        let navigationController = CustomNavigationController(rootViewController: tabBarController ?? UIViewController())
//        navigationController.navigationBar.isHidden = true
//        self.window = window
//        window.rootViewController = navigationController
//        window.makeKeyAndVisible()
//        window.backgroundColor = ThemeManager.currentTheme().windowBackground
//        
//        
////        window.makeKeyAndVisible()
//        
//        tabBarController?.presentOnboardingController()
//        }

        
//        let sceneCoordinator = SceneCoordinator(window: window)
//        let firebaseUtil = FirebaseUtil()
//        self.signInViewModel = SignInViewModel(sceneCoordinator: sceneCoordinator, firebaseUtil: firebaseUtil)
//        let signInScene = Scene.signIn(self.signInViewModel!)
//        sceneCoordinator.transition(to: signInScene, using: .root, animated: true)
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

//    func sceneWillResignActive(_ scene: UIScene) {
//
//        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive && $0 != scene }) {
//            UIApplication.shared.delegate?.applicationWillResignActive?(.shared)
//        }
//    }
//
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//
//        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
//            UIApplication.shared.delegate?.applicationDidEnterBackground?(.shared)
//        }
//    }
//
//
//    func sceneWillEnterForeground(_ scene: UIScene) {
//
//        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
//            UIApplication.shared.delegate?.applicationWillEnterForeground?(.shared)
//        }
//    }
//
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//
//        if !UIApplication.shared.connectedScenes.contains(where: { $0.activationState == .foregroundActive && $0 != scene }) {
//            UIApplication.shared.delegate?.applicationDidBecomeActive?(.shared)
//        }
//    }

}
