//
//  UpdateChannelController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import SVProgressHUD
import MapKit
import Firebase

protocol UpdateChannelDelegate: class {
    func channel(doneUpdatinigChannel: Bool)
}

class UpdateChannelController: UITableViewController {
    
    var delegate: UpdateChannelDelegate?
    
    let createChannelHeaderCellId = "createChannelHeaderCell"
    let createChannelCellId = "createChannelCell"
    let descriptionCellId = "descriptionCellId"
    let datePickerCellId = "datePickerCellId"
    let specialSwitchCellId = "specialSwitchCellId"
    
    var users = [User]()

    var firstVirtual = true
    var isVirtual: Bool? {
        didSet {
            if firstVirtual {
                firstVirtual = false
                return
            }
            if oldValue != isVirtual {
                updateVirtuality()
                navBarButtonChannelVirtuality()
            }
        }
    }
    var firstPictureDidSet = true
    var selectedImage: UIImage? {
        didSet {
            if channel?.imageUrl == nil && firstPictureDidSet {
                firstPictureDidSet = false
                return
            }
            if oldValue != selectedImage {
                imageDidUpdate()
            }
        }
    }
    var firstChannelName = true
    var channelName: String? {
        didSet {
            if firstChannelName {
                firstChannelName = false
                return
            }
            if oldValue != channelName {
                updateName()
                navBarButtonChannelName()
            }
        }
    }
    var firstChannelStarttime = true
    var startTime: Int? {
        didSet {
            if firstChannelStarttime {
                firstChannelStarttime = false
                return
            }
            if oldValue != startTime {
                updateStartTime()
                navBarButtonChannelStartTime()
            }
        }
    }
    var firstChannelEndtime = true
    var endTime: Int? {
        didSet {
            if firstChannelEndtime {
                firstChannelEndtime = false
                return
            }
            if oldValue != endTime {
                updateEndTime()
                navBarButtonChannelEndTime()
            }
        }
    }
    var firstChannelLocation = true
    var location: (Double, Double)? {
        didSet {
            if firstChannelLocation {
                firstChannelLocation = false
                return
            }
            if oldValue?.0 != location?.0 && oldValue?.1 != location?.1 {
                updateLocation()
                navBarButtonChannelLocation()
            }
        }
    }
    var firstChannelDescription = true
    var channelDescription: String? {
        didSet {
            if firstChannelDescription {
                firstChannelDescription = false
                return
            }
            if oldValue != channelDescription {
                updateDescription()
                navBarButtonChannelDescription()
            }
        }
    }
    var firstLocationName = true
    var locationName: String? {
        didSet {
            if firstLocationName {
                firstLocationName = false
                return
            }
            if oldValue != locationName {
                updateLocationName()
            }
        }
    }
    var firstLocationSubtitle = true
    var locationSubtitle: String? {
        didSet {
            if firstLocationSubtitle {
                firstLocationSubtitle = false
                return
            }
            if oldValue != locationSubtitle {
                updateLocationSubtitle()
            }
        }
    }
    
    var imageUpdated = false
    var channel: Channel?
    var channelReference: DocumentReference?
    var selectedImageOwningCellIndexPath: IndexPath?

    let avatarOpener = AvatarOpener()
    let informationMessageSender = InformationMessageSender()
    let channelUpdatingGroup = DispatchGroup()
    var batchUpdate = Firestore.firestore().batch()
    let channelValidator = ChannelValidator()
    
    // MARK: - Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupController()
        setupNavigationbar()
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Controller Setup & Configuration
    
    fileprivate func setupController() {
        guard let channelID = channel?.id else { return }
        hideKeyboardWhenTappedAround()
        channelReference = Firestore.firestore().collection("channels").document(channelID)
    }
    
    fileprivate func setupNavigationbar() {
        title = "Edit event"
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = cancelButtonItem
        
        let doneEditingButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(updateChannel))
        navigationItem.rightBarButtonItem = doneEditingButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.register(CreateChannelHeaderCell.self, forCellReuseIdentifier: createChannelHeaderCellId)
        tableView.register(CreateChannelCell.self, forCellReuseIdentifier: createChannelCellId)
        tableView.register(DescriptionCell.self, forCellReuseIdentifier: descriptionCellId)
        tableView.register(SpecialSwitchCell.self, forCellReuseIdentifier: specialSwitchCellId)
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: datePickerCellId)
        tableView.keyboardDismissMode = .onDrag
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
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
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
        navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - Navigation
    
    @objc func goBack() {
        hapticFeedback(style: .impact)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Validation
    
    fileprivate func datesAreGood(start: Int, end: Int) -> Bool {
        if start > end {
            return false
        }
        return true
    }
    
    // MARK: - Misc.
    fileprivate func somethingUpdated() {}
    
}

