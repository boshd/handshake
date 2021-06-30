//
//  ViewController.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import SVProgressHUD
import RealmSwift
import SafariServices

class AccountSettingsController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var window: UIWindow?
    
    let userProfileContainerView = UserProfileContainerView()
    let settingsFooterContainerView = SettingsFooterContainerView()
    
    let ind = SVProgressHUD.self
    
    let accountSettingsCellId = "userProfileCell"
    
    let realm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())

    var accountSection = [( icon: UIImage(named: "Notification") , title: "Profile" ),
                        ( icon: UIImage(named: "ChangeNumber") , title: "Change number")]
    
    var preferencesSection = [( icon: UIImage(named: "ChangeNumber") , title: "Notifications"),
                             ( icon: UIImage(named: "Privacy") , title: "Appearance" )]
    
    var supportSection = [( icon: UIImage(named: "Logout") , title: "Terms of Use"),
                         ( icon: UIImage(named: "Logout") , title: "Privacy Policy"),
                         ( icon: UIImage(named: "Logout") , title: "Licences"),
                         ( icon: UIImage(named: "ChangeNumber") , title: "Feedback")]
    
    var logoutSection = [
                            ( icon: UIImage(named: "Logout") , title: "Permenantly delete account")
                        ]
    
    let dismissButton = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action: #selector(dismissController))
    
    var createButtonDelegate: CreateButtonDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        addObservers()
        setupNavigationbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isModalInPresentation = false
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        tableView.backgroundColor = view.backgroundColor
        navigationController?.navigationBar.barTintColor = ThemeManager.currentTheme().barTintColor
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        settingsFooterContainerView.setColor()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.backgroundColor = ThemeManager.currentTheme().windowBackground
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationBar)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func configureTableView() {
        tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 0
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: -25)
//        tableView.tableFooterView?.backgroundColor = .green
//        tableView.tableFooterView = settingsFooterContainerView
//        settingsFooterContainerView.backgroundColor = .red
//        settingsFooterContainerView.frame = tableView.tableFooterView!.bounds
//        tableView.tableFooterView?.isUserInteractionEnabled = true
        tableView.separatorColor = .lightGray
        tableView.register(AccountSettingsTableViewCell.self, forCellReuseIdentifier: accountSettingsCellId)
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.reloadData()
        settingsFooterContainerView.controller = self
