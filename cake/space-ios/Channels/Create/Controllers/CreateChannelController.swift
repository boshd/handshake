//
//  CreateChannelTableViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-04.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import SVProgressHUD
import MapKit
import Firebase

protocol CreateChannelDelegate: class {
    func channel(doneUpdatinigChannel: Bool)
}

class CreateChannelController: UITableViewController {
    
    var createChannelDelegate: CreateChannelDelegate?
    
    let createChannelHeaderCellId = "createChannelHeaderCell"
    let createChannelCellId = "createChannelCell"
    let descriptionCellId = "descriptionCellId"
    let datePickerCellId = "datePickerCellId"
    let specialSwitchCellId = "specialSwitchCellId"
    
    var selectedRowIndex = -1
    
//    var isVirtual = false

    var isVirtual: Bool = false {
        didSet {
            updateVirtuality(); channelDataUpdated()
        }
    }
    
    var users = [User]()
    
    var channelId: String?
    var first = true
    var selectedImage: UIImage? {
        didSet {
            if first {
                first = false
                return
            }
            
            if isInChannelEditing { imageDidUpdate(); channelDataUpdated() }
        }
    }
    
    var channelName: String? {
        didSet {
            if isInChannelEditing { updateName(); channelDataUpdated() }
        }
    }
    var startTime: Int? {
        didSet {
            if isInChannelEditing { updateStartTime(); channelDataUpdated() }
        }
    }
    var endTime: Int? {
        didSet {
            if isInChannelEditing { updateEndTime(); channelDataUpdated() }
        }
    }
    var location: (Double, Double)? {
        didSet {
            if isInChannelEditing { updateLocation(); channelDataUpdated() }
        }
    }
    var channelDescription: String? {
        didSet {
            if isInChannelEditing { updateDescription(); channelDataUpdated() }
        }
    }
    var locationName: String? {
        didSet {
            if isInChannelEditing { channelDataUpdated() }
        }
    }
    
    var editingHappened = false
    
    private func channelDataUpdated() {
        editingHappened = true
        if let enabled = navigationItem.rightBarButtonItem?.isEnabled, !enabled {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = ThemeManager.currentTheme().tintColor
        }
    }
    
    var selectedUsers = [User]()
    
    var isInChannelEditing = false
    
    
    var selectedImageOwningCellIndexPath: IndexPath?

    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    let avatarOpener = AvatarOpener()
    
    let channelCreatingGroup = DispatchGroup()
    let informationMessageSender = InformationMessageSender()
    
    var indicator = SVProgressHUD.self
    
    var datesSection = [(title: "Starting", secondaryTitle: "", type: "date"),
                        (title: "Ending", secondaryTitle: "", type: "date")]
    
    var mainSection = [(title: "Description", secondaryTitle: "", type: "description")]
    
    // MARK: - Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationbar()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
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
    
    // MARK: - Controller Setup & Configuration
    
