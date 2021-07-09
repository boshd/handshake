//
//  ChannelDetailsController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class ChannelDetailsController: UIViewController, UIGestureRecognizerDelegate {
    
    var channel: Channel?
    var channelImage: UIImage?
    
    var attendees = [User]()
    
    let channelDetailsContainerView = ChannelDetailsContainerView()
    var channelImageView: UIImageView?
    
    var channelListener: ListenerRegistration?
    var channelPartiticapntsListener: ListenerRegistration?
    
    let accountSettingsCellId = "accountSettingsCellId"
    let channelNameCellId = "channelNameCellId"
    let locationViewCellId = "locationViewCellId"
    let userCellId = "userCellId"
    let channelDescriptionCellId = "channelDescriptionCellId"
    let channelDetailsCellId = "channelDetailsCellId"
    let loadMoreCellId = "loadMoreCellId"
    
    let tableSectionHeaderHeight: CGFloat = 27.5
    
    let initialNumberOfAttendees = 1
    let showMoreUsers = false
    
    var allAttendeesLoaded = false
    var initialAttendeesLoaded = false
    
    let fullDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let avatarOpener = AvatarOpener()
    let channelDetailsDataDatabaseUpdater = ChannelDetailsDataDatabaseUpdater()
    
    var expandedCells = Set<Int>()
    
    let nonLocalRealm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
    let localRealm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        view = channelDetailsContainerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNaviationBar()
        observeChannel()
        observeChannelAttendeesChanges()
