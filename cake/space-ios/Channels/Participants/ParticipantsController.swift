//
//  ParticipantsController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-19.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import Contacts

class ParticipantsController: UIViewController {
    
    let participantsContainerView = ParticipantsContainerView()
    let userCellID = "userCellID"
    
    var goingParticipants = [User]()
    var maybeParticipants = [User]()
    var notGoingParticipants = [User]()
    var noResponseParticipants = [User]()

    var admin: Bool?
    var channel: Channel?
    
    var channelsReference: CollectionReference?
    var usersReference: CollectionReference?
    var currentChannelReference: DocumentReference?
    
    var channelListener: ListenerRegistration?
    
    private var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate!
    
    let nonLocalRealm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
    let localRealm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    
    var participants = [User]()
    var selectedUsers: [User]?
    var segmentedControlIndex = 0
    
    let memberRemovalGroup = DispatchGroup()
    let contact = CNMutableContact()
    let viewPlaceholder = ViewPlaceholder()
    let informationMessageSender = InformationMessageSender()
    
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupNavigationBar()
        configureRSVPuserArrays()
        addObservers()
        listenToChannelChanges()
        fetchAndPopulate()
    }
    
    private func loadViews() {
        self.view = participantsContainerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc fileprivate func changeTheme() {
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationBar)
        }
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        participantsContainerView.tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        participantsContainerView.tableView.sectionIndexBackgroundColor = view.backgroundColor
        participantsContainerView.tableView.backgroundColor = view.backgroundColor
        participantsContainerView.tableView.isOpaque = true
        participantsContainerView.setColors()
        DispatchQueue.main.async { [weak self] in
            self?.participantsContainerView.tableView.reloadData()
        }
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reConfigureCurrentUser), name: .currentUserDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    @objc fileprivate func reConfigureCurrentUser() {
        DispatchQueue.main.async { [weak self] in
            self?.reloadTable()
        }
    }
    
    func listenToChannelChanges() {
        guard let channelID = channel?.id else { return }
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        channelListener = channelReference.addSnapshotListener { [weak self] (snapshot, error) in
            guard let unwrappedSelf = self else { return }
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            guard let data = snapshot?.data() as [String:AnyObject]? else { return }
            let newChannel = Channel(dictionary: data)
            unwrappedSelf.channel = newChannel
            
            unwrappedSelf.configureRSVPuserArrays()
            DispatchQueue.main.async {
                unwrappedSelf.reloadTable()
            }

        }
    }
    
    @objc func handleChannelUpdate(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let channel = obj["channel"] as? Channel,
              let channelID = obj["channelID"] as? String,
              let currentChannelID = channel.id,
              channelID == currentChannelID else { return }
//        segmentedControlIndex = 0
        self.channel = channel
        self.configureRSVPuserArrays()
        DispatchQueue.main.async { [weak self] in
            self?.reloadTable()
        }
    }
    
    fileprivate func setupController() {
        guard let admin = admin, let channelID = channel?.id else { return }
        
        currentChannelReference = Firestore.firestore().collection("channels").document(channelID)
        usersReference = Firestore.firestore().collection("users")
        
        // going participants = channel.goingids somehow
        
        participantsContainerView.interfaceSegmented.delegate = self
        participantsContainerView.tableView.delegate = self
        participantsContainerView.tableView.dataSource = self
        
        participantsContainerView.tableView.register(UserCell.self, forCellReuseIdentifier: userCellID)
        
        
        if admin {
            participantsContainerView.tableView.isUserInteractionEnabled = true
        } else {
            participantsContainerView.tableView.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func configureRSVPuserArrays() {
        guard let channel = channel else { return }
//        goingParticipants = participants.filter({ channel.goingIds.contains($0.id ?? "") })
//        maybeParticipants = participants.filter({ channel.maybeIds.contains($0.id ?? "") })
//        notGoingParticipants = participants.filter({ channel.notGoingIds.contains($0.id ?? "") })
        
        for participant in participants {
            if let id = participant.id {
                if channel.goingIds.contains(id) {
                    goingParticipants.append(participant)
                } else if channel.notGoingIds.contains(id) {
                    notGoingParticipants.append(participant)
                } else if channel.maybeIds.contains(id) {
                    maybeParticipants.append(participant)
                } else {
                    noResponseParticipants.append(participant)
                }
                print("here")
            }
        }
        print("here2", goingParticipants.count, notGoingParticipants.count, maybeParticipants.count)
        var goingTitle = "Going"
        var maybeTitle = "Tentative"
        var notGoingTitle = "Not going"
        var noResponseTitle = "No response"
        
        if goingParticipants.count != 0 {
            goingTitle += " (\(goingParticipants.count))"
        }
        if maybeParticipants.count != 0 {
            maybeTitle += " (\(maybeParticipants.count))"
        }
        if notGoingParticipants.count != 0 {
            notGoingTitle += " (\(notGoingParticipants.count))"
        }
        
        if noResponseParticipants.count != 0 {
            noResponseTitle += " (\(noResponseParticipants.count))"
        }
        
        
        
        participantsContainerView.interfaceSegmented.setButtonTitles(buttonTitles: [noResponseTitle, maybeTitle, goingTitle, notGoingTitle])
        reloadTable()
    }
    
    fileprivate func setupNavigationBar() {
        let count = channel?.participantIds.count
        
        navigationItem.title = "Attendees"
        
        let title = count == 1 ? "1 attendee" : "\(count ?? 0) attendees"
        
        navigationItem.title = title
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        let dismissButton = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action:  #selector(dismissController))
        dismissButton.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = dismissButton
        
        guard let currentUserID = Auth.auth().currentUser?.uid, let channelAdminIDs = channel?.admins else { return }

        if channelAdminIDs.contains(currentUserID) {
            let addMemberButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action:  #selector(addMember))
            addMemberButton.tintColor = .black
            navigationItem.rightBarButtonItem = addMemberButton
        }
    }
    
    // MARK: - Datasource
    
    func fetchAndPopulate() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let participantIds = channel?.participantIds
        else { return }
        
        var mutableParticipantIds = [String]()
        
        mutableParticipantIds +=  Array(participantIds)
        
        if let globalCurrentUser = globalCurrentUser {
            participants.append(globalCurrentUser)
        }
        
        let group = DispatchGroup()

        for participantId in mutableParticipantIds {
            if participantId == currentUserID { continue }
            group.enter()
            
            if RealmKeychain.realmNonLocalUsersArray().map({$0.id}).contains(participantId) {
                if let usr = RealmKeychain.realmNonLocalUsersArray().first(where: {$0.id == participantId}) {
                    participants.append(usr)
                }
            }
            
            if RealmKeychain.realmUsersArray().map({$0.id}).contains(participantId) {
                if let usr = RealmKeychain.realmUsersArray().first(where: {$0.id == participantId}) {
                    participants.append(usr)
                }
            }
            
            UsersFetcher.fetchUser(id: participantId) { user, error in
                group.leave()
                if let user = user {
                    guard error == nil else { print(error?.localizedDescription ?? "error"); return }

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
                            if let index = self.participants.firstIndex(where: { user_ in
                                return user_.id == user.id
                            }) {
                                self.participants[index] = user
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
                            if let index = self.participants.firstIndex(where: { user_ in
                                return user_.id == user.id
                            }) {
                                self.participants[index] = user
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
                        self.participants.append(user)
                    }
                }
            }
            
            group.notify(queue: .main, execute: { [weak self] in
                self?.configureRSVPuserArrays()
                self?.participantsContainerView.tableView.reloadData()
            })
        }
        
    }
    
    // MARK: - @objc methods
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func addMember() {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelParticipantIDs = channel?.participantIds,
              let channelAdminIDs = channel?.admins,
              channelAdminIDs.contains(currentUserID)
        else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: "You are not an admin", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        hapticFeedback(style: .impact)
        
        let destination = AddChannelParticipantsController()
        
        if let selectedUsers = selectedUsers {
            destination.selectedUsers = selectedUsers
        }
        
        destination.channel = channel
        destination.users = RealmKeychain.realmUsersArray()
        destination.filteredUsers = RealmKeychain.realmUsersArray()
        destination.preSelectedUsers = RealmKeychain.realmUsersArray().filter({ channelParticipantIDs.contains($0.id ?? "") })
        destination.setUpCollation()
        destination.delegate = self
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc fileprivate func removeAdmin_(memberID: String) {
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
            globalIndicator.showSuccess(withStatus: "Removed")
            hapticFeedback(style: .success)
            if let name = self.participants.filter({ $0.id == memberID }).first?.name, let channelName = self.channel?.name {
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channelName, participantIDs: [], text: "\(name) has been dismissed as Organizer", channel: self.channel)
            }
        }
    }
    
    @objc fileprivate func removeAdmin(memberID: String) {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        guard let channelID = channel?.id else { return }
        
        globalIndicator.show()
        
        currentChannelReference?.updateData([
            "admins": FieldValue.arrayRemove([memberID])
        ], completion: { [unowned self] (error) in
            globalIndicator.dismiss()
            if error != nil {
                print(error?.localizedDescription ?? "")
                displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            hapticFeedback(style: .success)
            
            
            if let newAdminName = self.participants.filter({ $0.id == memberID }).first?.name {
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel?.name ?? "", participantIDs: [], text: "\(newAdminName) has been dismissed as Organizer", channel: channel)
            }
        
        })
    }
    
    @objc fileprivate func makeAdmin(memberID: String) {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        guard let channelID = channel?.id else { return }
        
        globalIndicator.show()
        
        currentChannelReference?.updateData([
            "admins": FieldValue.arrayUnion([memberID])
        ], completion: { [unowned self] (error) in
            globalIndicator.dismiss()
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                displayErrorAlert(title: "Oops", message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }

            if let newAdminName = self.participants.filter({ $0.id == memberID }).first?.name {
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel?.name ?? "", participantIDs: [], text: "\(newAdminName) is now an Organizer", channel: channel)
            }
            
            hapticFeedback(style: .success)
        })
    }
    
    @objc fileprivate func removeMember_(memberID: String) {
        if currentReachabilityStatus == .notReachable {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        guard let channelID = channel?.id else { return }
        
        globalIndicator.show()
        
        let batch = Firestore.firestore().batch()
        
        let userReference = Firestore.firestore().collection("users").document(memberID)
        let currentChannelReference = Firestore.firestore().collection("channels").document(channelID)
        
        batch.deleteDocument(userReference.collection("channelIds").document(channelID))
        batch.deleteDocument(currentChannelReference.collection("participantIds").document(memberID))
        batch.updateData([
            "participantIds": FieldValue.arrayRemove([memberID]),
            "admins": FieldValue.arrayRemove([memberID]),
            "goingIds": FieldValue.arrayRemove([memberID]),
            "maybeIds": FieldValue.arrayRemove([memberID]),
            "notGoingIds": FieldValue.arrayRemove([memberID]),
        ], forDocument: currentChannelReference)
        
        let fellasName = self.participants.filter({ $0.id == memberID }).first?.name
        self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel?.name ?? "", participantIDs: [], text: "\(fellasName ?? "someone") has been removed from the event", channel: channel)
        batch.commit { [unowned self] (error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            globalIndicator.showSuccess(withStatus: "Memeber removed")
            hapticFeedback(style: .success)
            
            Firestore.firestore().runTransaction { (transaction, errorPointer) -> Any? in
                let document: DocumentSnapshot
                do {
                    try document = transaction.getDocument(currentChannelReference)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                guard let oldFCMTokensMap = document.data()?["fcmTokens"] as? [String:String] else {
                   let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                           NSLocalizedDescriptionKey: "Unable to retrieve fcmTokens from snapshot \(document)"
                       ]
                   )
                   errorPointer?.pointee = error
                   return nil
                }
                var newFCMTokensMap = oldFCMTokensMap
                newFCMTokensMap.removeValue(forKey: memberID)
                transaction.updateData(["fcmTokens": newFCMTokensMap], forDocument: currentChannelReference)
                return nil
            } completion: { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                } else {
                    print("Transaction successfully committed!")
                }
            }

//            self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel?.name ?? "", participantIDs: [], text: "\(fellasName ?? "someone") has been removed from the event")
            
        
            self.reloadTable()
        }
    }
    
    // MARK: - Misc.
    
    func checkIfThereAreAnyElements(isEmpty: Bool) {
        guard isEmpty else {
            viewPlaceholder.remove(from: view, priority: .medium)
            return
        }
        viewPlaceholder.add(for: view, title: .nothingHere, subtitle: .nothingHere, priority: .medium, position: .top)
    }
    
    func reloadTable() {
        participantsContainerView.tableView.reloadData()
        
        switch (segmentedControlIndex) {
        case 0:
            if noResponseParticipants.count == 0 {
                checkIfThereAreAnyElements(isEmpty: true)
            } else {
                checkIfThereAreAnyElements(isEmpty: false)
            }
            break
        case 1:
            if maybeParticipants.count == 0 {
                checkIfThereAreAnyElements(isEmpty: true)
            } else {
                checkIfThereAreAnyElements(isEmpty: false)
            }
            break
        case 2:
            if goingParticipants.count == 0 {
                checkIfThereAreAnyElements(isEmpty: true)
            } else {
                checkIfThereAreAnyElements(isEmpty: false)
            }
            break
        case 3:
            if notGoingParticipants.count == 0 {
                checkIfThereAreAnyElements(isEmpty: true)
            } else {
                checkIfThereAreAnyElements(isEmpty: false)
            }
            break
        default: break }
    }

}