    @objc private func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        tableView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationBar)
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func setupController() {
        users = RealmKeychain.realmUsersArray()
        hideKeyboardWhenTappedAround()
        indicator.setDefaultMaskType(.clear)
    }
    
    fileprivate func setupNavigationbar() {
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = cancelButtonItem
        
        if isInChannelEditing {
            let doneEditingButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(updateChannel))
            navigationItem.rightBarButtonItem = doneEditingButton
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .lightText
        } else {
            let createButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createChannel))
            navigationItem.rightBarButtonItem = createButton
        }
        
        
        if !isInChannelEditing {
            title = selectedUsers.count == 1 ? "1 friend selected" : "\(selectedUsers.count) friends selected"
        }
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
//        tableView.allowsSelection = false
        tableView.register(CreateChannelHeaderCell.self, forCellReuseIdentifier: createChannelHeaderCellId)
        tableView.register(CreateChannelCell.self, forCellReuseIdentifier: createChannelCellId)
        tableView.register(DescriptionCell.self, forCellReuseIdentifier: descriptionCellId)
        tableView.register(SpecialSwitchCell.self, forCellReuseIdentifier: specialSwitchCellId)
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: datePickerCellId)
        tableView.keyboardDismissMode = .onDrag
    }
    
    // MARK: - Cell Selection Handlers
    
    @objc func addLocationPressed() {
        let destination = MapController()
        destination.mapControllerDelegate = self
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func addDescriptionPressed() {
        let destination = DescriptionViewController()
        destination.descriptionDelegate = self
        if channelDescription != nil {
            destination.textView.text = channelDescription
        }
        destination.view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - Misc. & Navigation
    
    @objc func goBack() {
        hapticFeedback(style: .impact)
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func displayErrorAlertf(with title: String, message: String) {
        displayErrorAlert(title: title, message: message, preferredStyle: .alert, actionTitle: "OK", controller: self)
        globalIndicator.dismiss()
    }
    
    fileprivate func datesAreGood(start: Int, end: Int) -> Bool {
        if start > end {
            return false
        }
        return true
    }
    
    fileprivate func checkInputsAndReachability() -> Bool {
        guard currentReachabilityStatus != .notReachable else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
            return false
        }
        
        if startTime == nil {
            startTime = Int(Date().nextHour.timeIntervalSince1970)
        }
        
        if endTime == nil {
            guard let oneHourInFutureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date().nextHour) else { return false }
            endTime = Int(oneHourInFutureDate.timeIntervalSince1970)
        }
        
        guard let start = startTime, let end = endTime, datesAreGood(start: start, end: end) else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: datesError, preferredStyle: .alert, actionTitle: "Got it", controller: self)
            return false
        }
        guard let channelName = channelName, !channelName.trimmingCharacters(in: .whitespaces).isEmpty else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: "Please provide a name for the event", preferredStyle: .alert, actionTitle: "Got it", controller: self)
            return false
        }
        
        if isVirtual {
            if location != nil {
                location = nil
            }
            
            if locationName != nil {
                locationName = nil
            }
        } else {
            guard locationName != nil else {
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Please provide a location for the event", preferredStyle: .alert, actionTitle: "Got it", controller: self)
                return false
            }
        }
        
        return true
    }
    let batchUpdate = Firestore.firestore().batch()
    var imageUpdated = false
    var localChannelData = [String:AnyObject]()
}

// MARK: - Channel Creation

extension CreateChannelController {
    
    
    
    @objc
    func createChannel() {
//        self.channelName = String(Date().timeIntervalSince1970)
//        location = (0.0, 0.0)
//        locationName = "Random famous location"
        
        guard let currentUserID = Auth.auth().currentUser?.uid, checkInputsAndReachability() else { return }
        resignFirstResponder()
        globalIndicator.show()

        let memberIDs = fetchMemeberIDs()
        let channelsReference = Firestore.firestore().collection("channels")
        let newChannelReference = channelsReference.document()

        let channelData = [
            "id": newChannelReference.documentID as AnyObject,
            "name": channelName?.trimmingCharacters(in: .whitespaces) as AnyObject,
            "participantIds": memberIDs.0  as AnyObject,
            "author": currentUserID as AnyObject,
            "authorName": globalCurrentUser?.name as AnyObject,
            "admins": [currentUserID] as AnyObject,
            "description": channelDescription?.trimmingCharacters(in: .whitespaces) as AnyObject,
            "createdAt": NSNumber(value: Int(Date().timeIntervalSince1970)) as AnyObject,
            "startTime": startTime as AnyObject,
            "endTime": endTime as AnyObject,
            "latitude": location?.0 as AnyObject,
            "longitude": location?.1 as AnyObject,
            "locationName": locationName as AnyObject,
            "maybeIds": memberIDs.0 as AnyObject,
            "isCancelled": false as AnyObject,
            "isVirtual": isVirtual as AnyObject
        ]
        
        localChannelData = channelData

        channelCreatingGroup.enter()
        channelCreatingGroup.enter()
        channelCreatingGroup.enter()
        fetchAndUpdateMemeberFCMTokens(reference: newChannelReference)
        createChannelAndConnectMembersToChannelNode(newChannelReference: newChannelReference, channelData: channelData, participantIDs: memberIDs.0)
        uploadImage(reference: newChannelReference, image: selectedImage)
        
        channelCreatingGroup.notify(queue: DispatchQueue.main) { [weak self] in
            hapticFeedback(style: .success)
            
//            if let localChannelData = localChannelData {
            self?.informationMessageSender.sendInformationMessage(channelID: newChannelReference.documentID, channelName: self?.channelName ?? "", participantIDs: memberIDs.0, text: "New event has been created. Discuss and share ideas here.", channel: Channel(dictionary: self?.localChannelData))
//            }
            
            self?.dismiss(animated: true, completion: nil)
            globalIndicator.dismiss()
        }

    }
    