//        fetchChannelAttendees()
        test2(usersToLoad: 10)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Config/setup
    
    fileprivate func configureNaviationBar() {
        navigationItem.title = "Event details"
        
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action:  #selector(popController))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let moreButton = UIBarButtonItem(image: UIImage(named: "More Square"), style: .plain, target: self, action:  #selector(presentOptions))
        navigationItem.rightBarButtonItem = moreButton
    }

    fileprivate func configureTableView() {
        avatarOpener.delegate = self
        
        channelDetailsContainerView.tableView.delegate = self
        channelDetailsContainerView.tableView.dataSource = self
        channelDetailsContainerView.tableView.tableHeaderView?.isUserInteractionEnabled = true
        channelDetailsContainerView.tableView.register(AccountSettingsTableViewCell.self, forCellReuseIdentifier: accountSettingsCellId)
        channelDetailsContainerView.tableView.register(ChannelNameCell.self, forCellReuseIdentifier: channelNameCellId)
        channelDetailsContainerView.tableView.register(LocationViewCell.self, forCellReuseIdentifier: locationViewCellId)
        channelDetailsContainerView.tableView.register(UsersTableViewCell.self, forCellReuseIdentifier: userCellId)
        channelDetailsContainerView.tableView.register(ChannelDescriptionCell.self, forCellReuseIdentifier: channelDescriptionCellId)
        channelDetailsContainerView.tableView.register(ChannelDetailsCell.self, forCellReuseIdentifier: channelDetailsCellId)
        channelDetailsContainerView.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: loadMoreCellId)
        
        channelImageView = UIImageView(frame: CGRect(x: 0, y:0, width: channelDetailsContainerView.tableView.frame.width, height: 250))
        
        configureChannelImageHeaderView()
        configureFooterView()
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    fileprivate func removeListeners() {
        if channelListener != nil {
            channelListener = nil
            channelListener?.remove()
        }
        
        if channelPartiticapntsListener != nil {
            channelPartiticapntsListener = nil
            channelPartiticapntsListener?.remove()
        }
    }
    
    func configureChannelImageHeaderView() {
        
        guard let channelImageView = channelImageView else { return }
        
        channelImageView.backgroundColor = .handshakeLightPurple
        channelImageView.contentMode = .scaleAspectFill
        channelImageView.clipsToBounds = true
        channelImageView.isUserInteractionEnabled = true
        channelImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openChannelProfilePicture)))
        channelDetailsContainerView.tableView.tableHeaderView = channelImageView
        if let url = channel?.imageUrl {
            channelImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "GroupIcon"), options: [.continueInBackground, .scaleDownLargeImages], completed: { (image, error, _, _) in
                print(error?.localizedDescription ?? "")
                self.channelImage = image
            })
        }
    }
    
    let footerView = ChannelDetailsFooterView()
    
    func configureFooterView() {
        
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let currentUserID = Auth.auth().currentUser?.uid, let authorID = channel?.author else { return }
        fullDateFormatter.dateFormat = "MMM d @ h:mm a"
        let createdAt = fullDateFormatter.string(from: Date(timeIntervalSince1970: Double(channel?.createdAt.value ?? 0)))
        
        if authorID == currentUserID {
            footerView.primaryLabel.text = "You created this event"
        } else {
            if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == authorID }),
               let name = realmUser.localName {
                footerView.primaryLabel.text = "Created by \(name)"
            } else {
                Firestore.firestore().collection("users").document(authorID).getDocument { (snapshot, error) in
                    guard let data = snapshot?.data() as [String:AnyObject]?, error == nil else { return }
                    let user = User(dictionary: data)
                    if let name = user.name {
                        self.footerView.primaryLabel.text = "Created by \(name)"
                    }
                }
            }
        }
        footerView.secondaryLabel.text = "Created \(createdAt)"
        
        
        let footer = UIView(frame : CGRect(x: 0, y: 0, width: channelDetailsContainerView.tableView.frame.width, height: 115))
        footer.addSubview(footerView)
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 0),
            footerView.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: 0),
            footerView.topAnchor.constraint(equalTo: footer.topAnchor, constant: 0),
            footerView.heightAnchor.constraint(equalToConstant: 50),
        ])
 
        channelDetailsContainerView.tableView.tableFooterView = footer
        channelDetailsContainerView.backgroundColor = .red
        
    }
    
    // MARK: - Theme
    
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
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        channelDetailsContainerView.tableView.sectionIndexBackgroundColor = view.backgroundColor
        channelDetailsContainerView.tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        channelDetailsContainerView.tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        channelDetailsContainerView.setColors()
        footerView.setColors()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.backgroundColor = ThemeManager.currentTheme().windowBackground
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.channelDetailsContainerView.tableView.reloadData()
        }
    }
    
    
    // MARK: - Navigation
    
    @objc func popController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func presentOptions() {
        guard Auth.auth().currentUser != nil, currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }

        guard let channel = channel,
              let channelID = channel.id,
              let currentUserID = Auth.auth().currentUser?.uid
        else { return }

        hapticFeedback(style: .impact)
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
        if channel.admins.contains(currentUserID) {
            let editEventAction = CustomAlertAction(title: "Edit event", style: .default , handler: {
                let destination = UpdateChannelController(style: .plain)
                destination.channel = RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: channelID)
//                self.navigationController?.pushViewController(destination, animated: true)
                if let channelImage = self.channelImage {
                    destination.selectedImage = channelImage
                }
                let navController = UINavigationController(rootViewController: destination)
                
                navController.isModalInPresentation = true
                self.present(navController, animated: true, completion: nil)

            })
            alert.addAction(editEventAction)

        }
        let addToCalendarAction = CustomAlertAction(title: "Add to calendar", style: .default , handler: { [weak self] in
            //self?.addToCalendar()
        })
        alert.addAction(addToCalendarAction)
        let deleteAction = CustomAlertAction(title: "Delete and exit", style: .destructive , handler: {
            //self.deleteAndExitHandler()
        })
        alert.addAction(deleteAction)
        self.present(alert, animated: true)
    }
    
    @objc func presentRSVPList() {
        guard let channelID = channel?.id, let currentUserID = Auth.auth().currentUser?.uid, let admins = channel?.admins else { return }
        let destination = ParticipantsController()
        destination.participants = attendees
        destination.channel = RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: channelID)
        destination.admin = admins.contains(currentUserID)
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .formSheet
        newNavigationController.navigationBar.isHidden = false
        present(newNavigationController, animated: true, completion: nil)
    }
    
    @objc func presentRSVPOptions() {
        
    }
    
    // MARK: - Cell Interaction Handlers
    
    @objc
    fileprivate func openChannelProfilePicture() {
        guard currentReachabilityStatus != .notReachable,
              let currentUserID = Auth.auth().currentUser?.uid,
              let channelImageView = channelImageView,
              let allowed = channel?.admins.contains(currentUserID) else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        avatarOpener.handleAvatarOpening(avatarView: channelImageView, at: self, isEditButtonEnabled: allowed, title: .group)
    }
    
    @objc
    func presentLocationActions() {
        hapticFeedback(style: .impact)
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(CustomAlertAction(title: "Maps", style: .default, handler: { [weak self] in
            //self?.openInMaps(type: "apple")
        }))

        alert.addAction(CustomAlertAction(title: "Google Maps", style: .default, handler: { [weak self] in
            //self?.openInMaps(type: "google")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    // MARK: - Datasource Observers
    
    private var onceToken = 0
    
    fileprivate func observeChannel() {
        // observe channel changes
        guard let channelID = channel?.id else { return }
        var first = true
        channelListener = Firestore.firestore().collection("channels").document(channelID).addSnapshotListener({ snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            if first {
                first = false
                return
            }
            
            guard let channelDictionary = snapshot?.data() as [String: AnyObject]? else { return }
            let channel = Channel(dictionary: channelDictionary)
            self.channel = channel
            self.configureChannelImageHeaderView()
            DispatchQueue.main.async { [weak self] in
                self?.channelDetailsContainerView.tableView.reloadData()
            }
            
            
        })
    }
    
    fileprivate func observeChannelAttendeesChanges() {
        // handle channel attendess changes
        // are the changes in a user that's not being shown? redundant
        guard let channelID = channel?.id else { return }
        channelPartiticapntsListener = Firestore.firestore().collection("channels").document(channelID).collection("participantIds").addSnapshotListener({ snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "err")
                return
            }
            snapshot?.documentChanges.forEach({ diff in
                if diff.type == .added {
                    
                } else if diff.type == .removed {
                    
                } else {
                    
                }
            })
            
        })
        
    }
    
    func test2(usersToLoad: Int) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let participantIds = channel?.participantIds.filter({ $0 != currentUserID }),
              let currentUser = globalCurrentUser
        else { return }
        
        let group = DispatchGroup()

        attendees.append(currentUser)
        
        // sort participant ids

        for participantId in participantIds {
            group.enter()
            fetchUser(id: participantId) { user, error in
                group.leave()
                if let user = user {
                    guard error == nil else { print(error?.localizedDescription ?? "error"); return }

                    // check for existance in realm as a whole
                    // if exists, then check for difference with local copy

                    if RealmKeychain.realmUsersArray().map({$0.id}).contains(user.id) {
                        if let localRealmUser = RealmKeychain.usersRealm.object(ofType: User.self, forPrimaryKey: user.id),
                           !user.isEqual_(to: localRealmUser) {
                            
                            // update local realm user copy
                            if !(self.localRealm.isInWriteTransaction) {
                                self.localRealm.beginWrite()
                                localRealmUser.email = user.email
                                localRealmUser.name = user.name
                                localRealmUser.localName = user.localName
                                localRealmUser.phoneNumber = user.phoneNumber
                                localRealmUser.userImageUrl = user.userImageUrl
                                localRealmUser.userThumbnailImageUrl = user.userThumbnailImageUrl
                                try! self.localRealm.commitWrite()
                            }
                            
                            // update array
                            if let index = self.attendees.firstIndex(where: { user_ in
                                return user_.id == user.id
                            }) {
                                self.attendees[index] = user
                            }
                        }
                        // IN LOCAL REALM
                        // is different and needs updating?
                        
                    } else if RealmKeychain.realmUsersArray().map({$0.id}).contains(user.id) {
                        // IN NON LOCAL REALM
                        // is different and needs updating?
                        
                        if let nonLocalRealmUser = RealmKeychain.nonLocalUsersRealm.object(ofType: User.self, forPrimaryKey: user.id),
                           !user.isEqual_(to: nonLocalRealmUser) {
                            
                            // update local realm user copy
                            if !(self.nonLocalRealm.isInWriteTransaction) {
                                self.nonLocalRealm.beginWrite()
                                nonLocalRealmUser.email = user.email
                                nonLocalRealmUser.name = user.name
                                nonLocalRealmUser.localName = user.localName
                                nonLocalRealmUser.phoneNumber = user.phoneNumber
                                nonLocalRealmUser.userImageUrl = user.userImageUrl
                                nonLocalRealmUser.userThumbnailImageUrl = user.userThumbnailImageUrl
                                try! self.nonLocalRealm.commitWrite()
                            }
                            
                            // update array
                            if let index = self.attendees.firstIndex(where: { user_ in
                                return user_.id == user.id
                            }) {
                                self.attendees[index] = user
                            }
                            
                        }
                        
                    } else {
                        // NOT IN ANY REALM -- YET
                        // add to nonlocal realm or add to local realm?
                        // add to non local realm, if theres an issue it will be removed from local realm anyway
                        autoreleasepool {
                            if !self.nonLocalRealm.isInWriteTransaction {
                                self.nonLocalRealm.beginWrite()
                                self.nonLocalRealm.create(User.self, value: user, update: .modified)
                                try! self.nonLocalRealm.commitWrite()
                            }
                        }
                        // update array
                    }
                }
                // if doesn't exist in realm, create it
            }
            
            group.notify(queue: .main, execute: { [weak self] in
                self?.channelDetailsContainerView.tableView.reloadData()
            })
        }
        
    }
    
    func test() {
        // 0. filter out currentUser & init temp users arr
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let participantIds = channel?.participantIds.filter({ $0 != currentUserID }),
              let currentUser = globalCurrentUser
        else { return }
        
        var tempAttendees = [User]()
        
        // 1. append current user
        tempAttendees.append(currentUser)
        
        // 2. check if any of ids exist in realm (local or non-local)
        let localAttendees = RealmKeychain.realmUsersArray().filter({ participantIds.contains($0.id ?? "") })
        let nonLocalAttendees = RealmKeychain.realmNonLocalUsersArray().filter({ participantIds.contains($0.id ?? "") })
        
        
        
        
    }
    
//    fileprivate func fetchChannelAttendees() {
//
//        guard let channelID = channel?.id, let currentUserID = Auth.auth().currentUser?.uid else { return }
//
//        /*
//
//         fetch first n users
//
//
//         */
//
//        Firestore.firestore().collection("channels").document(channelID).collection("participantIds").limit(to: initialNumberOfAttendees).getDocuments(completion: { [weak self] snapshot, error in
//
//            if error != nil {
//                print(error?.localizedDescription ?? "error")
//                return
//            }
//
//            guard let docs = snapshot?.documents else { self?.doneFetchingReloadTable(); return }
//
//            if docs.count > 0 {
//                let group = DispatchGroup()
//                for doc in docs {
//                    if doc.documentID != currentUserID {
//                        group.enter()
//                        self?.fetchUser(id: doc.documentID) { user, err in
//
//                            if let user = user {
//                                if RealmKeychain.realmUsersArray().map({ $0.id }).contains(user.id) {
//                                    self?.updateRealmUser(user: user, localRealm: true) { index in
//                                        self?.channelDetailsContainerView.tableView.beginUpdates()
//                                        self?.channelDetailsContainerView.tableView.deleteRows(at: [IndexPath(row: index, section: 3)], with: .none)
//                                        self?.channelDetailsContainerView.tableView.insertRows(at: [IndexPath(row: index, section: 3)], with: .none)
//                                        self?.channelDetailsContainerView.tableView.endUpdates()
//                                    }
//                                } else {
//                                    if !RealmKeychain.realmNonLocalUsersArray().map({ $0.id }).contains(user.id) {
//                                        autoreleasepool {
//                                            if !(self?.realm.isInWriteTransaction ?? false) {
//                                                self?.realm.beginWrite()
//                                                self?.realm.create(User.self, value: user, update: .modified)
//                                                try! self?.realm.commitWrite()
//                                            }
//                                            self?.attendees.append(user)
//                                        }
//                                    } else {
//                                        // user AVAILABLE in non-local users realm
//                                        // if diff, update existing (if any)
//                                        self?.updateRealmUser(user: user, localRealm: false) { index in
//                                            self?.channelDetailsContainerView.tableView.beginUpdates()
//                                            self?.channelDetailsContainerView.tableView.deleteRows(at: [IndexPath(row: index, section: 3)], with: .none)
//                                            self?.channelDetailsContainerView.tableView.insertRows(at: [IndexPath(row: index, section: 3)], with: .none)
//                                            self?.channelDetailsContainerView.tableView.endUpdates()
//                                        }
//                                    }
//                                }
//                            }
//                            group.leave()
//                        }
//                    }
//                }
//
//                group.notify(queue: .main, execute: {
//                    // sort??
//                    self?.channelDetailsContainerView.tableView.reloadData()
//                })
//            }
//
//        })
//
//    }
    
//    fileprivate func updateRealmUser(user: User, localRealm: Bool, completion: @escaping (Int) -> ()) {
//
//        if let realmUser = localRealm ? RealmKeychain.realmUsersArray().first(where: { $0.id == user.id }) : RealmKeychain.realmNonLocalUsersArray().first(where: { $0.id == user.id }) {
//            if !user.isEqual_(to: realmUser) {
//                if let index = self.attendees.firstIndex(where: { $0.id == realmUser.id }) {
//                    // update in realm too
//                    if !(self.realm.isInWriteTransaction) {
//                        self.realm.beginWrite()
//                        realmUser.email = user.email
//                        realmUser.name = user.name
//                        realmUser.localName = user.localName
//                        realmUser.phoneNumber = user.phoneNumber
//                        realmUser.userImageUrl = user.userImageUrl
//                        realmUser.userThumbnailImageUrl = user.userThumbnailImageUrl
//                        try! self.realm.commitWrite()
//                        completion(index)
//                    }
//
//                }
//            }
//        }
//    }
    
    func populateAllAttendees(at indexPath: IndexPath) {
        guard let channelParticipantIds = channel?.participantIds, let currentUserID = Auth.auth().currentUser?.uid else { return }
        let localAttendees = RealmKeychain.realmUsersArray().filter({ channelParticipantIds.contains($0.id ?? "") })
        let nonLocalAttendees = RealmKeychain.realmNonLocalUsersArray().filter({ channelParticipantIds.contains($0.id ?? "") })
        
        let listSet = NSSet(array: Array(channelParticipantIds))
        let findListSet = NSSet(array: localAttendees.map({ $0.id ?? "" }))
        
        let tempAttendees = nonLocalAttendees.map({ $0.id ?? "" })
        
        let allElemtsEqual = findListSet.isSubset(of: listSet as! Set<AnyHashable>)
        
        let diff = zip(Array(channelParticipantIds), tempAttendees).map({ $0.0 == $0.1 })
        
        var filteredArr = [String]()
        for id in tempAttendees {
            if !channelParticipantIds.contains(id) && id != currentUserID {
                filteredArr.append(id)
            }
        }
        
        print(channelParticipantIds, tempAttendees, "DIFFERENCE")
        
        // check if two arrays are equal
        if Array(channelParticipantIds).containsSameElements(as: tempAttendees) {
            print("dfvlkmdklfvmlkdf")
        } else {
            // load others
            
        }
        
        print("allElemtsEqual", allElemtsEqual)
    }
            
//            if error != nil {
//                print(error?.localizedDescription ?? "sdd")
//                return
//            }
            
//            guard let docs = snapshot?.documents else { print("no docs?"); return }
            
//            self.attendees.append(globalCurrentUser)
            
//            guard error != nil, let docs = snapshot?.documents else { print(error?.localizedDescription ?? "error \(error)"); return }
//            let group = DispatchGroup()
//            for doc in docs {
//                group.enter()
//                if doc.documentID != currentUserID {
//                    self.fetchUser(id: doc.documentID) { user, error in
//                        if let user = user {
////                            autoreleasepool {
////                                if !self.realm.isInWriteTransaction {
////                                    self.realm.beginWrite()
////                                    self.realm.create(User.self, value: user, update: .modified)
////                                    try! self.realm.commitWrite()
////                                }
////                            }
//                            self.attendees.append(user)
//                        }
//                        group.leave()
//                    }
//                }
//            }
//            group.notify(queue: .main) { [weak self] in
//
//                self?.doneFetchingReloadTable()
//            }
            
//        })
        
        // we know all the participants
//        var allofem = [User]()
//        guard let currentUser = globalCurrentUser, let currentUserID = Auth.auth().currentUser?.uid, let channelID = channel?.id, let channelParticipantIds = channel?.participantIds else { return }
//        allofem.append(currentUser)
//        allofem += RealmKeychain.realmUsersArray().filter({ channelParticipantIds.contains($0.id ?? "") })
//
//        print("bout to print")
//        print(allofem.map({$0.localName}))
//
//        let attendeeIdsNotInRealm = channelParticipantIds.filter({ !allofem.map({$0.id}).contains($0) && $0 != currentUserID })
//
//        print("not in realm \(attendeeIdsNotInRealm.count)")
//
//        if attendeeIdsNotInRealm.count > 0 {
//            let group = DispatchGroup()
//            for id in attendeeIdsNotInRealm {
//                group.enter()
//                self.fetchUser(id: id) { user, error in
//                    group.leave()
//                    if let user = user {
//                        self.attendees.append(user)
//                    }
//                }
//
//                group.notify(queue: .main) { [weak self] in
//                    self?.attendees += allofem
//                    self?.doneFetchingReloadTable()
//                }
//            }
            
//            channelPartiticapntsListener = Firestore.firestore().collection("channels").document(channelID).collection("participantIds").limit(to: initialNumberOfAttendees).addSnapshotListener({ [weak self] snapshot, error in
//                guard error != nil, let docs = snapshot?.documents else { print(error?.localizedDescription ?? "error"); return }
//                let group = DispatchGroup()
//                for doc in docs {
//                    group.enter()
//                    self?.fetchUser(id: doc.documentID) { user, error in
//                        group.leave()
//                        if let user = user {
//                            self?.attendees.append(user)
//                        }
//                    }
//                }
//                group.notify(queue: .main) { [weak self] in
//                    self?.doneFetchingReloadTable()
//                }
//            })
//        } else {
//            print("shouldnt be reached")
//            DispatchQueue.main.async { [weak self] in
//                self?.doneFetchingReloadTable()
//            }
//        }

//    }
    
//    func loadAllAttendees(at indexPath: IndexPath) {
//        guard let attendeeIds = channel?.participantIds else { return }
//        // load realm users
//        var allUsers = [User]()
//
//        allUsers = RealmKeychain.realmUsersArray()
//
//        print(allUsers.map({ $0.name }))
//    }
    
    // MARK: - Helper methods
    
    fileprivate func doneFetchingReloadTable() {
//        self.initialAttendeesLoaded = true
//        if let participantIdCount = self.channel?.participantIds.count {
//            if self.attendees.count == participantIdCount {
//                self.allAttendeesLoaded = true
//            } else {
//                self.allAttendeesLoaded = false
//            }
//        }
        self.channelDetailsContainerView.tableView.reloadData()
    }
    
    // user fetching method
    func fetchUser(id: String, completion: @escaping (User?, Error?) -> ()) {
        Firestore.firestore().collection("users").document(id).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                completion(nil, error)
                return
            }
            guard let userData = snapshot?.data() as [String : AnyObject]? else { return }
            completion(User(dictionary: userData), nil)
        }
    }
    
}
