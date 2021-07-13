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

var tabBarController: TabBarController?
var globalIndicator = SVProgressHUD.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let pushManager = PushNotificationManager()
    let realm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        userDefaults.configureInitialLaunch()
        
        tabBarController = TabBarController()
        
        if #available(iOS 13, *), userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            tabBarController?.applyTheme()
        } else {
            ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = CustomNavigationController(rootViewController: tabBarController ?? UIViewController())
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        window?.backgroundColor = ThemeManager.currentTheme().windowBackground
        tabBarController?.presentOnboardingController()
        
        pushManager.registerForPushNotifications()
        
        if let options = launchOptions,
           let notification = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [NSObject : AnyObject] {
            // NOTE: (Kyle Begeman) May 19, 2016 - There is an issue with iOS instantiating the UIWindow object. Making this call without
            // a delay will cause window to be nil, thus preventing us from constructing the application and assigning it to the window.
            
            print("IN APP DELEGATE", notification)
//            Quark.runAfterDelay(seconds: 0.001, after: {
//                self.application(application, didReceiveRemoteNotification: notification)
//            })
        }
        
        print("LAUNCH OPTIONS", launchOptions)
        
        configureIndicator()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Auth.auth().canHandle(url)
    }
    
    // MARK: - Push Notifications
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        if Auth.auth().canHandleNotification(notification) {
//            completionHandler(.noData)
//            return
//        }
//        pushManager.handleNotification(notification: notification)
//    }
//
    
    // MARK: - Push notification registration
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: - Indicator
    
    func configureIndicator() {
        globalIndicator.setDefaultMaskType(.clear)
        globalIndicator.setMaximumDismissTimeInterval(1.0)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
          // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
          Database.database().purgeOutstandingWrites()
          autoreleasepool {
              try! RealmKeychain.defaultRealm.safeWrite {
                  for object in RealmKeychain.defaultRealm.objects(Message.self).filter("status == %@", messageStatusSending) {
                      object.status = messageStatusNotSent
                  }
              }
          }
    }

}
