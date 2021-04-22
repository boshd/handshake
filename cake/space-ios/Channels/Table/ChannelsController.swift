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

class ChannelsController: UITableViewController, UIGestureRecognizerDelegate {
    
//    private let imageView = UIImageView(image: UIImage(named: "GroupIcon"))
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .red
        return imageView
    }()
    
    /// WARNING: Change these constants according to your project's design
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = 12
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 32
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
    }
    
    var isSyncingUsers = false
    
    var isAppLoaded = false
    var shouldAnimate = true
    fileprivate var shouldReSyncUsers = false
    
    let channelCellId = "channelCellId"
    
    var contactsPermissionGranted = false
//    var channelsContainerView = ChannelsContainerView()
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
//        loadViews()
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
        navigationItem.largeTitleDisplayMode = .always
//        showActivityTitle(title: .updatingUsers)
        guard !isAppLoaded, Auth.auth().currentUser != nil else { return }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadUsers()
            self?.contactsFetcher.fetchContacts()
        }
    }

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
        initializeDataSource()
        initializeUsersDataSource()
        continiousUIUpdate()
        configureNavigationBar()
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
    
//    private func loadViews() {
//        self.view = channelsContainerView
//        view.frame = channelsContainerView.bounds
//    }
    
    func initializeUsersDataSource() {
        guard !isAppLoaded, Auth.auth().currentUser != nil else { return }
        users = realm.objects(User.self)
    }
    
    fileprivate func configureController() {
        // init variables
        channelsReference = Firestore.firestore().collection("channels")
        
        // tableview cell registration
        tableView.register(ChannelCell.self, forCellReuseIdentifier: channelCellId)
        
        // add targets
//        channelsContainerView.createButton.addTarget(self, action: #selector(presentCreateChannelController), for: .touchUpInside)
//        channelsContainerView.contactsButton.addTarget(self, action: #selector(presentContactsController), for: .touchUpInside)
        
        // delegates
        channelsFetcher.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        usersFetcher.delegate = self
        contactsFetcher.delegate = self
    }
    
    fileprivate func configureNavigationBar() {
        
//        navigationController?.navigationBar.prefersLargeTitles = true

        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
//        guard let navigationBar = self.navigationController?.navigationBar else { return }
//        navigationBar.addSubview(profileImageView)
//
//        NSLayoutConstraint.activate([
//            profileImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor,
//                                             constant: -Const.ImageRightMargin),
//            profileImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor,
//                                              constant: -Const.ImageBottomMarginForLargeState),
//            profileImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
//            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
//        ])
        

        
        let newChatBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentCreateChannelController))
        navigationItem.rightBarButtonItem = newChatBarButton
        
        navigationItem.title = "Events"

    }
    
    // MARK: - Observers
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(initializeDataSource), name: .authenticationSucceeded, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(initializeHeaderViewDataSource), name: .authenticationSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(call), name: .authenticationSucceeded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cleanUpController), name: NSNotification.Name(rawValue: "clearUserData"), object: nil)
//        NotificationCenter.default.addObserver(self, selector:#selector(setGreeting), name: .NSCalendarDayChanged, object:nil)
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
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        tableView.sectionIndexBackgroundColor = view.backgroundColor
        tableView.backgroundColor = view.backgroundColor
        tableView.isOpaque = true
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc fileprivate func initializeDataSource() {
        guard !isAppLoaded, let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        channelsFetcher.fetchChannels()
        checkConnectivity()
        
        currentUserReference = Firestore.firestore().collection("users").document(currentUserID)
        listenToCurrentUser()
        
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
        
        // date
        dateFormatter.dateFormat = "EEEE, MMMM d"
//        channelsContainerView.channelsHeaderView.subTitle.text = dateFormatter.string(from: Date()).uppercased()
        let dateLabel = UILabel()
        dateLabel.text = dateFormatter.string(from: Date()).uppercased()
        dateLabel.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
        dateLabel.textColor = .gray
        dateLabel.sizeToFit()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dateLabel)
    }
    
    private func listenToCurrentUser() {
        

//
//        if currentUserListenerReference == nil {
//            currentUserListenerReference = currentUserReference?.addSnapshotListener({ [weak self] (snapshot, error) in
//                if error != nil {
//                    print(error?.localizedDescription ?? "")
//                    return
//                }
//                print("reached???")
//                self?.profileImageView.image = UIImage(named: "300")
//
//                guard let data = snapshot?.data() else { return }
//                let updatedUser = User(dictionary: data as [String:AnyObject])
//                globalCurrentUser = updatedUser
//                 self?.currentUserDelegate?.currentUser(didUpdate: updatedUser)
//
//                userDefaults.updateObject(for: userDefaults.currentUserName, with: updatedUser.name)
//
//                if let url = updatedUser.userThumbnailImageUrl, url != "" {
//
//                    self?.profileImageView.sd_setImage(with: URL(string: url), completed: nil)
                    
//                    self?.channelsContainerView.channelsHeaderView.userImageButton.imageView?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "UserpicIcon"), options: [], completed: { (image, error, _, _) in
//                        if error != nil{
//                            print(error?.localizedDescription ?? "")
//                            return
//                        }
////                        self?.channelsContainerView.setImage(image, for: .normal)
//
//
//                    })
//                } else {
//                    self?.channelsContainerView.channelsHeaderView.userImageButton.setImage(UIImage(named: "UserpicIcon"), for: .normal)
//                }
//            })
//        }
    }
    
    // MARK: - Datasource changes
    
    func observeDataSourceChanges() {
        realmChannelsNotificationToken = theRealmChannels?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let unwrappedSelf = self else { return }
            switch changes {
            case .initial:
                UIView.performWithoutAnimation { unwrappedSelf.tableView.reloadData() }
                break
            case .update(_, let deletions, let insertions, let modifications):
                if unwrappedSelf.isAppLoaded {
                    print(deletions, insertions, modifications)
                    unwrappedSelf.tableView.beginUpdates()
                    unwrappedSelf.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                    unwrappedSelf.tableView.deleteRows(at: unwrappedSelf.indexPathsToUpdate(updates: deletions, section: 0), with: .automatic)
                    UIView.performWithoutAnimation { unwrappedSelf.tableView.reloadRows(at: unwrappedSelf.indexPathsToUpdate(updates: modifications, section: 0), with: .none) }
                    unwrappedSelf.tableView.endUpdates()
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
        theRealmChannels = theRealmChannels?.sorted(byKeyPath: "startTime", ascending: true)

        guard let realmChannels = realmChannels else { return }
        if !isAppLoaded {
            UIView.transition(with: tableView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil)
        } else {
            DispatchQueue.main.async { [weak self] in
                UIView.performWithoutAnimation {
                    self?.tableView.reloadData()
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
//            self?.tableView.reloadData()
//        }
    }

    fileprivate func stopContiniousUpdate() {
        updateUITimer?.cancel()
        updateUITimer = nil
    }
    
    func configureTabBarBadge() {
        guard let realmAllConversations = theRealmChannels else { return }
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
//        channelsContainerView.channelsHeaderView.showActivityView(with: title)
    }

    func hideActivityTitle(title: ActivityTitle) {
//        channelsContainerView.channelsHeaderView.hideActivityView(with: title)
    }
    
    fileprivate func indexPathsToUpdate(updates: [Int], section: Int) -> [IndexPath] {
        return updates.compactMap({ [unowned self] (index) -> IndexPath? in
            if self.tableView.hasRow(at: IndexPath(row: index, section: section)) {
                return IndexPath(row: index, section: section)
            } else {
                return nil
            }
        })
    }
    
}

extension ChannelsController: WelcomeControllerDelegate {
    func onboardingFinished() {}
}

extension ChannelsController {
    private func moveAndResizeImage(for height: CGFloat) {
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0

        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)

        profileImageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let height = navigationController?.navigationBar.frame.height else { return }
//        moveAndResizeImage(for: height)
    }
}
