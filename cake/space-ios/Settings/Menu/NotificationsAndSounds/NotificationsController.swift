//
//  NotificationsController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-22.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class NotificationsController: MenuControlsTableViewController {

    var notificationElements = [SwitchObject]()
    
    let buttonCellId = "buttonCellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        createDataSource()
        setupNavigationbar()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }

    fileprivate func createDataSource() {
        let inAppNotificationsState = userDefaults.currentBoolObjectState(for: userDefaults.inAppNotifications)
        let inAppSoundsState = userDefaults.currentBoolObjectState(for: userDefaults.inAppSounds)
        let inAppVibrationState = userDefaults.currentBoolObjectState(for: userDefaults.inAppVibration)
        let inAppNotifications = SwitchObject("Previews", subtitle: nil, state: inAppNotificationsState, defaultsKey: userDefaults.inAppNotifications)
        let inAppSounds = SwitchObject("Sounds", subtitle: nil, state: inAppSoundsState, defaultsKey: userDefaults.inAppSounds)
        let inAppVibration =  SwitchObject("Vibrate", subtitle: nil, state: inAppVibrationState, defaultsKey: userDefaults.inAppVibration)

        notificationElements.append(inAppNotifications)
        notificationElements.append(inAppSounds)
        notificationElements.append(inAppVibration)
        
        tableView.register(ButtonCell.self, forCellReuseIdentifier: buttonCellId)
    }
    
    fileprivate func setupNavigationbar() {
        navigationItem.title = "Notifications & Sounds"
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc fileprivate func popController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc fileprivate func reset() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        if let token = Messaging.messaging().fcmToken {
            userDefaults.updateObject(for: userDefaults.fcmToken, with: token)
            let fcmTokensCurrentUserReference = Firestore.firestore().collection("fcmTokens").document(currentUserID)
            let batch = Firestore.firestore().batch()
            batch.setData(["fcmToken":token], forDocument: fcmTokensCurrentUserReference, merge: true)
            batch.commit { (error) in
                globalIndicator.showSuccess(withStatus: "Token reset")
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    return
                }
                hapticFeedback(style: .success)
            }
        }
        
//        if let token = Messaging.messaging().fcmToken {
//            globalIndicator.show()
//            userDefaults.updateObject(for: userDefaults.fcmToken, with: token)
//            let currentUserReference = Firestore.firestore().collection("fcmTokens").document(currentUserID)
//            let batch = Firestore.firestore().batch()
//            batch.updateData(["fcmToken":token], forDocument: currentUserReference)
////            batch.setData([
////                "fcmToken": token,
////                "time": Date()
////            ], forDocument: currentUserReference.collection("fcmTokens").document(token))
//            batch.commit { (error) in
//                globalIndicator.showSuccess(withStatus: "Token reset")
//                if error != nil {
//                    print(error?.localizedDescription ?? "error")
//                    return
//                }
//                hapticFeedback(style: .success)
//
//                let channels = RealmKeychain.defaultRealm.objects(Channel.self)
//                for channel in channels {
//                    Messaging.messaging().subscribe(toTopic: channel.id ?? "")
//                }
//            }
//        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notificationElements.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 120
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellID, for: indexPath) as? SwitchTableViewCell ?? SwitchTableViewCell()
            cell.currentViewController = self
            cell.setupCell(object: notificationElements[indexPath.row], index: indexPath.row)
            cell.isUserInteractionEnabled = true
            cell.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: buttonCellId, for: indexPath) as? ButtonCell ?? ButtonCell()
            cell.resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
            return cell
        }
    }
}
