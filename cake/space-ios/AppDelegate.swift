//
//  AppDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-28.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseMessaging
import CoreData
import Photos
import RealmSwift
import SVProgressHUD

func setUserNotificationToken(token: String) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    Firestore.firestore().collection("users").document(uid).updateData([token: true])
}

var channelsController: ChannelsController?
var globalIndicator = SVProgressHUD.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let pushManager = PushNotificationManager()
    let realm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
//        func deleteAll() {
//            do {
//                try realm.safeWrite {
//                    realm.deleteAll()
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//
//        deleteAll()
        
        print("\nAPP DELEGATE realm channel count: \(RealmKeychain.defaultRealm.objects(Channel.self).count)\n")
        
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        userDefaults.configureInitialLaunch()
        
        //ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        
        channelsController = ChannelsController()
        
        if #available(iOS 13, *), userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            channelsController?.applyInitialTheme()
        } else {
            ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = CustomNavigationController(rootViewController: channelsController ?? UIViewController())
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        window?.backgroundColor = ThemeManager.currentTheme().windowBackground
        channelsController?.presentOnboardingController()
        
        // Push notifications setup
        pushManager.registerForPushNotifications()
        
        configureIndicator()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Auth.auth().canHandle(url)
    }
    
    // MARK: - Push Notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        pushManager.handleNotification(notification: notification)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func configureIndicator() {
        globalIndicator.setDefaultMaskType(.clear)
        globalIndicator.setMaximumDismissTimeInterval(1.0)
    }

}
