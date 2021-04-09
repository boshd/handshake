//
//  ChannelsController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-26.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import SDWebImage  
import Contacts
//import SwiftConfettiView

enum ActivityTitle: String {
    case noInternet = "Waiting for network"
    case updating = "Updating..."
    case connecting = "Connecting..."
    case updatingUsers = "Syncing users..."
}

var globalCurrentUser: User? {
    didSet {
        NotificationCenter.default.post(name: .currentUserDidChange, object: nil)
    }
}

protocol CurrentUserDelegate: class {
    func currentUser(didUpdate user: User)
}

class ChannelsController: UIViewController, UIGestureRecognizerDelegate {
    
    var isSyncingUsers = false
    
    var isAppLoaded = false
    var shouldAnimate = true
    fileprivate var shouldReSyncUsers = false
    
    let channelCellId = "channelCellId"
    
    var contactsPermissionGranted = false
    var channelsContainerView = ChannelsContainerView()
    let channelsFetcher = ChannelsFetcher()
    let viewPlaceholder = ViewPlaceholder()
    let notificationsManager = InAppNotificationManager()
    let realmManager = ChannelsRealmManager()
    let dateFormatter = DateFormatter()
    let usersFetcher = UsersFetcher()
    let contactsFetcher = ContactsFetcher()
    let informationMessageSender = InformationMessageSender()
    
    var channelsReference: CollectionReference?
    var currentChannelReference: DocumentReference?
    var currentUserListenerReference: ListenerRegistration?
    var currentUserReference: DocumentReference?
    
    var upcomingChannelsNotificationToken: NotificationToken?
    var pastChannelsNotificationToken: NotificationToken?
    var inProgressChannelsNotificationToken: NotificationToken?
    
    var realmChannelsNotificationToken: NotificationToken?

    var realmChannels: Results<Channel>?
    
    var theRealmChannels: Results<Channel>?
    var pastRealmChannels: Results<Channel>?
    var upcomingRealmChannels: Results<Channel>?
    var inProgressRealmChannels: Results<Channel>?
    var users: Results<User>?
    
    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    
    weak var currentUserDelegate: CurrentUserDelegate?
    
    let realm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    
    fileprivate var updateUITimer: DispatchSourceTimer?
    
    // MARK: - Controller life-cycle
    
    override func loadView() {
        super.loadView()
        loadViews()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if currentUserListenerReference != nil {
            currentUserListenerReference = nil
        }
    }
    
    var initialViewDidLoadAttemptSuccessful = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addContactsObserver()
        addObservers()
        configureController()
//        showActivityTitle(title: .updatingUsers)
        guard !isAppLoaded, Auth.auth().currentUser != nil else { return }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadUsers()
            self?.contactsFetcher.fetchContacts()
        }
    }
    
