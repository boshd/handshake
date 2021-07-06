//
//  CreateChannelController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-08.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class CreateChannelController: UITableViewController {

    var channelName: String?
    var startTime: Int64?
    var endTime: Int64?
    
    var locationCoordinates: (Double, Double)?
    var locationName: String?
    var locationDescription: String?
    var mapItem: MKMapItem?
    
    var location: Location?
    
    var newChannel: Channel?
    
    var channelDescription: String?
    var selectedImage: UIImage?
    
    // for local use
    var startDate: Date?
    var endDate: Date?
    
    var selectedUsers = [User]()
    
    var secondSection = [
        "Remote",
        "Location"
    ]
    
    var thirdSection = [
        "Starts",
        "Ends"
    ]
    var fourthSection = [
        "Description"
    ]
    
    var datePickerIndexPath: IndexPath?
    var selectedImageOwningCellIndexPath: IndexPath?
    
    let channelNameHeaderCellId = "channelNameHeaderCellId"
    let datePickerCellId = "datePickerCellId"
    let dateCellId = "dateCellId"
    let locationCellId = "locationCellId"
    let selectLocationCellId = "selectLocationCellId"
    let specialSwitchCellId = "specialSwitchCellId"
    let descriptionCellId = "descriptionCellId"
    
    var datePickerVisible = false
    var expandPicker = false
    
    let timeFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    let avatarOpener = AvatarOpener()
    let batchUpdate = Firestore.firestore().batch()
    var localChannelData = [String:AnyObject]()
    let channelCreatingGroup = DispatchGroup()
    let informationMessageSender = InformationMessageSender()
    
    var isRemote = false
    
    // MARK: - Controller life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Controller setup/config.
    
    override init(style: UITableView.Style) {
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTableView() {
        configureDates()
        
        tableView.register(ChannelNameHeaderCell.self, forCellReuseIdentifier: channelNameHeaderCellId)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: datePickerCellId)
        tableView.register(DateCell.self, forCellReuseIdentifier: dateCellId)
        tableView.register(LocationCell.self, forCellReuseIdentifier: locationCellId)
        tableView.register(SpecialSwitchCell.self, forCellReuseIdentifier: specialSwitchCellId)
        tableView.register(SelectLocationCell.self, forCellReuseIdentifier: selectLocationCellId)
        tableView.register(DescriptionCell.self, forCellReuseIdentifier: descriptionCellId)
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        // tableView.keyboardDismissMode = .onDrag
    }
    
    func configureDates() {
        dateFormatter.dateFormat = "MMMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
        
        let nearestHour = Date().nearestHour()
        startTime = Int64(nearestHour.timeIntervalSince1970)
        endTime = Int64(nearestHour.nextHour.timeIntervalSince1970)
    }
    
    func configureNavigationBar() {
        title = "New event"
        let createButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createChannel))
        createButton.tintColor = ThemeManager.currentTheme().tintColor
        navigationItem.rightBarButtonItem = createButton
    }
    
    // MARK: - Date Picker Logic
    
    fileprivate func showDatePicker(at indexPath: IndexPath) {
        self.tableView.beginUpdates()
        self.datePickerIndexPath = indexPath
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.endUpdates()
    }
    
    fileprivate func hideDatePicker(at indexPath: IndexPath) {
        self.tableView.beginUpdates()
        self.datePickerIndexPath = nil
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.endUpdates()
    }
    
    // MARK: - Helper Methods
    
    fileprivate func checkInputsAndReachability() -> Bool {
        
        func datesAreGood(start: Int64, end: Int64) -> Bool {
            if start > end {
                return false
            }
            return true
        }
        
        guard currentReachabilityStatus != .notReachable else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
            return false
        }

        guard let start = startTime, let end = endTime, datesAreGood(start: start, end: end) else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: datesError, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return false
        }
        guard let channelName = channelName, !channelName.trimmingCharacters(in: .whitespaces).isEmpty else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: "Please provide a name for the event", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return false
        }

        if isRemote {
            if locationCoordinates != nil {
                locationCoordinates = nil
            }
            
            if locationName != nil {
                locationName = nil
            }
        } else {
            guard locationName != nil else {
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Please provide a location for the event", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return false
            }
        }

        return true
    }
    
    func constructHeaderCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelNameHeaderCellId, for: indexPath) as? ChannelNameHeaderCell ?? ChannelNameHeaderCell()
        cell.delegate = self
        
        if channelName != nil {
            cell.channelNameField.text = channelName
        }
        
        if selectedImage != nil {
            cell.channelImageView.image = selectedImage
            cell.channelImagePlaceholderLabel.isHidden = true
        } else {
            cell.channelImagePlaceholderLabel.isHidden = false
        }
        
        return cell
    }
    
}

