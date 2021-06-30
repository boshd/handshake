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
    
    let initialNumberOfAttendees = 5
    
    var allAttendeesLoaded = false
    var initialAttendeesLoaded = false
    
    let fullDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var expandedCells = Set<Int>()
    
    let realm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        view = channelDetailsContainerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNaviationBar()
        observeChannelAttendeesChanges()
        fetchChannelAttendees()
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
        channelDetailsContainerView.tableView.delegate = self
        channelDetailsContainerView.tableView.dataSource = self
        channelDetailsContainerView.tableView.register(AccountSettingsTableViewCell.self, forCellReuseIdentifier: accountSettingsCellId)
        channelDetailsContainerView.tableView.register(ChannelNameCell.self, forCellReuseIdentifier: channelNameCellId)
        channelDetailsContainerView.tableView.register(LocationViewCell.self, forCellReuseIdentifier: locationViewCellId)
        channelDetailsContainerView.tableView.register(UsersTableViewCell.self, forCellReuseIdentifier: userCellId)
        channelDetailsContainerView.tableView.register(ChannelDescriptionCell.self, forCellReuseIdentifier: channelDescriptionCellId)
        channelDetailsContainerView.tableView.register(ChannelDetailsCell.self, forCellReuseIdentifier: channelDetailsCellId)
        channelDetailsContainerView.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: loadMoreCellId)
        
        configureChannelImageHeaderView()
        configureFooterView()
        
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
        let channelImageView = UIImageView(frame: CGRect(x: 0, y:0, width: channelDetailsContainerView.tableView.frame.width, height: 250))
        channelImageView.backgroundColor = .handshakeLightPurple
        channelImageView.contentMode = .scaleAspectFill
        channelImageView.clipsToBounds = true
        channelDetailsContainerView.tableView.tableHeaderView = channelImageView
        if let url = channel?.imageUrl {
            channelImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "GroupIcon"), options: [.continueInBackground, .scaleDownLargeImages], completed: { (image, error, _, _) in
                print(error?.localizedDescription ?? "")
                self.channelImage = image
            })
        }
    }
    
    func configureFooterView() {
        let footerView = ChannelDetailsFooterView()
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
                        footerView.primaryLabel.text = "Created by \(name)"
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
    func presentLocationActions() {
        hapticFeedback(style: .impact)
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(CustomAlertAction(title: "Maps", style: .default , handler: { [weak self] in
            //self?.openInMaps(type: "apple")
        }))

        alert.addAction(CustomAlertAction(title: "Google Maps", style: .default , handler: { [weak self] in
            //self?.openInMaps(type: "google")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    // MARK: - Datasourcing
    
    fileprivate func observeChannel() {
        guard let channelID = channel?.id else { return }
        channelListener = Firestore.firestore().collection("channels").document(channelID).addSnapshotListener({ snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
        })
    }
    
    func loadAllAttendees(at indexPath: IndexPath) {
        guard let attendeeIds = channel?.participantIds else { return }
        
        // load realm users
        
    
        
        
//        let group = DispatchGroup()
        var allUsers = [User]()
        
        allUsers = RealmKeychain.realmUsersArray()
        
        print(allUsers.map({ $0.name }))
        
//        for id in attendeeIds {
//            group.enter()
//            fetchUser(id: id) { user, error in
//                group.leave()
//                if error != nil {
//                    print(error?.localizedDescription ?? "error")
//                    return
//                }
//                if let user = user {
//                    allUsers.append(user)
//                }
//            }
//        }
//
//        group.notify(queue: .main, execute: { [weak self] in
//            self?.attendees = allUsers
//            self?.allAttendeesLoaded = true
//
//            self?.channelDetailsContainerView.tableView.beginUpdates()
//            self?.channelDetailsContainerView.tableView.insertRows(at: [indexPath], with: .middle)
//            self?.channelDetailsContainerView.tableView.deleteRows(at: [indexPath], with: .none)
//            self?.channelDetailsContainerView.tableView.endUpdates()
//
//        })
    }
    
    fileprivate func sdkmsd() {

        
    }
    
    fileprivate func fetchChannelAttendees() {
        
        guard let channelID = channel?.id, let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("channels").document(channelID).collection("participantIds").limit(to: initialNumberOfAttendees).getDocuments(completion: { [weak self] snapshot, error in
            
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }

            guard let docs = snapshot?.documents else { self?.doneFetchingReloadTable(); return }
            
            if docs.count > 0 {
                let group = DispatchGroup()
                for doc in docs {
                    if doc.documentID != currentUserID {
                        group.enter()
                        self?.fetchUser(id: doc.documentID) { user, err in
                            
                            if let user = user {
                                if !RealmKeychain.realmNonLocalUsersArray().map({ $0.id }).contains(user.id) {
                                    autoreleasepool {
                                        if !(self?.realm.isInWriteTransaction ?? false) {
                                            self?.realm.beginWrite()
                                            self?.realm.create(User.self, value: user, update: .modified)
                                            try! self?.realm.commitWrite()
                                        }
                                        self?.attendees.append(user)
                                    }
                                } else {
                                    print("OUTHEYAAAAA")
                                    // user AVAILABLE in non-local users realm
                                    // if diff, replace existing (if any)
                                    if let realmUser = RealmKeychain.realmNonLocalUsersArray().first(where: { $0.id == user.id }) {
                                        if !user.isEqual_(to: realmUser) {
                                            if let index = self?.attendees.firstIndex(where: { $0.id == realmUser.id }) {
                                                // update in realm too
                                                if !(self?.realm.isInWriteTransaction ?? false) {
                                                    self?.realm.beginWrite()
                                                    realmUser.email = user.email
                                                    realmUser.name = user.name
                                                    realmUser.localName = user.localName
                                                    realmUser.phoneNumber = user.phoneNumber
                                                    realmUser.userImageUrl = user.userImageUrl
                                                    realmUser.userThumbnailImageUrl = user.userThumbnailImageUrl
                                                    try! self?.realm.commitWrite()
                                                }
                                                
                                                self?.channelDetailsContainerView.tableView.beginUpdates()
                                                self?.channelDetailsContainerView.tableView.deleteRows(at: [IndexPath(row: index, section: 3)], with: .none)
                                                self?.channelDetailsContainerView.tableView.insertRows(at: [IndexPath(row: index, section: 3)], with: .none)
                                                self?.channelDetailsContainerView.tableView.endUpdates()
                                            }
                                        }
                                    }
                                }
                            }
                            group.leave()
                            
                        }
                    }
                }
                
                group.notify(queue: .main, execute: {
                    // sort??
                    self?.channelDetailsContainerView.tableView.reloadData()
                })
            }
            
        })
        
    }
    
    fileprivate func observeChannelAttendeesChanges() {
        
        guard let channelID = channel?.id else { return }
        channelPartiticapntsListener = Firestore.firestore().collection("channels").document(channelID).collection("participantIds").limit(to: initialNumberOfAttendees).addSnapshotListener({ snapshot, error in
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

    }
    
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