extension ParticipantsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (segmentedControlIndex) {
        case 0:
            return noResponseParticipants.count
        case 1:
            return maybeParticipants.count
        case 2:
            return goingParticipants.count
        case 3:
            return notGoingParticipants.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: userCellID) as? UserCell ?? UserCell(style: .subtitle, reuseIdentifier: userCellID)
        cell.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        
        guard let channelAdmins = channel?.admins else { return cell }
        
        switch (segmentedControlIndex) {
        case 0:
            if channelAdmins.contains(noResponseParticipants[indexPath.row].id ?? "") {
                cell.configureCell(for: indexPath, users: noResponseParticipants, admin: true)
            } else {
                cell.configureCell(for: indexPath, users: noResponseParticipants, admin: false)
            }
            break
        case 1:
            if channelAdmins.contains(maybeParticipants[indexPath.row].id ?? "") {
                cell.configureCell(for: indexPath, users: maybeParticipants, admin: true)
            } else {
                cell.configureCell(for: indexPath, users: maybeParticipants, admin: false)
            }
            break
        case 2:
            if channelAdmins.contains(goingParticipants[indexPath.row].id ?? "") {
                cell.configureCell(for: indexPath, users: goingParticipants, admin: true)
            } else {
                cell.configureCell(for: indexPath, users: goingParticipants, admin: false)
            }
            break
        case 3:
            if channelAdmins.contains(notGoingParticipants[indexPath.row].id ?? "") {
                cell.configureCell(for: indexPath, users: notGoingParticipants, admin: true)
            } else {
                cell.configureCell(for: indexPath, users: notGoingParticipants, admin: false)
            }
            break
        default: break }
        cell.accessoryView = .none
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    fileprivate func report(memberID: String, currentID: String) {
        Firestore.firestore().collection("reports").document().setData([
            "reportedBy": currentID,
            "reportedId": memberID,
            "reason": ""
        ])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hapticFeedback(style: .selectionChanged)
        if let cell = participantsContainerView.tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        var tmp: User?
        switch (segmentedControlIndex) {
            case 0: tmp = noResponseParticipants[indexPath.row]
            case 1: tmp = maybeParticipants[indexPath.row]
            case 2: tmp = goingParticipants[indexPath.row]
            case 3: tmp = notGoingParticipants[indexPath.row]
            default: break
        }
        
        guard let member = tmp, member.id != currentUserID else { return }
        
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(CustomAlertAction(title: "View profile", style: .default , handler: { [unowned self] in
            let destination = ParticipantProfileController()
            
            destination.member = member
            
            destination.userProfileContainerView.addPhotoLabel.isHidden = true
            navigationController?.pushViewController(destination, animated: true)
        }))
        
        guard let channelAdminIds = channel?.admins,
              let channelAuthor = channel?.author
        else { return }

        guard channelAdminIds.contains(currentUserID) else {
            self.present(alert, animated: true, completion: {})
            return
        }
        
        guard let memberID = member.id else { return }
        if memberID != currentUserID {
            if channelAdminIds.contains(memberID) {
                alert.addAction(CustomAlertAction(title: "Dismiss as Organizer", style: .default , handler: { [unowned self] in
                    if memberID == channelAuthor {
                        displayErrorAlert(title: "Not Allowed", message: "You cannot dismiss this person as admin because they created the event", preferredStyle: .alert, actionTitle: "Got it", controller: self)
                    } else {
                        self.removeAdmin(memberID: memberID)
                    }
                }))
            } else {
                alert.addAction(CustomAlertAction(title: "Make Organizer", style: .default , handler: { [weak self] in
                    self?.makeAdmin(memberID: memberID)
                }))
            }

            alert.addAction(CustomAlertAction(title: "Remove from event", style: .destructive , handler: { [unowned self] in


                let alert = CustomAlertController(title_: "Confirmation", message: "Are you sure you want to remove them from the event?", preferredStyle: .alert)
                alert.addAction(CustomAlertAction(title: "No", style: .default, handler: nil))
                alert.addAction(CustomAlertAction(title: "Yes", style: .destructive, handler: {
                    guard self.currentReachabilityStatus != .notReachable else {
                        basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
                        return
                    }
                    if memberID == channelAuthor && channelAdminIds.contains(memberID) {
                        displayErrorAlert(title: "Not Allowed", message: "You cannot remove this person because they created the channel", preferredStyle: .alert, actionTitle: "Got it", controller: self)
                    } else {
                        self.removeMember_(memberID: memberID)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            reloadTable()
        }
    }
    
}

extension ParticipantsController: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        self.segmentedControlIndex = index
        DispatchQueue.main.async { [weak self] in
            self?.reloadTable()
        }
    }
}