// MARK: - Channel Creation

extension CreateChannelController {
   
    @objc
    func createChannel() {

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
            "latitude": locationCoordinates?.0 as AnyObject,
            "longitude": locationCoordinates?.1 as AnyObject,
            "locationName": locationName as AnyObject,
            "locationDescription": locationDescription as AnyObject,
            "maybeIds": memberIDs.0 as AnyObject,
            "isCancelled": false as AnyObject,
            "isRemote": isRemote as AnyObject
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
        let batch = Firestore.firestore().batch()
        let usersCollectionReference = Firestore.firestore().collection("users")

        batch.setData(channelData, forDocument: newChannelReference)
        for participantID in participantIDs {
            batch.setData(["participantId":participantID], forDocument: newChannelReference.collection("participantIds").document(participantID), merge: true)
            batch.setData([
                "id": newChannelReference.documentID
            ], forDocument: usersCollectionReference.document(participantID).collection("channelIds").document(newChannelReference.documentID), merge: true)
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
//            reference.updateData([:]) { [weak self] (error) in
//                self?.channelCreatingGroup.leave()
//                if error != nil {
//                    print("error // ", error?.localizedDescription as Any)
//                    return
//                }
//            }
            self.channelCreatingGroup.leave()
            return
        }
        
        let imageUploadingGroup = DispatchGroup()

        let thumbnailImage = createImageThumbnail(image)
        var images = [(image: UIImage, quality: CGFloat, key: String)]()
        images.append((image: image, quality: 0.5, key: "imageUrl"))
        images.append((image: thumbnailImage, quality: 1, key: "thumbnailImageUrl"))
        
        // guard let image = images.first else { channelCreatingGroup.leave(); return }
        
        for image in images {
            imageUploadingGroup.enter()
            uploadImageForChannelToFirebaseStorageUsingImage(image.image, quality: image.quality) { (url) in
                reference.updateData([
                    image.key: url
                ]) { (error) in
                    imageUploadingGroup.leave()
                    if error != nil {
                        print("error // ", error?.localizedDescription as Any)
                        return
                    }
                }
            }
        }
        
        imageUploadingGroup.notify(queue: .main, execute: {
            self.channelCreatingGroup.leave()
        })
        
        
    }

    func fetchAndUpdateMemeberFCMTokens(reference: DocumentReference) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        var membersFCMTokensDict = [String:String]()
        let fcmFetchingGroup = DispatchGroup()

        for _ in selectedUsers { fcmFetchingGroup.enter() }