//    func outputImage(name:String,image:UIImage){
//        let fileManager = FileManager.default
//        let data = image.pngData()
//        fileManager.createFile(atPath: "/Users/kareemarab/Desktop/\(name).png", contents: data, attributes: nil)
//    }
    
    @objc
    func call() {
        guard !isAppLoaded, Auth.auth().currentUser != nil else { return }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadUsers()
            self?.contactsFetcher.fetchContacts()
        }
    }
    
    func applyInitialTheme() {
        if traitCollection.userInterfaceStyle == .light {
            ThemeManager.applyTheme(theme: .normal)
        } else {
            ThemeManager.applyTheme(theme: .dark)
        }
        changeTheme()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        initializeDataSource()
        initializeHeaderViewDataSource()
        initializeUsersDataSource()
        continiousUIUpdate()
//        setNeedsStatusBarAppearanceUpdate()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        print("recieved memory warning from ChannelsController")
    }
    
    // MARK: - Controller setup, configuration & clean up
    
    private func loadViews() {
        self.view = channelsContainerView
        view.frame = channelsContainerView.bounds
    }
    
    func initializeUsersDataSource() {
        guard !isAppLoaded, Auth.auth().currentUser != nil else { return }
        users = realm.objects(User.self)
    }
    
    fileprivate func configureController() {
        // init variables
        channelsReference = Firestore.firestore().collection("channels")
        
        // tableview cell registration
        channelsContainerView.tableView.register(ChannelCell.self, forCellReuseIdentifier: channelCellId)
//        channelsContainerView.tableView.tableFooterView = UIView()
        
        // add targets
        channelsContainerView.channelsHeaderView.userImageButton.addTarget(self, action: #selector(presentSettings), for: .touchUpInside)
        channelsContainerView.createButton.addTarget(self, action: #selector(presentCreateChannelController), for: .touchUpInside)
        channelsContainerView.contactsButton.addTarget(self, action: #selector(presentContactsController), for: .touchUpInside)
        
        // delegates
        channelsFetcher.delegate = self
        channelsContainerView.tableView.delegate = self
        channelsContainerView.tableView.dataSource = self
        usersFetcher.delegate = self
        contactsFetcher.delegate = self
    }
    
    fileprivate func configureNavigationBar() {
//        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationBar.barStyle = ThemeManager.currentTheme().barStyle
    }
    
    // MARK: - Observers
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(initializeDataSource), name: .authenticationSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initializeHeaderViewDataSource), name: .authenticationSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(call), name: .authenticationSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cleanUpController), name: NSNotification.Name(rawValue: "clearUserData"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(setGreeting), name: .NSCalendarDayChanged, object:nil)
    }
    
    func addContactsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(contactStoreDidChange), name: .CNContactStoreDidChange, object: nil)
    }
    
    func removeContactsObserver() {
        NotificationCenter.default.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
    }
    
    // MARK: - @objc methods
    
    @objc fileprivate func cleanUpController() {
        notificationsManager.removeAllObservers()
        channelsFetcher.removeAllObservers()
        realmManager.deleteAll()
        isAppLoaded = false
        
        globalCurrentUser = nil
        if currentUserListenerReference != nil {
            currentUserListenerReference =  nil
            currentUserListenerReference?.remove()
        }
        
        func deleteAll() {
            do {
                try realm.safeWrite {
                    realm.deleteAll()
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        deleteAll()
        shouldReSyncUsers = true
        userDefaults.removeObject(for: userDefaults.contactsCount)
        userDefaults.removeObject(for: userDefaults.contactsSyncronizationStatus)
//        userDefaults.removeObject(for: userDefaults.useSystemTheme)
//        userDefaults.removeObject(for: userDefaults.selectedTheme)
    }
    
    @objc func contactStoreDidChange(notification: NSNotification) {
        guard Auth.auth().currentUser != nil else { return }
        removeContactsObserver()
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadUsers()
            self?.contactsFetcher.fetchContacts()
        }
    }
    
    func forceSync() {
        if !isSyncingUsers {
            
//            guard shouldReSyncUsers else { return }
            print("in here cuz syncing")
            shouldReSyncUsers = false
            usersFetcher.loadUsers()
            contactsFetcher.forcedSync = true
            contactsFetcher.syncronizeContacts(contacts: contacts)
        }
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return ThemeManager.currentTheme().statusBarStyle
//    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        channelsContainerView.tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        channelsContainerView.tableView.sectionIndexBackgroundColor = view.backgroundColor
        channelsContainerView.tableView.backgroundColor = view.backgroundColor
        channelsContainerView.tableView.isOpaque = true
        channelsContainerView.channelsHeaderView.title.textColor = ThemeManager.currentTheme().generalTitleColor
        channelsContainerView.channelsHeaderView.subTitle.textColor = ThemeManager.currentTheme().generalSubtitleColor
        channelsContainerView.channelsHeaderView.seperator.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        channelsContainerView.contactsButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        channelsContainerView.createButton.backgroundColor = ThemeManager.currentTheme().buttonColor
        channelsContainerView.contactsButton.tintColor = ThemeManager.currentTheme().buttonIconColor
        channelsContainerView.createButton.tintColor = ThemeManager.currentTheme().buttonIconColor
        DispatchQueue.main.async { [weak self] in
            self?.channelsContainerView.tableView.reloadData()
        }
    }
    
    @objc fileprivate func initializeHeaderViewDataSource() {
        dateFormatter.dateFormat = "EEEE, MMMM d"
        setGreeting()
        channelsContainerView.channelsHeaderView.subTitle.text = dateFormatter.string(from: Date()).uppercased()
        guard !isAppLoaded, Auth.auth().currentUser != nil else { return }
        if currentUserListenerReference == nil {
            currentUserListenerReference = currentUserReference?.addSnapshotListener({ [weak self] (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                guard let data = snapshot?.data() else { return }
                let updatedUser = User(dictionary: data as [String:AnyObject])
                globalCurrentUser = updatedUser
                 self?.currentUserDelegate?.currentUser(didUpdate: updatedUser)
                
                userDefaults.updateObject(for: userDefaults.currentUserName, with: updatedUser.name)
                
                if let url = updatedUser.userThumbnailImageUrl, url != "" {
                    self?.channelsContainerView.channelsHeaderView.userImageButton.imageView?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "UserpicIcon"), options: [], completed: { (image, error, _, _) in
                        if error != nil{
                            print(error?.localizedDescription ?? "")
                            return
                        }
                        self?.channelsContainerView.channelsHeaderView.userImageButton.setImage(image, for: .normal)
                    })
                } else {
                    
                    self?.channelsContainerView.channelsHeaderView.userImageButton.setImage(UIImage(named: "UserpicIcon"), for: .normal)
                }
            })
        }
    }
    
    @objc fileprivate  func setGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        DispatchQueue.main.async {
            switch hour {
            case 6..<12: self.channelsContainerView.channelsHeaderView.title.text = "Good morning"
            case 12..<17: self.channelsContainerView.channelsHeaderView.title.text = "Good afternoon"
            default: self.channelsContainerView.channelsHeaderView.title.text = "Good evening"
            }
        }
    }
    
    @objc fileprivate func initializeDataSource() {
        guard !isAppLoaded, let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        channelsFetcher.fetchChannels()
        checkConnectivity()
        
        currentUserReference = Firestore.firestore().collection("users").document(currentUserID)
        
        let currentDateInt64 = Int64(Int(Date().timeIntervalSince1970))
        
        let objects = RealmKeychain.defaultRealm.objects(Channel.self).sorted(byKeyPath: "startTime", ascending: false)
        let pastObjects = objects.filter("startTime < \(currentDateInt64) && endTime < \(currentDateInt64)").sorted(byKeyPath: "startTime", ascending: false)
        let upcomingObjects = objects.filter("startTime > \(currentDateInt64) && endTime > \(currentDateInt64)").sorted(byKeyPath: "startTime", ascending: false)
        let inProgressObjects = objects.filter("startTime < \(currentDateInt64) && endTime > \(currentDateInt64)").sorted(byKeyPath: "startTime", ascending: false)
        let theObjects = objects.sorted(byKeyPath: "startTime", ascending: false)
        // filter past objects newer than 24 hrs ago
        
        pastRealmChannels = pastObjects
        upcomingRealmChannels = upcomingObjects
        inProgressRealmChannels = inProgressObjects
        realmChannels = objects
        theRealmChannels = theObjects
    }
    
    // MARK: - Datasource changes
    
    func observeDataSourceChanges() {
        realmChannelsNotificationToken = theRealmChannels?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let unwrappedSelf = self else { return }
            switch changes {
            case .initial:
                UIView.performWithoutAnimation { unwrappedSelf.channelsContainerView.tableView.reloadData() }
                break
            case .update(_, let deletions, let insertions, let modifications):
                if unwrappedSelf.isAppLoaded {
                    print(deletions, insertions, modifications)
                    unwrappedSelf.channelsContainerView.tableView.beginUpdates()
                    unwrappedSelf.channelsContainerView.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                    unwrappedSelf.channelsContainerView.tableView.deleteRows(at: unwrappedSelf.indexPathsToUpdate(updates: deletions, section: 0), with: .automatic)
                    UIView.performWithoutAnimation { unwrappedSelf.channelsContainerView.tableView.reloadRows(at: unwrappedSelf.indexPathsToUpdate(updates: modifications, section: 0), with: .none) }
                    unwrappedSelf.channelsContainerView.tableView.endUpdates()
                }
                break
            case .error(let err): fatalError("\(err)"); break
            }
        }
    }
    
    // MARK: - User experience
    
    @objc func handleReloadTable() {
//        inProgressRealmChannels = inProgressRealmChannels?.sorted(byKeyPath: "startTime", ascending: false)
//        upcomingRealmChannels = upcomingRealmChannels?.sorted(byKeyPath: "startTime", ascending: false)
//        pastRealmChannels = pastRealmChannels?.sorted(byKeyPath: "startTime", ascending: false)
        theRealmChannels = theRealmChannels?.sorted(byKeyPath: "startTime", ascending: false)

        guard let realmChannels = realmChannels else { return }
        if !isAppLoaded {
            UIView.transition(with: channelsContainerView.tableView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                self.channelsContainerView.tableView.reloadData()
            }, completion: nil)
        } else {
            DispatchQueue.main.async { [weak self] in
                UIView.performWithoutAnimation {
                    self?.channelsContainerView.tableView.reloadData()
                }
            }
        }
        
        if realmChannels.count == 0 {
            checkIfThereAnyActiveChats(isEmpty: true)
        } else {
            checkIfThereAnyActiveChats(isEmpty: false)
        }
        
        configureTabBarBadge()
        
        guard !isAppLoaded else { return }
        isAppLoaded = true
    }
    
    func checkIfThereAnyActiveChats(isEmpty: Bool) {
        guard isEmpty else {
            viewPlaceholder.remove(from: view, priority: .high)
            return
        }
        viewPlaceholder.add(for: view, title: .noChannels, subtitle: .noChannels, priority: .high, position: .center)
    }
    
    fileprivate func continiousUIUpdate() {
        guard let theRealmChannels = theRealmChannels, theRealmChannels.count > 0 else { return }
        updateUITimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        updateUITimer?.schedule(deadline: .now(), repeating: .seconds(15))
        updateUITimer?.setEventHandler { [weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.performUIUpdate()
        }
        updateUITimer?.resume()
    }

    fileprivate func performUIUpdate() {
//        print("update here")
//        DispatchQueue.main.async { [weak self] in
//            self?.setGreeting()
//            self?.channelsContainerView.tableView.reloadData()
//        }
    }

    fileprivate func stopContiniousUpdate() {
        updateUITimer?.cancel()
        updateUITimer = nil
    }
    
    func configureTabBarBadge() {
        guard let realmAllConversations = realmChannels else { return }
        let badge = realmAllConversations.compactMap({ (conversation) -> Int in
            return conversation.badge.value ?? 0
        }).reduce(0, +)
        guard badge > 0 else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            return
        }
        UIApplication.shared.applicationIconBadgeNumber = badge
    }
    
    // MARK: - Navigation methods
    
    func presentOnboardingController() {
        guard Auth.auth().currentUser == nil else {
            return
        }
        let destination = WelcomeViewController()
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .overFullScreen
        present(newNavigationController, animated: false, completion: nil)
    }
    
    @objc func presentSettings() {
        guard Auth.auth().currentUser != nil else { return }
        hapticFeedback(style: .selectionChanged)
        print(userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme))
        let destination = AccountSettingsController()
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .formSheet
        present(newNavigationController, animated: true, completion: nil)
    }
    
    @objc func presentCreateChannelController() {
        guard Auth.auth().currentUser != nil else { return }
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        } else {
            hapticFeedback(style: .selectionChanged)
        }

        let destination = SelectChannelParticipantsController()
        // remove blocked users
        let users = RealmKeychain.realmUsersArray()
        destination.users = users
        destination.filteredUsers = users
        destination.setUpCollation()

        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .formSheet
        newNavigationController.navigationBar.isHidden = false
        present(newNavigationController, animated: true, completion: nil)
    }
    
    private var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate!
    
    @objc func presentContactsController() {
        guard Auth.auth().currentUser != nil else { return }
        hapticFeedback(style: .selectionChanged)
        let destination = ContactsController()
        destination.contacts = self.contacts
        destination.filteredContacts = self.filteredContacts
        destination.users = self.users
        destination.usersFetcher = usersFetcher
        destination.permissionGranted = contactsPermissionGranted
        destination.presentingController = self
        // usersFetcher.loadUsers()
        
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .formSheet
        present(newNavigationController, animated: true, completion: nil)
    }

    
    // MARK: - Misc.
    
    fileprivate func checkConnectivity() {
        if currentReachabilityStatus == .notReachable {
            showActivityTitle(title: .connecting)
        }
    }
    
    func showActivityTitle(title: ActivityTitle) {
        channelsContainerView.channelsHeaderView.showActivityView(with: title)
    }

    func hideActivityTitle(title: ActivityTitle) {
        channelsContainerView.channelsHeaderView.hideActivityView(with: title)
    }
    
    fileprivate func indexPathsToUpdate(updates: [Int], section: Int) -> [IndexPath] {
        return updates.compactMap({ [unowned self] (index) -> IndexPath? in
            if self.channelsContainerView.tableView.hasRow(at: IndexPath(row: index, section: section)) {
                return IndexPath(row: index, section: section)
            } else {
                return nil
            }
        })
    }
    
}

extension ChannelsController: WelcomeControllerDelegate {
    func onboardingFinished() {
//        initializeUsersDataSource()
//
//        guard shouldReSyncUsers, isAppLoaded, Auth.auth().currentUser != nil else { return }
//        shouldReSyncUsers = false
//        usersFetcher.loadUsers()
//        contactsFetcher.syncronizeContacts(contacts: contacts)
    }
}