    func createChannelAndConnectMembersToChannelNode(newChannelReference: DocumentReference, channelData: [String: AnyObject], participantIDs: [String]) {
        guard Auth.auth().currentUser != nil else { channelCreatingGroup.leave(); return }
        globalIndicator.show()
        let batch = Firestore.firestore().batch()
        let usersCollectionReference = Firestore.firestore().collection("users")

        batch.setData(channelData, forDocument: newChannelReference)
        for participantID in participantIDs {
            batch.setData(["participantId":participantID], forDocument: newChannelReference.collection("participantIds").document(participantID))
            batch.setData([
                "channelId": newChannelReference.documentID
            ], forDocument: usersCollectionReference.document(participantID).collection("channelIds").document(newChannelReference.documentID))
        }
        
        batch.commit { [unowned self] (error) in
            channelCreatingGroup.leave()
            if error != nil {
                print("\(error?.localizedDescription ?? "error")")
                displayErrorAlert(title: basicErrorTitleForAlert, message: genericOperationError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
        }
    }
    
    func uploadImage(reference: DocumentReference, image: UIImage?) {
        guard let image = selectedImage else {
            reference.updateData([
                "imageUrl": "",
                "thumbnailImageUrl": ""
            ]) { (error) in
                if error != nil {
                    print("error // ", error?.localizedDescription as Any)
                    self.channelCreatingGroup.leave()
                    return
                }
                self.channelCreatingGroup.leave()
            }
            return
        }
        
        let thumbnailImage = createImageThumbnail(image)
        var images = [(image: UIImage, quality: CGFloat, key: String)]()
        images.append((image: image, quality: 0.5, key: "imageUrl"))
        images.append((image: thumbnailImage, quality: 1, key: "thumbnailImageUrl"))
        let photoUpdatingGroup = DispatchGroup()
        for _ in images { photoUpdatingGroup.enter() }
        
        photoUpdatingGroup.notify(queue: DispatchQueue.main, execute: {
            self.channelCreatingGroup.leave()
        })
        
        for imageElement in images {
            uploadImageForChannelToFirebaseStorageUsingImage(imageElement.image, quality: imageElement.quality) { (url) in
                reference.updateData([
                    imageElement.key: url
                ]) { (error) in
                    if error != nil {
                        print("error // ", error?.localizedDescription as Any)
                        photoUpdatingGroup.leave()
                        return
                    }
                    photoUpdatingGroup.leave()
                }
            }
        }
    }
    
    func fetchAndUpdateMemeberFCMTokens(reference: DocumentReference) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        var membersFCMTokensDict = [String:String]()
        let fcmFetchingGroup = DispatchGroup()
        
        for _ in selectedUsers { fcmFetchingGroup.enter() }
        
        fcmFetchingGroup.notify(queue: DispatchQueue.main, execute: {
            reference.updateData(["fcmTokens": membersFCMTokensDict]) { [weak self] (error) in
                self?.localChannelData["fcmTokens"] = membersFCMTokensDict as AnyObject
                self?.channelCreatingGroup.leave()
            }
        })
        membersFCMTokensDict[currentUserID] = userDefaults.currentStringObjectState(for: userDefaults.fcmToken)
        for selectedUser in selectedUsers {
            guard let userId = selectedUser.id else { continue }
            Firestore.firestore().collection("fcmTokens").document(userId).getDocument { (snapshot, error) in
                fcmFetchingGroup.leave()
                guard let fcmDict = snapshot?.data(), let fcmToken = fcmDict["fcmToken"] as? String else { return }
                membersFCMTokensDict[userId] = fcmToken
            }
        }
    }
    
//    typealias UpdateUserProfileCompletionHandler = (_ success: Bool) -> Void
//    func fetchMemeberFCMTokens_(completion: @escaping (_ fcmTokenMap: [String:String]) -> Void) {
//        var membersFCMTokensDict = [String:String]()
//        let fcmFetchingGroup = DispatchGroup()
//
//        guard let currentUserID = Auth.auth().currentUser?.uid else { completion(membersFCMTokensDict) }
//
//        membersFCMTokensDict[currentUserID] = userDefaults.currentStringObjectState(for: userDefaults.fcmToken)
//        fcmFetchingGroup.enter()
//        for selectedUser in selectedUsers {
//            guard let userId = selectedUser.id else { continue }
//            Firestore.firestore().collection("fcmTokens").document(userId).getDocument { (snapshot, error) in
//                fcmFetchingGroup.leave()
//                guard let fcmDict = snapshot?.data(), let fcmToken = fcmDict["fcmToken"] as? String else { return }
//                membersFCMTokensDict[userId] = fcmToken
//            }
//        }
//
//        fcmFetchingGroup.notify(queue: .global(qos: .userInteractive)) {
//            completion(membersFCMTokensDict)
//        }
//
////        return membersFCMTokensDict
//
//    }
    
    func fetchMemeberIDs() -> ([String], [String: AnyObject]) {
        var membersIDs = [String]()
        var membersIDsDictionary = [String: AnyObject]()
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return (membersIDs, membersIDsDictionary) }
        
        membersIDsDictionary.updateValue(currentUserID as AnyObject, forKey: currentUserID)
        membersIDs.append(currentUserID)
        
        for selectedUser in selectedUsers {
            guard let id = selectedUser.id else { continue }
            membersIDsDictionary.updateValue(id as AnyObject, forKey: id)
            membersIDs.append(id)
        }
        
        return (membersIDs, membersIDsDictionary)
    }
    
}