//        settingsFooterContainerView.footerView.delegate = self
        
        ind.setDefaultMaskType(.clear)
    }
    
    fileprivate func setupNavigationbar() {
        navigationItem.title = "Account"
        
//        let dismissButton = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action: #selector(dismissController))
//        dismissButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
//        navigationItem.rightBarButtonItem = dismissButton
        if let navigationController = navigationController {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationController.navigationBar)
        }
    }
    
    @objc func dismissController() {
        hapticFeedback(style: .impact)
        dismiss(animated: true, completion: nil)
    }
    
    func openUrl(_ url: String) {
        var svc = SFSafariViewController(url: URL(string: url)!)

        if #available(iOS 11.0, *) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true
            svc = SFSafariViewController(url: URL(string: url)!, configuration: configuration)
        }

        svc.preferredControlTintColor = ThemeManager.currentTheme().tintColor
        svc.preferredBarTintColor = ThemeManager.currentTheme().generalBackgroundColor
        present(svc, animated: true, completion: nil)
    }
    
    func logoutButtonTapped () {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        hapticFeedback(style: .impact)
        let alert = CustomAlertController(title_: "Sign out?", message: "You can always access your content by signing back in",         preferredStyle: .alert)
        alert.addAction(CustomAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(CustomAlertAction(title: "Sign out", style: .destructive, handler: {
            print("signing out..")
            self.actualLogout()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func actualLogout() {
        let channels = RealmKeychain.defaultRealm.objects(Channel.self)
        let group = DispatchGroup()
        for channel in channels {
            group.enter()
            Messaging.messaging().unsubscribe(fromTopic: channel.id ?? "") { (error) in
                group.leave()
                if error != nil { print(error?.localizedDescription ?? ""); return }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearUserData"), object: nil)
        group.notify(queue: .main) {
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
                hapticFeedback(style: .success)
                
                let destination = WelcomeViewController()
                let navigationController = UINavigationController(rootViewController: destination)
                navigationController.modalTransitionStyle = .crossDissolve
                navigationController.modalPresentationStyle = .overFullScreen
                if #available(iOS 13.0, *) {
                    navigationController.isModalInPresentation = true
                }
                self.present(navigationController, animated: true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        
    }
    
    func deleteAccountPressed() {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        hapticFeedback(style: .impact)
        let alertController = CustomAlertController(title_: "Permenantly delete account", message: "\nAre you sure you want to delete your account? This action can't be undone. \n\nIf you wish to continue, you will recieve a verification code through SMS. Message and data rates may apply.", preferredStyle: .alert)
        let continueAction = CustomAlertAction(title: "Continue", style: .destructive) {
            guard Auth.auth().currentUser?.uid != nil, let phoneNumber = Auth.auth().currentUser?.phoneNumber else { globalIndicator.dismiss(); return }
            globalIndicator.show()
            // before calling the delete operation we need to re-authenticate b/c this is sensitive operation
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                globalIndicator.dismiss()
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                guard let verificationID = verificationID else { return }
                alertController.dismiss(animated: true) {
                    self.presentVerificationCodeAlertController(verificationID: verificationID)
                }
            }
            
        }
        let cancelAction = CustomAlertAction(title: "Cancel", style: .cancel) {  }
        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentVerificationCodeAlertController(verificationID: String) {
        let alertController = CustomAlertController(title_: "Permenantly delete account", message: "\nIf you wish to proceed, please enter the verification code you recieved and press 'Delete account'", preferredStyle: .alert)
        let confirmAction = CustomAlertAction(title: "Delete account", style: .destructive) {
            guard Auth.auth().currentUser?.uid != nil else { return }
            if let textField = alertController.textFields.first, let text = textField.text {
                let verificationCode = text
                self.actualDeleteAccountOperation(verificationID: verificationID, verificationCode: verificationCode)
            }
        }
        let cancelAction = CustomAlertAction(title: "Cancel", style: .cancel) {  }
        alertController.addTextfield { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "SMS code"
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func actualDeleteAccountOperation(verificationID: String, verificationCode: String) {
        globalIndicator.show()
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().currentUser?.reauthenticate(with: credentials, completion: { (_, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                globalIndicator.dismiss()
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Error deleting account. Please check if the provided verification code is correct.", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            Auth.auth().currentUser?.delete(completion: { [self] (error) in
                
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    displayErrorAlert(title: basicErrorTitleForAlert, message: "Error deleting account, please try again later.", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                    globalIndicator.showError(withStatus: "Deletion failed")
                    return
                }
                
                //self.dismiss(animated: true, completion: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearUserData"), object: nil)
                let destination = WelcomeViewController()
                
                let navigationController = UINavigationController(rootViewController: destination)
                navigationController.modalTransitionStyle = .crossDissolve
                navigationController.modalPresentationStyle = .overFullScreen
                if #available(iOS 13.0, *) {
                    navigationController.isModalInPresentation = true
                }
                
//                self.dismiss(animated: true, completion: nil)
                
                self.present(navigationController, animated: true, completion: {
                    globalIndicator.showSuccess(withStatus: "Deletion successful")
                })
                
            })
        })
    }
    
}

extension AccountSettingsController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: accountSettingsCellId,
                                                 for: indexPath) as? AccountSettingsTableViewCell ?? AccountSettingsTableViewCell()
        cell.accessoryType = .disclosureIndicator

        if indexPath.section == 0 {
            cell.icon.image = accountSection[indexPath.row].icon
            cell.title.text = accountSection[indexPath.row].title
        } else if indexPath.section == 1 {
            cell.icon.image = preferencesSection[indexPath.row].icon
            cell.title.text = preferencesSection[indexPath.row].title
        } else if indexPath.section == 2 {
            cell.icon.image = supportSection[indexPath.row].icon
            cell.title.text = supportSection[indexPath.row].title
        } else {
            cell.icon.image = logoutSection[indexPath.row].icon
            cell.title.text = logoutSection[indexPath.row].title
            cell.title.textColor = .defaultHotRed()
            cell.title.font = ThemeManager.currentTheme().secondaryFontBold(with: 14)
        }

//        cell.accessoryType = .none
        return cell
    }
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hapticFeedback(style: .impact)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let destination = ProfileController()
                destination.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destination, animated: true)
            } else {
                let destination = ChangePhoneNumberController()
                destination.hidesBottomBarWhenPushed = true
                navigationController?.isModalInPresentation = true
                navigationController?.pushViewController(destination, animated: true)
            }
        } else if indexPath.section == 1 {
            if  indexPath.row == 0 {
                let destination = NotificationsController()
                destination.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destination, animated: true)
            } else {
                let destination = AppearanceTableViewController()
                destination.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destination, animated: true)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
//                basicErrorAlert(errorMessage: "Coming soon.", controller: self)
                // fetch?
                openUrl("https://www.notion.so/e0cc5b02ebfa4071ac97a204c7db25eb")
            } else if indexPath.row == 1 {
                openUrl("https://www.notion.so/Your-privacy-matters-to-us-419248ff0f624d66ad9915e1b090fe1f")
            } else if  indexPath.row == 2 {
                basicErrorAlert(errorMessage: "Coming soon.", controller: self)
                openUrl("https://www.notion.so/Licences-575d5e806944479c9f97d685c18aab83")
            } else if indexPath.row == 3 {
                logoutButtonTapped()
//                if MFMailComposeViewController.canSendMail() {
//                    let mailComposerVC = MFMailComposeViewController()
//                    mailComposerVC.mailComposeDelegate = self
//                    mailComposerVC.setToRecipients(["me@kareemarab.com"])
//                    mailComposerVC.setSubject("Handshake feedback")
//                    mailComposerVC.setMessageBody("", isHTML: false)
//                    self.present(mailComposerVC, animated: true, completion: nil)
//                } else {
//                    displayErrorAlert(title: basicErrorTitleForAlert, message: "Your phone isn't configured to send emails. Send us an email at me@kareemarab.com", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
//                }
            } else {
//                openUrl("https://kareemarab.now.sh/spl-redirect")
            }
        } else {
            if indexPath.row == 0 {
//                deleteAccountPressed()
//                logoutButtonTapped()
            } else {
//                deleteAccountPressed()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
     
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Account"
        } else if section == 1 {
            return "Your Preferences"
        } else if section == 2 {
            return "About"
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 20
        } else if section == 0 {
            return 0
        } else {
            return 45
        }
    }
    
    override func tableView(_  tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 10)
        header.textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
//        let attributedString = NSMutableAttributedString(string: (header.textLabel?.text)!)
//        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(3), range: NSRange(location: 0, length: attributedString.length))
//        header.textLabel?.attributedText = attributedString
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 50
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            return SettingsFooterContainerView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 50))
        } else {
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
     }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return accountSection.count
        } else if section == 1 {
            return preferencesSection.count
        } else {
            return supportSection.count
        }
//        } else {
//            return logoutSection.count
//        }
    }
    
}

extension AccountSettingsController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        print("deetected?")
//        guard interaction != .preview else { return false }
//        guard ["http", "https"].contains(URL.scheme?.lowercased() ?? "")  else { return true }
//        var svc = SFSafariViewController(url: URL as URL)
//
//        if #available(iOS 11.0, *) {
//            let configuration = SFSafariViewController.Configuration()
//            configuration.entersReaderIfAvailable = true
//            svc = SFSafariViewController(url: URL as URL, configuration: configuration)
//        }
//
//        svc.preferredControlTintColor = ThemeManager.currentTheme().tintColor
//        svc.preferredBarTintColor = ThemeManager.currentTheme().generalBackgroundColor
//        present(svc, animated: true, completion: nil)
//        
        return false
    }
}
