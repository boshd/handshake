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
import EventKit
import MapKit

class ChannelDetailsController: UIViewController, UIGestureRecognizerDelegate {
    
//    var realmChannel: Channel?
    var channel: Channel?
    
    var channelID = String() {
        didSet {
            observeChannel()
            observeChannelAttendeesChanges()
        }
    }
    var channelImage: UIImage?
    
    var attendees = [User]()
    
    let channelDetailsContainerView = ChannelDetailsContainerView()
    var channelImageView: UIImageView?
    
    var channelListener: ListenerRegistration?
    var channelPartiticapntsListener: ListenerRegistration?
    var currentChannelReference: DocumentReference?
    
    let accountSettingsCellId = "accountSettingsCellId"
    let channelNameCellId = "channelNameCellId"
    let locationViewCellId = "locationViewCellId"
    let userCellId = "userCellId"
    let channelDescriptionCellId = "channelDescriptionCellId"
    let channelDetailsCellId = "channelDetailsCellId"
    let loadMoreCellId = "loadMoreCellId"
    
    var mapAnnotation: MKAnnotation?
    var mapAddress: String?
    
    let tableSectionHeaderHeight: CGFloat = 27.5
    
    let initialNumberOfAttendees = 5
    var isInitial = true {
        didSet {
            populateAttendees()
        }
    }
    
    let fullDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let avatarOpener = AvatarOpener()
    let channelDetailsDataDatabaseUpdater = ChannelDetailsDataDatabaseUpdater()
    
    let eventStore = EKEventStore()
    
    var expandedCells = Set<Int>()
    
    let nonLocalRealm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
    let localRealm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    
    let informationMessageSender = InformationMessageSender()
    
    // MARK: - Lifecycle
    
    deinit {
        print("DETAILS WILL BE DEALLOCATED NOW")
        removeListeners()
    }
    
