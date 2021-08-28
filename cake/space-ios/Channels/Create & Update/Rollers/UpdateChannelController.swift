//
//  UpdateChannelController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-08.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class UpdateChannelController: CreateChannelController {
    
    var channel: Channel?
    
    override var isRemote: Bool {
        didSet {
            checkDifference()
        }
    }
    
    override var channelName: String? {
        didSet {
            checkDifference()
        }
    }
    
    override var channelDescription: String? {
        didSet {
            checkDifference()
        }
    }
    
    override var startTime: Int64? {
        didSet {
            checkDifference()
        }
    }
    
    override var endTime: Int64? {
        didSet {
            checkDifference()
        }
    }
    
    // overriden vars
    override var newChannel: Channel? {
        didSet {
            checkDifference()
        }
    }
    
    override var locationCoordinates: (Double, Double)? {
        didSet {
            checkDifference()
        }
    }
    
    override var locationName: String? {
        didSet {
            checkDifference()
        }
    }
    
    override var locationDescription: String? {
        didSet {
            checkDifference()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateUpdatableProperties()
        
        configureTableView()
        configureNavigationBar()
    }
    
    override func configureNavigationBar() {
        title = "Edit Event"
        
        let doneEditingButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        navigationItem.rightBarButtonItem = doneEditingButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action: #selector(dismissController))
        dismissButton.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = dismissButton
        
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationBar)
        }
    }
    
    func populateUpdatableProperties() {
        guard let channel = channel else { dismissController(); return }
        
        newChannel = Channel(value: channel)

        if let channelName = channel.name {
            self.channelName = channelName
        }
        
        if let isRemote = channel.isRemote.value {
            self.isRemote = isRemote
        }
        
        if let locationName = channel.locationName {
            self.locationName = locationName
        }
        
        if let locationDescription = channel.locationDescription {
            self.locationDescription = locationDescription
        }
        
        if let latitude = channel.latitude.value, let longitude = channel.longitude.value {
            self.locationCoordinates = (latitude, longitude)
        }
        
        if let channelDescription = channel.description_ {
            self.channelDescription = channelDescription
        }
        
        if let startTime = channel.startTime.value, let endTime = channel.endTime.value {
            self.startTime = startTime
            self.endTime = endTime
            self.startDateLocal = Date(timeIntervalSince1970: TimeInterval(startTime))
            self.endDateLocal = Date(timeIntervalSince1970: TimeInterval(endTime))
        }
        
    }
    
    func checkDifference() {
        guard let channel = channel else { dismissController(); return }
        
        if channel.isRemote.value != isRemote ||
            channel.name != channelName ||
            channel.description_ != channelDescription ||
            channel.startTime.value != startTime ||
            channel.endTime.value != endTime ||
            channel.latitude.value != locationCoordinates?.0 ||
            channel.longitude.value != locationCoordinates?.1 ||
            channel.locationName != locationName ||
            channel.locationDescription != locationDescription {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
    }
    
    func getPlacemark(with lat: Double, lon: Double, completion: @escaping([CLPlacemark]?)->()) {
        let location = CLLocation(latitude: lat, longitude: lon)
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: nil) { (placemarks: [CLPlacemark]?, error: Error?) in
            if error != nil {
                print(error ?? "error fetching location from coordinates")
            }
            completion(placemarks)
        }
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    override func configureDates() {
        dateFormatter.dateFormat = "MMMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
    }
    
    // MARK: - Updating
    
    override func doneAction() {
        guard let channelID = channel?.id, checkInputsAndReachability() else { return }
        resignFirstResponder()
        globalIndicator.show()

        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        
        /*
         
         "latitude": locationCoordinates?.0 as AnyObject,
         "longitude": locationCoordinates?.1 as AnyObject,
         "locationName": locationName as AnyObject,
         "locationDescription": locationDescription as AnyObject,
         
         */
        
        channelReference.updateData([
            "name": channelName as AnyObject,
            "isRemote": isRemote as AnyObject,
            
            "latitude": isRemote ? FieldValue.delete() : locationCoordinates?.0 as AnyObject,
            "longitude": isRemote ? FieldValue.delete() : locationCoordinates?.1 as AnyObject,
            "locationName": isRemote ? FieldValue.delete() : locationName as AnyObject,
            "locationDescription": isRemote ? FieldValue.delete() : locationDescription as AnyObject,
            
//            "locationName": isRemote ? FieldValue.delete() : channel?.locationName ?? "" as AnyObject,
//            "locationDescription": isRemote ? FieldValue.delete() : locationDescription ?? "" as AnyObject,
//            "latitude":  isRemote ? FieldValue.delete() : channel?.latitude ?? 0.0 as AnyObject,
//            "longitude": isRemote ? FieldValue.delete() : channel?.latitude ?? 0.0 as AnyObject,
            "startTime": startTime as AnyObject,
            "endTime": endTime as AnyObject,
            "description": channelDescription as AnyObject
        ]) { error in
            guard error == nil else {
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Something went wrong", preferredStyle: .alert, actionTitle: "Dismiss", controller: self)
                print(error?.localizedDescription ?? "error");
                globalIndicator.dismiss();
                return
            }
            globalIndicator.showSuccess(withStatus: "Event updated")
            hapticFeedback(style: .success)
            self.dismiss(animated: true, completion: nil)
        }

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
    
    // MARK: - Tableview
    
    override func constructHeaderCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelNameHeaderCellId, for: indexPath) as? ChannelNameHeaderCell ?? ChannelNameHeaderCell()
        cell.delegate = self
        
        if channelName != nil {
            cell.channelNameField.text = channelName
        }
        
        cell.channelNameDescriptionLabel.text = "Update event name. Max length of 25 characters."
        
        cell.channelImageView.removeFromSuperview()
        cell.channelImagePlaceholderLabel.removeFromSuperview()
        
        NSLayoutConstraint.activate([
            cell.channelNameField.topAnchor.constraint(equalTo: cell.topAnchor, constant: 15),
            cell.channelNameField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15),
            cell.channelNameField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -15),
            cell.channelNameDescriptionLabel.topAnchor.constraint(equalTo: cell.channelNameField.bottomAnchor, constant: 0),
            cell.channelNameDescriptionLabel.leadingAnchor.constraint(equalTo: cell.channelNameField.leadingAnchor, constant: 0),
            cell.channelNameDescriptionLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
            cell.channelNameDescriptionLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0)
//            cell.paddingView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0),
//            cell.paddingView.heightAnchor.constraint(equalToConstant: 5),
//            cell.paddingView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
//            cell.paddingView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
        ])
        
        return cell
    }
    
    override func returnHeaderHeight() -> CGFloat {
        return 80
    }
}
