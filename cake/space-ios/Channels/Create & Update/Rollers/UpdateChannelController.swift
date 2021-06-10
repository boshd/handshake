//
//  UpdateChannelController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-08.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class UpdateChannelController: CreateChannelController {
    
    var channel: Channel?
    
    // overriden vars
    override var newChannel: Channel? {
        didSet {
            print("newchannel init")
            checkDifference()
        }
    }
    
    override func createChannel() {
        print("updating channel")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateUpdatableProperties()
        
        configureTableView()
        configureNavigationBar()
    }
    
    override func configureNavigationBar() {
        title = "Edit event"
        
        let doneEditingButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(createChannel))
        navigationItem.rightBarButtonItem = doneEditingButton
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action: #selector(dismissController))
        dismissButton.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = dismissButton
    }
    
    func populateUpdatableProperties() {
        guard let channel = channel else { dismissController(); return }
        
        newChannel = Channel(value: channel)
        print("viewdidload")
        if let channelName = channel.name {
            self.channelName = channelName
        }
        
        if let locationName = channel.locationName {
            self.locationName = locationName
        }
        
        if let locationDescription = channel.locationDescription {
            self.locationDescription = locationDescription
        }
        
        if let latitude = channel.latitude.value, let longitude = channel.latitude.value {
            self.locationCoordinates = (latitude, longitude)
        }
        
        if let channelDescription = channel.description_ {
            self.channelDescription = channelDescription
        }
        
        if let startTime = channel.startTime.value, let endTime = channel.endTime.value {
            self.startTime = startTime
            self.endTime = endTime
            self.startDate = Date(timeIntervalSince1970: TimeInterval(startTime))
            self.endDate = Date(timeIntervalSince1970: TimeInterval(endTime))
        }
        
    }
    
    func checkDifference() {
        guard let channel = channel, let newChannel = newChannel else { dismissController(); return }
        
        if channel == newChannel {
            print("difference NOT observed")
        } else {
            print("difference observed")
            print(channel.name, newChannel.name)
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
}