// MARK: - Channel updating

extension CreateChannelController {
    // we will break up each update operation and perform
    // a batch update in the end if values changed
    
    fileprivate func updateName() {
        print("update name")
        guard let channelID = channelId else { return }
        
        guard let channelName = channelName, !channelName.trimmingCharacters(in: .whitespaces).isEmpty else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: "Please provide a name for the event", preferredStyle: .alert, actionTitle: "Got it", controller: self)
            return
        }
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        
        batchUpdate.updateData([
            "name": channelName as AnyObject
        ], forDocument: channelReference)
    }
    
    fileprivate func updateDescription() {
        guard let channelID = channelId else { return }
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        print("update description")
        batchUpdate.updateData([
            "description": channelDescription as AnyObject
        ], forDocument: channelReference)
    }
    
    fileprivate func updateStartTime() {
        guard let channelID = channelId else { return }

        guard let start = startTime, let end = endTime, datesAreGood(start: start, end: end) else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: datesError, preferredStyle: .alert, actionTitle: "Got it", controller: self)
            return
        }
        
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        print("update start time")
        batchUpdate.updateData([
            "startTime": startTime as AnyObject
        ], forDocument: channelReference)
    }
    
    fileprivate func updateEndTime() {
        guard let channelID = channelId else { return }

        guard let start = startTime, let end = endTime, datesAreGood(start: start, end: end) else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: datesError, preferredStyle: .alert, actionTitle: "Got it", controller: self)
            return
        }
        
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        print("update end time")
        batchUpdate.updateData([
            "endTime": endTime as AnyObject
        ], forDocument: channelReference)
    }
    
    fileprivate func updateLocation() {
        guard let channelID = channelId, !isVirtual else { return }
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        print("update location")
        batchUpdate.updateData([
            "latitude": location?.0 as AnyObject,
            "longitude": location?.1 as AnyObject,
            "locationName": locationName as AnyObject
        ], forDocument: channelReference)
    }
    
    fileprivate func updateVirtuality() {
        guard let channelID = channelId, !isVirtual else { return }
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        print("update virtuality")
        batchUpdate.updateData([
            "isVirtual": isVirtual as AnyObject
        ], forDocument: channelReference)
    }
    
    
    fileprivate func imageDidUpdate() {
        print("update image")
        imageUpdated = true
    }
    
    @objc
    func updateChannel() {
        guard let channelID = channelId, editingHappened else { return }
        
        guard currentReachabilityStatus != .notReachable else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
            return
        }
        
        resignFirstResponder()
        
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        
        globalIndicator.show()
        channelCreatingGroup.enter()
        
        if imageUpdated {
            channelCreatingGroup.enter()
            uploadImage(reference: channelReference, image: selectedImage)
        }
        
        batchUpdate.commit { [unowned self] (error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                globalIndicator.showError(withStatus: "Failed")
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Could not update channel", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            channelCreatingGroup.leave()
        }
        
        
        
        
        channelCreatingGroup.notify(queue: DispatchQueue.main) {
            self.createChannelDelegate?.channel(doneUpdatinigChannel: true)
            hapticFeedback(style: .success)
            globalIndicator.showSuccess(withStatus: "Done!")
//            self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: self.channelName ?? "", participantIDs: [], text: "Event details have been changed", channel: channel)
        }
       
    }
}

extension CreateChannelController: MapControllerDelegate {
    func didUpdateSelectedLocation(with updatedLocation: MKAnnotation?) {
        guard let location_ = updatedLocation else { return }
        location = (location_.coordinate.latitude, location_.coordinate.longitude)

        if let name = location_.title, let title = name {
            locationName = title
            //mainSection[0] = (title: "Event location", secondaryTitle: title, type: "location")
            //if let s = location_.subtitle, let secondary = s {
                //mainSection[0] = (title: title, secondaryTitle: secondary, type: "location")
            //}
        }
        tableView.reloadData()
    }
}