    override func loadView() {
        super.loadView()
        view = channelDetailsContainerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNaviationBar()
        configureMapView()
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        currentChannelReference = Firestore.firestore().collection("channels").document(channelID)
        
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
        
//        channelDetailsContainerView.rsvpButton.target(forAction: #selector(presentRSVPOptions), withSender: self)
        channelDetailsContainerView.rsvpButton.addTarget(self, action: #selector(presentRSVPOptions), for: .touchUpInside)
    }
    
    fileprivate func configureMapView() {
        guard let lat = channel?.latitude.value, let lon = channel?.longitude.value else { return }
        let location = CLLocation(latitude: lat, longitude: lon)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { [weak self] placemarks, error -> Void in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            guard let placeMark = placemarks?.first else { return }
            let item = MKPlacemark(placemark: placeMark)

            self?.mapAddress = parseAddress(selectedItem: item)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self?.mapAnnotation = annotation
        })
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
            channelImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "handshake"), options: [.continueInBackground, .scaleDownLargeImages], completed: { [weak self] (image, error, _, _) in
                if error != nil { print(error?.localizedDescription ?? ""); return }
                self?.channelImage = image
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
                Firestore.firestore().collection("users").document(authorID).getDocument { [weak self] (snapshot, error) in
                    guard let data = snapshot?.data() as [String:AnyObject]?, error == nil else { return }
                    let user = User(dictionary: data)
                    if let name = user.name {
                        self?.footerView.primaryLabel.text = "Created by \(name)"
                    }
                }
            }
        }
        footerView.secondaryLabel.text = "Created \(createdAt)"
        
        
        let footer = UIView(frame : CGRect(x: 0, y: 0, width: channelDetailsContainerView.tableView.frame.width, height: 70))
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
            let editEventAction = CustomAlertAction(title: "Edit event", style: .default , handler: { [weak self] in
                let destination = UpdateChannelController(style: .plain)
                destination.channel = self?.channel
                if let channelImage = self?.channelImage {
                    destination.selectedImage = channelImage
                }
                let navController = UINavigationController(rootViewController: destination)
                
                navController.isModalInPresentation = true
                self?.present(navController, animated: true, completion: nil)

            })
            alert.addAction(editEventAction)
        }
        
        let addToCalendarAction = CustomAlertAction(title: "Add to Calendar", style: .default , handler: { [weak self] in
            self?.addToCalendar()
        })
        let deleteAction = CustomAlertAction(title: "Leave Event", style: .destructive , handler: { [weak self] in
            let alert = CustomAlertController(title_: "Confirmation", message: "Are you sure you want to leave this event?", preferredStyle: .alert)
            alert.addAction(CustomAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(CustomAlertAction(title: "Yes", style: .destructive, handler: { [weak self] in
                self?.leaveEvent()
            }))
            self?.present(alert, animated: true, completion: nil)
        })
        
        alert.addAction(addToCalendarAction)
        alert.addAction(deleteAction)
        
        self.present(alert, animated: true)
    }
    
    @objc func presentRSVPList() {
        guard let currentUserID = Auth.auth().currentUser?.uid, let admins = channel?.admins else { return }
        
        let destination = ParticipantsController()
//        destination.participants = attendees
        destination.channel = self.channel
        destination.admin = admins.contains(currentUserID)
        let newNavigationController = UINavigationController(rootViewController: destination)
        newNavigationController.modalPresentationStyle = .formSheet
        newNavigationController.navigationBar.isHidden = false
        present(newNavigationController, animated: true, completion: nil)
    }
    
    @objc func presentRSVPOptions() {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let goingIds = channel?.goingIds,
              let notGoingIds = channel?.notGoingIds,
              let tentativeIds = channel?.maybeIds
        else { return }
        
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
        
        let goingAction = CustomAlertAction(title: "Going", style: .default , handler: { [weak self] in
            self?.rsvp(.going, memberID: currentUserID)
        })
        
        let notGoingAction = CustomAlertAction(title: "Not going", style: .default , handler: { [weak self] in
            self?.rsvp(.notGoing, memberID: currentUserID)
        })
        
        let tentativeAction = CustomAlertAction(title: "Tentative", style: .default , handler: { [weak self] in
            self?.rsvp(.tentative, memberID: currentUserID)
        })
        
        if goingIds.contains(currentUserID) {
            goingAction.isEnabled = false
        } else if tentativeIds.contains(currentUserID) {
            tentativeAction.isEnabled = false
        } else if notGoingIds.contains(currentUserID) {
            notGoingAction.isEnabled = false
        }
        
        alert.addAction(goingAction)
        alert.addAction(tentativeAction)
        alert.addAction(notGoingAction)
        
        present(alert, animated: true, completion: nil)
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
            self?.openInMaps(type: "apple")
        }))

        alert.addAction(CustomAlertAction(title: "Google Maps", style: .default, handler: { [weak self] in
            self?.openInMaps(type: "google")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @objc
    func leaveEvent() {
        guard let channelID = channel?.id, let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        guard let index = attendees.firstIndex(where: { (user) -> Bool in
            return user.id == currentUserID
        }) else { return }
        guard let memberName = attendees[index].name else { return }
        let text = "\(memberName) left the group"
        
        let channelName = self.channel?.name ?? ""
        
        let channelCopy = Channel(value: channel)
        
        let channelParticipantReference = Firestore.firestore().collection("channels").document(channelID).collection("participantIds").document(currentUserID)
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        let participantChannelReference = Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(channelID)
        
        let batch = Firestore.firestore().batch()
        
        batch.deleteDocument(channelParticipantReference)
        batch.deleteDocument(participantChannelReference)
        batch.updateData(["participantIds": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
        batch.updateData(["fcmTokens": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
        
        batch.commit { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                print(error?.localizedDescription ?? "err")
                return
            }
            
            self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channelName, participantIDs: self.attendees.map({$0.id ?? ""}), text: text, channel: channelCopy)
            
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: - Datasource Observers
    
    private var onceToken = 0
    
    fileprivate func observeChannel() {
        channelListener = Firestore.firestore().collection("channels").document(channelID).addSnapshotListener({ [weak self] snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            guard let channelDictionary = snapshot?.data() as [String: AnyObject]? else { return }
            let channel = Channel(dictionary: channelDictionary)
            
            self?.channel = channel
            
//            if self?.channel?.imageUrl != channel.imageUrl {
                self?.configureChannelImageHeaderView()
//            }
            self?.configureFooterView()
            self?.configureMapView()
//            if self?.channel?.participantIds != channel.participantIds {
                self?.populateAttendees()
//            }
            
            DispatchQueue.main.async { [weak self] in
                self?.channelDetailsContainerView.tableView.reloadData()
            }
        })
    }
    
    fileprivate func observeChannelAttendeesChanges() {
        // handle channel attendess changes
        // are the changes in a user that's not being shown? redundant
        var initial = true
        guard let channelID = channel?.id else { return }
        channelPartiticapntsListener = Firestore.firestore().collection("channels").document(channelID).collection("participantIds").addSnapshotListener({ [weak self] snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "err")
                return
            }
            if initial {
                initial = false
                return
            }
            snapshot?.documentChanges.forEach({ diff in
                if diff.type == .added {
                    UsersFetcher.fetchUser(id: diff.document.documentID) { user, error in
                        guard error == nil else { print(error?.localizedDescription ?? ""); return }
                        // issues w/ initial state
                        if let user = user {
                            
                            // this triggers test2()
                            if let isInitial = self?.isInitial, isInitial {
                                self?.isInitial = false
                            }
                            
//                            UIView.performWithoutAnimation {
//                                if let userIndex = self?.attendees.firstIndex(where: { (member) -> Bool in
//                                    return member.id == diff.document.documentID
//                                }) {
//                                    print("here1 \(self?.attendees.count)", userIndex, self?.attendees.map({$0.name}))
//                                    self?.channelDetailsContainerView.tableView.beginUpdates()
//                                    self?.attendees[userIndex] = user
//                                    self?.channelDetailsContainerView.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 3)], with: .none)
//                                    self?.channelDetailsContainerView.tableView.endUpdates()
//                                } else {
//                                    print("here2 \((self?.attendees.count))")
//                                    self?.channelDetailsContainerView.tableView.beginUpdates()
//                                    self?.attendees.append(user)
//                                    var index = 0
//                                    if let count = self?.attendees.count, count-1 >= 0 { index = count - 1 }
//                                    self?.channelDetailsContainerView.tableView.insertRows(at: [IndexPath(row: index, section: 3)], with: .fade)
//                                    self?.channelDetailsContainerView.tableView.endUpdates()
//                                }
//
//                            }
                        }
                    }
                } else if diff.type == .removed {
                    guard let memberIndex = self?.attendees.firstIndex(where: { (member) -> Bool in
                        return member.id == diff.document.documentID
                    }) else { return }

                    self?.channelDetailsContainerView.tableView.beginUpdates()
                    self?.attendees.remove(at: memberIndex)
                    self?.channelDetailsContainerView.tableView.deleteRows(at: [IndexPath(row: memberIndex, section: 3)], with: .left)
                    self?.channelDetailsContainerView.tableView.endUpdates()
                    if let isMember = self?.isCurrentUserMemberOfCurrentGroup(), !isMember {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            })
            
        })
        
    }
    
    func populateAttendees() {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let participantIds = self.channel?.participantIds
        else { return }
        
        
        attendees.removeAll()
        
        var mutableParticipantIds = [String]()
        
        if isInitial && initialNumberOfAttendees < participantIds.count {
            mutableParticipantIds += Array(participantIds).prefix(initialNumberOfAttendees)
        } else {
            mutableParticipantIds +=  Array(participantIds)
        }
        
        if let globalCurrentUser = globalCurrentUser {
            attendees.append(globalCurrentUser)
        }
        
        let group = DispatchGroup()

        for participantId in mutableParticipantIds {
            if participantId == currentUserID { continue }
            group.enter()
            
            if RealmKeychain.realmNonLocalUsersArray().map({$0.id}).contains(participantId) {
                if let usr = RealmKeychain.realmNonLocalUsersArray().first(where: {$0.id == participantId}) {
                    attendees.append(usr)
                }
            }
            
            if RealmKeychain.realmUsersArray().map({$0.id}).contains(participantId) {
                if let usr = RealmKeychain.realmUsersArray().first(where: {$0.id == participantId}) {
                    attendees.append(usr)
                }
            }
            
            UsersFetcher.fetchUser(id: participantId) { user, error in
                group.leave()
                if let user = user {
                    guard error == nil else { print(error?.localizedDescription ?? "error"); return }

                    if RealmKeychain.realmUsersArray().map({$0.id}).contains(user.id) {
                        if let localRealmUser = RealmKeychain.usersRealm.object(ofType: User.self, forPrimaryKey: user.id),
                           !user.isEqual_(to: localRealmUser) {
                            // this shouldn't pass....?
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
                    } else if RealmKeychain.realmNonLocalUsersArray().map({$0.id}).contains(user.id) {
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
                        autoreleasepool {
                            if !self.nonLocalRealm.isInWriteTransaction {
                                self.nonLocalRealm.beginWrite()
                                self.nonLocalRealm.create(User.self, value: user, update: .modified)
                                try! self.nonLocalRealm.commitWrite()
                            }
                        }
                        self.attendees.append(user)
                    }
                }
            }
            
            group.notify(queue: .main, execute: { [weak self] in
                guard let self = self else { return }
                
//                var ordinaryAttendees = [User]()
//                var adminAttendees = [User]()
//                var sortedAttendees = [User]()
//
//                for attendee in self.attendees {
//                    if let admins = self.channel?.admins, let id = attendee.id {
//                        if admins.contains(id) {
//                            adminAttendees.append(attendee)
//                        } else {
//                            ordinaryAttendees.append(attendee)
//                        }
//                    }
//                }
                
//                self.attendees.removeAll()
//
//                if let globalCurrentUser = globalCurrentUser {
//                    self.attendees.append(globalCurrentUser)
//                }
                
//                sortedAttendees = adminAttendees + ordinaryAttendees
//                self.attendees += sortedAttendees
                
                self.channelDetailsContainerView.tableView.reloadData()
            })
        }
        
    }
    
    // MARK: - Helper methods
    
    func isCurrentUserMemberOfCurrentGroup() -> Bool {
        guard let membersIDs = channel?.participantIds, let uid = Auth.auth().currentUser?.uid, membersIDs.contains(uid) else { return false }
        return true
    }
    
}

// MARK: - Channel members action handlers

extension ChannelDetailsController {
    
    @objc func viewProfile(member: User) {
        let destination = ParticipantProfileController()
        destination.member = member
        destination.userProfileContainerView.addPhotoLabel.isHidden = true
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func removeAdmin(memberID: String) {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        guard let ref = currentChannelReference, let channelID = channel?.id else { return }
        globalIndicator.show()
        ChannelManager.removeAdmin(ref: ref, memberID: memberID, channelID: channelID) { error in
            guard error == nil else {
                globalIndicator.dismiss()
                print(error?.localizedDescription ?? "")
                displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            globalIndicator.showSuccess(withStatus: "Dismissed")
            hapticFeedback(style: .success)
            if let name = self.attendees.filter({ $0.id == memberID }).first?.name, let channelName = self.channel?.name {
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channelName, participantIDs: [], text: "\(name) has been dismissed as Organizer", channel: self.channel)
            }
        }
    }
    
    @objc func makeAdmin(memberID: String) {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        guard let ref = currentChannelReference, let channelID = channel?.id else { return }
        globalIndicator.show()
        ChannelManager.makeAdmin(ref: ref, memberID: memberID, channelID: channelID) { error in
            guard error == nil else {
                globalIndicator.dismiss()
                print(error?.localizedDescription ?? "")
                displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            globalIndicator.showSuccess(withStatus: nil)
            hapticFeedback(style: .success)
            if let name = self.attendees.filter({ $0.id == memberID }).first?.name, let channelName = self.channel?.name {
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channelName, participantIDs: [], text: "\(name) is now an Organizer", channel: self.channel)
            }
        }
    }
    
    
    @objc func removeMember(memberID: String) {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        guard let channelReference = currentChannelReference,
              let channelID = channel?.id
        else { return }
        
        let userReference = Firestore.firestore().collection("users").document(memberID)
        
        let nameToBeDeleted = self.attendees.filter({ $0.id == memberID }).first?.name
         
        globalIndicator.show()
        ChannelManager.removeMember(channelReference: channelReference, userReference: userReference, memberID: memberID, channelID: channelID) { error in
            guard error == nil else {
                globalIndicator.dismiss()
                print(error?.localizedDescription ?? "")
                displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            globalIndicator.showSuccess(withStatus: "Removed")
            hapticFeedback(style: .success)
            if let name = nameToBeDeleted, let channelName = self.channel?.name {
//                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channelName, participantIDs: [], text: "\(name) has been removed from the event", channel: self.channel)
            }
//            self.channelDetailsContainerView.tableView.reloadData()
        }
    }
    
    @objc
    func openInMaps(type: String) {
        guard let lat = channel?.latitude.value, let lon = channel?.longitude.value else { return }
        
        if type == "apple" {
            let latitude: CLLocationDegrees = lat
            let longitude: CLLocationDegrees = lon

            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
               MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
               MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Event Location"
            mapItem.openInMaps(launchOptions: options)
        } else {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app

                if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(lat),\(lon)&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:])
            }} else {
            //Open in browser
                if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(lat),\(lon)&directionsmode=driving") {
                    UIApplication.shared.open(urlDestination)
                }
            }
        }
        
        

    }
    
    @objc func addToCalendar() {

        guard let unwrappedChannel = channel else { return }
        
        let name = unwrappedChannel.name
        let endTime = unwrappedChannel.endTime.value
        let description_ = unwrappedChannel.description_
        let locationName = unwrappedChannel.locationName
        let startTime = unwrappedChannel.startTime.value
        let isRemote = unwrappedChannel.isRemote.value
        let lat = unwrappedChannel.latitude.value
        let lon = unwrappedChannel.longitude.value

        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: self.eventStore)

                event.title = name
                event.startDate = Date(timeIntervalSince1970: TimeInterval(startTime ?? 0))
                event.endDate = Date(timeIntervalSince1970: TimeInterval(endTime ?? 0))
                event.notes = description_


                if let isRemote = isRemote, isRemote {
                    event.location = "Remote"
                } else {
                    if let lat = lat, let lon = lon, let locationName = locationName {
                        let location = CLLocation(latitude: lat, longitude: lon)
                        let structuredLocation = EKStructuredLocation(title: locationName)
                        structuredLocation.geoLocation = location
                        event.structuredLocation = structuredLocation
                    }
                }

                event.calendar = self.eventStore.defaultCalendarForNewEvents
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }

                hapticFeedback(style: .success)
                displayAlert(title: "Success", message: "The event has been saved to your calendar", preferredStyle: .alert, actionTitle: "Got it", controller: self)
            } else {
                print("failed to save event with error : \(error?.localizedDescription ?? "") or access not granted")
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Could not save event, check permissions?", preferredStyle: .alert, actionTitle: "Got it", controller: self)

            }
        }
    }
    
    func rsvp(_ rsvp: EventRSVP, memberID: String) {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        guard let channelReference = currentChannelReference else { return }
        globalIndicator.show()
        ChannelManager.rsvp(channelReference: channelReference, memberID: memberID, rsvp: rsvp) { error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                globalIndicator.dismiss()
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Operation could not be completed", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            globalIndicator.showSuccess(withStatus: nil)
            hapticFeedback(style: .success)
            if let name = globalCurrentUser?.name, let channelName = self.channel?.name {
                var text = ""
                if rsvp == .going {
                    text = "\(name) is going."
                } else if rsvp == .notGoing {
                    text = "\(name) can't make it."
                } else {
                    text = "\(name) might attend."
                }
                
                // self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channelName, participantIDs: [], text: text, channel: self.channel)
            }
            
        }
        
    }
    
    
}
