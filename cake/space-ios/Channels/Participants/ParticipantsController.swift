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
    
    var goingParticipants: [User]?
    var maybeParticipants: [User]?
    var notGoingParticipants: [User]?
    var admin: Bool?
    var channel: Channel?
    
    var channelsReference: CollectionReference?
    var usersReference: CollectionReference?
    var currentChannelReference: DocumentReference?
    
    var channelListener: ListenerRegistration?
    
    private var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate!
    
    var participants: [User]?
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
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        participantsContainerView.tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        participantsContainerView.tableView.sectionIndexBackgroundColor = view.backgroundColor
        participantsContainerView.tableView.backgroundColor = view.backgroundColor
        participantsContainerView.tableView.isOpaque = true
//        participantsContainerView.interfaceSegmented.textColor = ThemeManager.currentTheme().generalTitleColor
        participantsContainerView.setColors()
        DispatchQueue.main.async { [weak self] in
            self?.participantsContainerView.tableView.reloadData()
        }
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reConfigureCurrentUser), name: .currentUserDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleMemberRemoved), name: .memberRemoved, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelUpdate), name: .channelUpdated, object: nil)
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
        goingParticipants = participants?.filter({ channel.goingIds.contains($0.id ?? "") })
        maybeParticipants = participants?.filter({ channel.maybeIds.contains($0.id ?? "") })
        notGoingParticipants = participants?.filter({ channel.notGoingIds.contains($0.id ?? "") })
        
        var goingTitle = "Going"
        var maybeTitle = "Maybe"
        var notGoingTitle = "Not going"
        
        if goingParticipants?.count != 0 {
            goingTitle += " (\(goingParticipants?.count ?? 0))"
        }
        if maybeParticipants?.count != 0 {
            maybeTitle += " (\(maybeParticipants?.count ?? 0))"
        }
        if notGoingParticipants?.count != 0 {
            notGoingTitle += " (\(notGoingParticipants?.count ?? 0))"
        }
        
        
        
        participantsContainerView.interfaceSegmented.setButtonTitles(buttonTitles: [maybeTitle, goingTitle, notGoingTitle])
        reloadTable()
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.title = "Attendees"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action:  #selector(goBack))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        guard let currentUserID = Auth.auth().currentUser?.uid, let channelAdminIDs = channel?.admins else { return }
        
        guard let channel = channel,
              let state = channelState(channel: channel),
              let cancelled = channel.isCancelled.value
        else { return }

        if channelAdminIDs.contains(currentUserID), !cancelled, state != .Past {
            let addMemberButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action:  #selector(addMember))
            addMemberButton.tintColor = .black
            navigationItem.rightBarButtonItem = addMemberButton
        }
    }
    
    // MARK: - @objc methods
    
    @objc func goBack() {
        hapticFeedback(style: .impact)
        navigationController?.popViewController(animated: true)
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
        
        guard let status = channel?.updateAndReturnStatus() else { return }
        
        if status == .inProgress || status == .expired || status == .cancelled {
            displayErrorAlert(title: basicErrorTitleForAlert, message: cannotDoThisState, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
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
            
            
            if let newAdminName = self.participants?.filter({ $0.id == memberID }).first?.name {
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel?.name ?? "", participantIDs: [], text: "\(newAdminName) has been dismissed as admin", channel: channel)
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

            if let newAdminName = self.participants?.filter({ $0.id == memberID }).first?.name {
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel?.name ?? "", participantIDs: [], text: "\(newAdminName) has been made admin", channel: channel)
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
        
        let fellasName = self.participants?.filter({ $0.id == memberID }).first?.name
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
        // checkIfThereAreAnyElements(isEmpty: true)
        participantsContainerView.tableView.reloadData()
        
        switch (segmentedControlIndex) {
        case 0:
            if maybeParticipants?.count == 0 {
                checkIfThereAreAnyElements(isEmpty: true)
            } else {
                checkIfThereAreAnyElements(isEmpty: false)
            }
            break
        case 1:
            if goingParticipants?.count == 0 {
                checkIfThereAreAnyElements(isEmpty: true)
            } else {
                checkIfThereAreAnyElements(isEmpty: false)
            }
            break
        case 2:
            if notGoingParticipants?.count == 0 {
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
            return maybeParticipants?.count ?? 0
        case 1:
            return goingParticipants?.count ?? 0
        case 2:
            return notGoingParticipants?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: userCellID, for: indexPath) as? UserCell ?? UserCell(style: .subtitle, reuseIdentifier: userCellID)
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: userCellID) as? UserCell ?? UserCell(style: .subtitle, reuseIdentifier: userCellID)
        
        
        guard let going = goingParticipants, let maybe = maybeParticipants, let notGoing = notGoingParticipants, let channelAdmins = channel?.admins else { return cell }
        
        switch (segmentedControlIndex) {
        case 0:
            if channelAdmins.contains(maybe[indexPath.row].id ?? "") {
                cell.configureCell(for: indexPath, users: maybe, admin: true)
            } else {
                cell.configureCell(for: indexPath, users: maybe, admin: false)
            }
            break
        case 1:
            if channelAdmins.contains(going[indexPath.row].id ?? "") {
                cell.configureCell(for: indexPath, users: going, admin: true)
            } else {
                cell.configureCell(for: indexPath, users: going, admin: false)
            }
            break
        case 2:
            if channelAdmins.contains(notGoing[indexPath.row].id ?? "") {
                cell.configureCell(for: indexPath, users: notGoing, admin: true)
            } else {
                cell.configureCell(for: indexPath, users: notGoing, admin: false)
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
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let maybeParticipants = maybeParticipants,
              let goingParticipants = goingParticipants,
              let notGoingParticipants  = notGoingParticipants
        else { return }
        
        var tmp: User?
        switch (segmentedControlIndex) {
            case 0: tmp = maybeParticipants[indexPath.row]
            case 1: tmp = goingParticipants[indexPath.row]
            case 2: tmp = notGoingParticipants[indexPath.row]
            default: break
        }
        
        guard let member = tmp, member.id != currentUserID else { return }
        
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(CustomAlertAction(title: "View profile", style: .default , handler: { [unowned self] in
            let destination = ParticipantProfileController()
            
            destination.member = member
            
//            destination.userProfileContainerView.profileImageView.isUserInteractionEnabled = false
            destination.userProfileContainerView.addPhotoLabel.isHidden = true
            navigationController?.pushViewController(destination, animated: true)
        }))
        
        guard let channel = channel,
              let state = channelState(channel: channel),
              let cancelled = channel.isCancelled.value
        else { return }

        guard channel.admins.contains(currentUserID), !cancelled, state != .Past else {
            self.present(alert, animated: true, completion: {})
            return
        }
        
        guard let memberID = member.id else { return }
        if memberID != currentUserID {
            if channel.admins.contains(memberID) {
                alert.addAction(CustomAlertAction(title: "Dismiss as admin", style: .default , handler: { [unowned self] in
                    if memberID == channel.author {
                        displayErrorAlert(title: "Not Allowed", message: "You cannot dismiss this person as admin because they created the event", preferredStyle: .alert, actionTitle: "Got it", controller: self)
                    } else {
                        self.removeAdmin(memberID: memberID)
                    }
                }))
            } else {
                alert.addAction(CustomAlertAction(title: "Make admin", style: .default , handler: { [weak self] in
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
                    if memberID == channel.author && channel.admins.contains(memberID) {
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