// MARK: - Channel Updating

extension UpdateChannelController {
    
    @objc
    func updateChannel() {
        guard let channelReference = channelReference else { return }
        guard currentReachabilityStatus != .notReachable else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: noInternetError, preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
            return
        }
        
        if let isVirtual = isVirtual, isVirtual {
            print("isVirtual")
            if location != nil {
                location = nil
            }
            
            if locationName != nil {
                locationName = nil
            }
        } else {
            print("not Virtual")
            guard location != nil && locationName != "" else {
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Please provide a location for the event", preferredStyle: .alert, actionTitle: "Got it", controller: self)
                return
            }
        }
        
        resignFirstResponder()
        
        globalIndicator.show()
        channelUpdatingGroup.enter()
        if imageUpdated {
            channelUpdatingGroup.enter()
            uploadImage(reference: channelReference, image: selectedImage)
        }
        
        batchUpdate.commit { [unowned self] (error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                globalIndicator.showError(withStatus: "Failed")
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Could not update channel", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                return
            }
            channelUpdatingGroup.leave()
        }
        
        channelUpdatingGroup.notify(queue: DispatchQueue.main) { [weak self] in
            self?.delegate?.channel(doneUpdatinigChannel: true)
            hapticFeedback(style: .success)
            globalIndicator.showSuccess(withStatus: "Done!")
            self?.informationMessageSender.sendInformationMessage(channelID: channelReference.documentID, channelName: self?.channelName ?? "", participantIDs: [], text: "Event details have been changed", channel: self?.channel)
            self?.navigationController?.popViewController(animated: true)
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
                    self.channelUpdatingGroup.leave()
                    return
                }
                self.channelUpdatingGroup.leave()
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
            self.channelUpdatingGroup.leave()
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

}

// MARK: - Channel updating

extension UpdateChannelController {
    
    fileprivate func batchUpdateHelper(_ data: [String: AnyObject]) {
        guard let channelReference = channelReference else { return }
        batchUpdate.updateData(data, forDocument: channelReference)
    }
    
    fileprivate func updateName() {
        guard let channelName = channelName, channelValidator.isChannelNameGood(name: channelName) else {
            basicErrorAlert(errorMessage: emptyChannelName, controller: self)
            return
        }
        batchUpdateHelper(["name": channelName.trimmingCharacters(in: .whitespaces) as AnyObject])
    }
    
    fileprivate func updateDescription() {
        batchUpdateHelper(["description": channelDescription?.trimmingCharacters(in: .whitespaces) as AnyObject])
    }
    
    fileprivate func updateStartTime() {
        guard let start = startTime, let end = endTime, channelValidator.areDatesValid(start: start, end: end) else {
            basicErrorAlert(errorMessage: datesError, controller: self)
            return
        }
        batchUpdateHelper(["startTime": startTime as AnyObject])
    }
    
    fileprivate func updateEndTime() {

        guard let start = startTime, let end = endTime, channelValidator.areDatesValid(start: start, end: end) else {
            basicErrorAlert(errorMessage: datesError, controller: self)
            return
        }
        batchUpdateHelper(["endTime": endTime as AnyObject])
    }
    
    fileprivate func updateLocation() {
        batchUpdateHelper([
            "latitude": location?.0 as AnyObject,
            "longitude": location?.1 as AnyObject,
            "locationName": locationName as AnyObject,
            "locationSubtitle": locationSubtitle as AnyObject
        ])
    }
    
    fileprivate func updateLocationName() {
        batchUpdateHelper([
            "locationName": locationName as AnyObject
        ])
    }
    
    fileprivate func updateLocationSubtitle() {
        batchUpdateHelper([
            "locationSubtitle": locationSubtitle as AnyObject
        ])
    }
    
    fileprivate func updateVirtuality() {
        batchUpdateHelper(["isVirtual": isVirtual as AnyObject])
    }
    
    fileprivate func imageDidUpdate() {
        imageUpdated = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
}

extension UpdateChannelController {
    func navBarButtonChannelName() {
        if channelName != channel?.name {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func navBarButtonChannelDescription() {
        if channelDescription != channel?.description_ {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func navBarButtonChannelLocation() {
        if location?.0 != channel?.latitude.value && location?.1 != channel?.latitude.value {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func navBarButtonChannelStartTime() {
        if startTime ?? 0 != (channel?.startTime.value)! {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func navBarButtonChannelEndTime() {
        if endTime ?? 0 != (channel?.endTime.value)! {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func navBarButtonChannelVirtuality() {
        if isVirtual != channel?.isVirtual.value {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

}