        fcmFetchingGroup.notify(queue: DispatchQueue.main, execute: {
            self.channelCreatingGroup.leave()
            reference.updateData(["fcmTokens": membersFCMTokensDict]) { [weak self] (error) in
                self?.localChannelData["fcmTokens"] = membersFCMTokensDict as AnyObject
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


// MARK: - All-things Table-view

extension CreateChannelController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let startTime = startTime, let endTime = endTime {
            startDate = Date(timeIntervalSince1970: TimeInterval(startTime))
            endDate = Date(timeIntervalSince1970: TimeInterval(endTime))
        }
        
        if indexPath.section == 0 {
            return constructHeaderCell(indexPath: indexPath)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: specialSwitchCellId, for: indexPath) as? SpecialSwitchCell ?? SpecialSwitchCell()
                cell.textLabel?.text = secondSection[0]
                // cell.detailTextLabel?.text = "Plan a remote event. Share any details in the description below."
                
                cell.switchAccessory.isOn = isRemote
                cell.switchTapAction = { isOn in
                    DispatchQueue.main.async { [weak self] in
                        self?.isRemote = isOn
                        if isOn {
                            self?.tableView.beginUpdates()
                            self?.tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
                            self?.tableView.endUpdates()
                        } else {
                            self?.tableView.beginUpdates()
                            self?.tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
                            self?.tableView.endUpdates()
                        }
                    }
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: selectLocationCellId, for: indexPath) as? SelectLocationCell ?? SelectLocationCell()
                cell.textLabel?.text = locationName != nil ? location?.name : secondSection[1]
                
                    
                
                if location != nil { cell.detailTextLabel?.text = location?.locationDescription }
                return cell
            }
        } else if indexPath.section == 2 {
            if let datePickerIndexPathRow = datePickerIndexPath?.row, datePickerIndexPath != nil && datePickerIndexPathRow + 1 == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: datePickerCellId, for: indexPath) as? DatePickerCell ?? DatePickerCell()
                return cell
            } else if indexPath.row == 1 || indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: datePickerCellId, for: indexPath) as? DatePickerCell ?? DatePickerCell()

                if let startDate = startDate, let endDate = endDate {
                    if indexPath.row == 1 {
                        cell.datePicker.date = startDate
                    } else if indexPath.row == 3 {
                        cell.datePicker.minimumDate = startDate
                        cell.datePicker.date = endDate
                    }
                }

                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: dateCellId, for: indexPath) as? DateCell ?? DateCell()
                cell.textLabel?.text = indexPath.row == 0 ? thirdSection[0] : thirdSection[1]
                if let startDate = startDate, let endDate = endDate {
                    let startDateString = dateFormatter.string(from: startDate)
                    let endDateString = dateFormatter.string(from: endDate)
                    
                    if indexPath.row == 0 {
                        cell.dateLabel.text = dateFormatter.string(from: startDate)
                        cell.timeLabel.text = timeFormatter.string(from: startDate)
                    } else if indexPath.row == 2 {
                        cell.timeLabel.text = timeFormatter.string(from: endDate)
                        cell.dateLabel.text = startDateString == endDateString ? "" : dateFormatter.string(from: endDate)
                    }
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: descriptionCellId, for: indexPath) as? DescriptionCell ?? DescriptionCell()
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.textView.text = fourthSection[0]
            if let channelDescription = channelDescription {
                cell.textView.text = channelDescription
            }
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                return 50
            } else {
                return UITableView.automaticDimension
            }
        } else if indexPath.section == 2 {
            if let datePickerIndexPathRow = datePickerIndexPath?.row, datePickerIndexPath != nil && datePickerIndexPathRow + 1 == indexPath.row {
                return DatePickerCell().datePickerHeight
            } else if indexPath.row == 1 || indexPath.row == 3 {
                return 0
            } else {
                return 50
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return isRemote ? 1 : secondSection.count
        } else if section == 2 {
            return 4
            // return datePickerIndexPath != nil ? thirdSection.count + 1 : thirdSection.count
        } else {
            return fourthSection.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundSecondaryColor
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 0 ? 15 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                let destination = LocationSearchController()
                destination.modalPresentationStyle = .formSheet
                destination.delegate = self
                // tableView.deselectRow(at: indexPath, animated: true)
                present(destination, animated: true, completion: nil)
            }
        } else if indexPath.section == 2 {
            if datePickerIndexPath != nil {
                // something is already expanded, therefore we should collapse
                hideDatePicker(at: indexPath)
            } else {
                // nothing is expanded, therefore expand
                showDatePicker(at: indexPath)
            }
        }
    }
    
}

extension CreateChannelController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//         ddd
    }
}
