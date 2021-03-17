//
//  ChannelOptionsViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-26.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Kingfisher
import DateTimePicker
import YPImagePicker
import SVProgressHUD
import FirebaseFirestore
import Firebase
import LocationPicker
import MapKit

enum ChannelOptionsMode {
    case admin
    case nonAdmin
}

protocol OptionsDelegate: class {
    func updatedTitle(title: String)
}

class ChannelOptionsViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UITextViewDelegate,
    UITextFieldDelegate,
    UIActionSheetDelegate,
    UIGestureRecognizerDelegate {
    
    var channelOptionsMode: ChannelOptionsMode = .nonAdmin
    var channel: Channel?
    
    var users = [User]()
    var image: UIImage?
    var ts: Timestamp?
    
    weak var delegate: OptionsDelegate?
    
    var placeholderLabel: UILabel!
    var indicator = SVProgressHUD.self
    
    var photoChanged = false
    var bioChanged = false
    var dateChanged = false
    var titleChanged = false
    
    private let cellId = "cellId"
    private let detailsCellID = "detailsCellID"
    
    let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .offWhite()
        imageView.clipsToBounds = true
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.layer.shadowColor = UIColor.thatPink().cgColor
        imageView.layer.shadowRadius = 10.0
        imageView.layer.shadowOpacity = 0.75
        imageView.layer.shadowOffset = CGSize(width: -2, height: 5)
        
        return imageView
    }()
    
    let imageButton: UIButton = {
        let imageButton = UIButton()
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.backgroundColor = .clear
//        imageButton.layer.cornerRadius = 65
        imageButton.clipsToBounds = true
        imageButton.addTarget(self, action: #selector(didTapImage), for: .touchUpInside)
        
        return imageButton
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        scrollView.isScrollEnabled = true
        scrollView.sizeToFit()
        
        return scrollView
    }()
    
    let collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: ScreenSize.height - 70, right: 0)
        layout.itemSize = CGSize(width: ScreenSize.width, height: 120)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        collectionView.isScrollEnabled = false
        
        return collectionView
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        
        return titleLabel
    }()
    
    let titleTextField: UITextField = {
        let titleTextField = UITextField()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        titleTextField.textAlignment = .center
        titleTextField.textColor = .black
        titleTextField.returnKeyType = .done
        titleTextField.sizeToFit()
        
        return titleTextField
    }()
    
    let bioTitle: UILabel = {
        let bioTitle = UILabel()
        bioTitle.translatesAutoresizingMaskIntoConstraints = false
        bioTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        bioTitle.textColor = .black
        bioTitle.textAlignment = .left
        bioTitle.text = "Description"
        
        return bioTitle
    }()

    let dateButton: UIButton = {
        let dateButton = UIButton(frame: .zero)
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.setTitle("Date and Time", for: .normal)
        dateButton.backgroundColor = .white
        dateButton.setTitleColor(.black, for: .normal)
        dateButton.contentHorizontalAlignment = .left
        dateButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        dateButton.addTarget(self, action: #selector(didTapDate), for: .touchUpInside)
        
        return dateButton
    }()
    
    let timeLabel: UILabel = {
        let timeLabel = UILabel(frame: .zero)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.backgroundColor = .white
        timeLabel.textColor = .black
        timeLabel.textAlignment = .left
        timeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        return timeLabel
    }()
    
    let seperator: UIView = {
        let seperator = UIView(frame: .zero)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .lighterGray()
        
        return seperator
    }()
    
    let optionSeperator: UIView = {
        let seperator = UIView(frame: .zero)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .lighterGray()
        
        return seperator
    }()
    
    /* Location View */
    
    let locationOptionView: UIView = {
        let optionView = UIView(frame: .zero)
        optionView.translatesAutoresizingMaskIntoConstraints = false
        optionView.backgroundColor = .white
        
        return optionView
    }()
    
    let locationOptionImageView: UIImageView = {
        let optionImageView = UIImageView(frame: .zero)
        optionImageView.translatesAutoresizingMaskIntoConstraints = false
        optionImageView.backgroundColor = .white
        optionImageView.layer.cornerRadius = 20
        optionImageView.image = UIImage(named: "pinn-1")
        
        return optionImageView
    }()
    
    let locationOptionButton: UIButton = {
        let optionButton = UIButton(frame: .zero)
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.setTitleColor(.offBlack(), for: .normal)
        optionButton.setTitle("Location", for: .normal)
        optionButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        optionButton.backgroundColor = .white
        optionButton.contentHorizontalAlignment = .left
        optionButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        
        return optionButton
    }()
    
    /* Bio View */
    
    let bioOptionView: UIView = {
        let optionView = UIView(frame: .zero)
        optionView.translatesAutoresizingMaskIntoConstraints = false
        optionView.backgroundColor = .white
        
        return optionView
    }()
    
    let bioOptionImageView: UIImageView = {
        let optionImageView = UIImageView(frame: .zero)
        optionImageView.translatesAutoresizingMaskIntoConstraints = false
        optionImageView.backgroundColor = .white
        optionImageView.layer.cornerRadius = 20
        optionImageView.image = UIImage(named: "edit")
        
        return optionImageView
    }()
    
    let bioOptionButton: UIButton = {
        let optionButton = UIButton(frame: .zero)
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.setTitleColor(.offBlack(), for: .normal)
        optionButton.setTitle("Description", for: .normal)
        optionButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        optionButton.backgroundColor = .white
        optionButton.contentHorizontalAlignment = .left
        
        return optionButton
    }()
    
    let bioView: UITextView = {
        let bioView = UITextView()
        bioView.translatesAutoresizingMaskIntoConstraints = false
        bioView.backgroundColor = .white
        bioView.font = UIFont(name: "HelveticaNeue", size: 14)
        bioView.tintColor = UIColor.thatPink()
        bioView.textColor = UIColor.offBlack()
        bioView.returnKeyType = .done
        bioView.textAlignment = .left
        bioView.sizeToFit()
        
        return bioView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        
        switch channelOptionsMode {
        case .admin:
            adminEditing()
        case .nonAdmin:
            nonAdminEditing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadAndSetChannelData()
    }
    
    fileprivate func adminEditing() {
        imageButton.isEnabled = true
        titleTextField.isEnabled = true
        dateButton.isEnabled = true
        bioView.isEditable = true
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(self.didTapDelete))
        delete.tintColor = .red
        delete.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15)!,
            NSAttributedString.Key.foregroundColor : UIColor.red,
        ], for: .normal)
        self.navigationItem.rightBarButtonItems = [delete]
    }
    
    fileprivate func nonAdminEditing() {
        imageButton.isEnabled = true
        titleTextField.isEnabled = false
        dateButton.isEnabled = false
        bioView.isEditable = false
    }
    
    func downloadAndSetChannelData() {
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        
        if let urlString = channel?.channelPhotoURL {
            guard let url = URL(string: urlString) else { return }
            ImageService.getImage(withUrl: url) { (image) in
                self.imageView.image = image
            }
        }
        
        if let title = channel?.channelName {
            titleTextField.text = title
        }
        
        if let bio = channel?.bio {
            bioView.text = bio
            
            let fixedWidth = bioView.frame.size.width
            bioView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = bioView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = bioView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            bioView.frame = newFrame
        }
        
        if let dateTs = channel?.dateTimestamp {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM d, YYYY"
            dateButton.setTitle(dateFormatter.string(from: dateTs.dateValue()), for: .normal)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeLabel.text = timeFormatter.string(from: dateTs.dateValue())
        }
        
        if let latitude = CLLocationDegrees(exactly: channel?.latitude ?? 0), let longitude = CLLocationDegrees(exactly: channel?.longitude ?? 0) {
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler:
                {
                    placemarks, error -> Void in
                    
                    guard let placeMark = placemarks?.first else { return }
                    
                    // Location name
                    if let locationName = placeMark.name, let street = placeMark.thoroughfare, let city = placeMark.administrativeArea, let country = placeMark.country {
                        self.locationOptionButton.setTitle("\(locationName), \(street), \(city), \(country)", for: .normal)
                    }
            })
        }
    }
    
    fileprivate func setupController() {
        hideKeyboardWhenTappedAround()
        
        bioView.delegate = self
        titleTextField.delegate = self
        
        view.backgroundColor = .white
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        collectionView.addGestureRecognizer(tapGestureRecognizer)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ParticipantsCell.self, forCellWithReuseIdentifier: cellId)
        
        navigationController?.navigationBar.backgroundColor = .white
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(imageButton)
        self.scrollView.addSubview(imageView)
        self.scrollView.addSubview(collectionView)
        self.scrollView.addSubview(dateButton)
        self.scrollView.addSubview(timeLabel)
        self.scrollView.addSubview(seperator)
        
        self.scrollView.addSubview(locationOptionView)
        self.locationOptionView.addSubview(locationOptionImageView)
        self.locationOptionView.addSubview(locationOptionButton)
        self.locationOptionView.addSubview(optionSeperator)
        
        self.scrollView.addSubview(bioOptionView)
        self.bioOptionView.addSubview(bioOptionImageView)
        self.bioOptionView.addSubview(bioView)
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        imageButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        imageButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        imageButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        imageButton.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        collectionView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        seperator.heightAnchor.constraint(equalToConstant: 5).isActive = true
        seperator.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        seperator.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        seperator.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 0).isActive = true
        
        dateButton.topAnchor.constraint(equalTo: seperator.bottomAnchor, constant: 10).isActive = true
        dateButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        dateButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dateButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: dateButton.bottomAnchor, constant: 5).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        locationOptionView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5).isActive = true
        locationOptionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        locationOptionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        locationOptionView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        locationOptionImageView.centerYAnchor.constraint(equalTo: locationOptionView.centerYAnchor, constant: 0).isActive = true
        locationOptionImageView.leadingAnchor.constraint(equalTo: locationOptionView.leadingAnchor, constant: 20).isActive = true
        locationOptionImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        locationOptionImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        locationOptionButton.centerYAnchor.constraint(equalTo: locationOptionView.centerYAnchor, constant: 0).isActive = true
        locationOptionButton.leadingAnchor.constraint(equalTo: locationOptionImageView.trailingAnchor, constant: 10).isActive = true
        locationOptionButton.trailingAnchor.constraint(equalTo: locationOptionView.trailingAnchor, constant: -10).isActive = true
        locationOptionButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        optionSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        optionSeperator.leadingAnchor.constraint(equalTo: locationOptionView.leadingAnchor, constant: 0).isActive = true
        optionSeperator.trailingAnchor.constraint(equalTo: locationOptionView.trailingAnchor, constant: 0).isActive = true
        optionSeperator.bottomAnchor.constraint(equalTo: locationOptionView.bottomAnchor, constant: 0).isActive = true

        bioOptionView.topAnchor.constraint(equalTo: locationOptionView.bottomAnchor, constant: 0).isActive = true
        bioOptionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        bioOptionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        bioOptionView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        bioOptionImageView.topAnchor.constraint(equalTo: bioOptionView.topAnchor, constant: 10).isActive = true
        bioOptionImageView.leadingAnchor.constraint(equalTo: bioOptionView.leadingAnchor, constant: 20).isActive = true
        bioOptionImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        bioOptionImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        bioView.topAnchor.constraint(equalTo: bioOptionView.topAnchor, constant: 5).isActive = true
        bioView.leadingAnchor.constraint(equalTo: bioOptionImageView.trailingAnchor, constant: 5).isActive = true
        bioView.trailingAnchor.constraint(equalTo: bioOptionView.trailingAnchor, constant: -20).isActive = true
        bioView.heightAnchor.constraint(greaterThanOrEqualToConstant: 85).isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let backBTN = UIBarButtonItem(image: UIImage(named: "ctrl-left"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        backBTN.tintColor = .black
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        let destination = ChannelParticipantsTableViewController()
        
        destination.users = self.users
        destination.channelOptionsMode = self.channelOptionsMode
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.bioChanged = true
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.bioChanged = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.indicator.show()
        self.view.isUserInteractionEnabled = false
        
        guard let channelID = self.channel?.channelID else { return }
        
        Firestore.firestore().collection("channels").document(channelID).updateData([
            "channelName": textField.text as Any
        ], completion: { (error) in
            if error != nil {
                print("error // ", error!.localizedDescription)
                displayAlert(title: "ERROR", message: "Couldn't Edit Title", preferredStyle: UIAlertController.Style.alert, actionTitle: "OK", controller: self)
                self.indicator.dismiss()
                self.view.isUserInteractionEnabled = true
                return
            }
            
            self.delegate?.updatedTitle(title: textField.text!)
            
            self.indicator.dismiss()
            self.view.isUserInteractionEnabled = true
        })
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.indicator.show()
        self.view.isUserInteractionEnabled = false
        
        guard let channelID = self.channel?.channelID else { return }
        
        Firestore.firestore().collection("channels").document(channelID).updateData([
            "bio": textView.text as Any
            ], completion: { (error) in
                if error != nil {
                    print("error // ", error!.localizedDescription)
                    displayAlert(title: "ERROR", message: "Couldn't Edit Bio", preferredStyle: UIAlertController.Style.alert, actionTitle: "OK", controller: self)
                    self.indicator.dismiss()
                    self.view.isUserInteractionEnabled = true
                    return
                }
                self.indicator.dismiss()
                self.view.isUserInteractionEnabled = true
        })
    }
    
    func openMapForPlace(latitude: Double, longitude: Double) {
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Place Name"
        mapItem.openInMaps(launchOptions: options)
    }
    
    @objc func didTapLocation() {
        
        let lat = channel?.latitude
        let lon = channel?.longitude
        
        var adminActions: [(String, UIAlertAction.Style)] = []
        var nonAdminActions: [(String, UIAlertAction.Style)] = []
        
        switch channelOptionsMode {
        case .admin:
            adminActions.append(("View in Maps", UIAlertAction.Style.default))
            adminActions.append(("Change Location", UIAlertAction.Style.default))
            adminActions.append(("Dismiss", UIAlertAction.Style.cancel))
            Alerts.showActionsheet(viewController: self, title: "Event Location", message: "Event Location Options", actions: adminActions) { (index) in
                print("call action \(index)")
                if index == 0 {
                    self.openMapForPlace(latitude: lat ?? 0, longitude: lon ?? 0)
                } else if index == 1 {
                    let locationPicker = LocationPickerViewController()
                    locationPicker.completion = { selectedLocationItem in
                        let geoCoder = CLGeocoder()
                        guard let location = selectedLocationItem?.location else {
                            return
                        }
                        geoCoder.reverseGeocodeLocation(location, completionHandler:
                            {
                                placemarks, error -> Void in
                                
                                guard let placeMark = placemarks?.first else { return }
                                
                                if let locationName = placeMark.name, let country = placeMark.country {
                                    self.locationOptionButton.setTitle("\(locationName), \(country)", for: .normal)
                                    
                                    guard let channelID = self.channel?.channelID else { return }
                                    Firestore.firestore().collection("channels").document(channelID).updateData([
                                        "latitude": selectedLocationItem?.coordinate.latitude as Any,
                                        "longitude": selectedLocationItem?.coordinate.longitude as Any
                                        ], completion: { (error) in
                                            if error != nil {
                                                print("error // ", error!.localizedDescription)
                                                displayAlert(title: "ERROR", message: "Couldn't Edit Location", preferredStyle: UIAlertController.Style.alert, actionTitle: "OK", controller: self)
                                                self.indicator.dismiss()
                                                return
                                            }
                                            self.indicator.dismiss()
                                    })
                                    
                                }
                        })
                        
                    }
                    self.navigationController!.pushViewController(locationPicker, animated: true)
                } else {
                    
                }
            }
        case .nonAdmin:
            nonAdminActions.append(("View in Maps", UIAlertAction.Style.default))
            nonAdminActions.append(("Dismiss", UIAlertAction.Style.cancel))
            Alerts.showActionsheet(viewController: self, title: "Event Location", message: "Event Location Options", actions: nonAdminActions) { (index) in
                if index == 0 {
                    self.openMapForPlace(latitude: lat ?? 0, longitude: lon ?? 0)
                } else if index == 1 {
                    
                }
            }
        }
        
    }
    
    @objc func didTapDate() {
        switch channelOptionsMode {
        case .admin:
            let picker = DateTimePicker.create()
            picker.is12HourFormat = true
            picker.includeMonth = true
            picker.highlightColor = UIColor.black
            picker.darkColor = UIColor.black
            picker.doneButtonTitle = "Done"
            picker.doneBackgroundColor = .black
            picker.completionHandler = { date in
                
                self.indicator.show()
                
                let ts = Timestamp(date: date)
                self.ts = ts
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMMM d, YYYY"
                self.dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                self.timeLabel.text = timeFormatter.string(from: date)
                
                self.dateChanged = true
                
                guard let channelID = self.channel?.channelID else { return }
                
                Firestore.firestore().collection("channels").document(channelID).updateData([
                    "dateTimestamp": self.ts as Any
                    ], completion: { (error) in
                        if error != nil {
                            print("error // ", error!.localizedDescription)
                            displayAlert(title: "ERROR", message: "Couldn't Edit Date", preferredStyle: UIAlertController.Style.alert, actionTitle: "OK", controller: self)
                            self.indicator.dismiss()
                            self.dateChanged = false
                            return
                        }
                        self.indicator.dismiss()
                        self.dateChanged = false
                })
                
            }
            picker.show()
        case .nonAdmin:
            print("Do nothing.")
        }
    }
    
    @objc func didTapImage() {
        var actions: [(String, UIAlertAction.Style)] = []
        
        switch channelOptionsMode {
        case .admin:
            actions.append(("View Image", UIAlertAction.Style.default))
            actions.append(("Change Image", UIAlertAction.Style.default))
            actions.append(("Dismiss", UIAlertAction.Style.cancel))
            Alerts.showActionsheet(viewController: self, title: "Event Photo", message: "Event Photo Options", actions: actions) { (index) in
                print("call action \(index)")
                if index == 0 {
                    print("VIEW IMAGE")
                } else if index == 1 {
                    let picker = YPImagePicker()
                    picker.didFinishPicking { [unowned picker] items, _ in
                        if let photo = items.singlePhoto {
                            self.indicator.show()
                            self.view.isUserInteractionEnabled = false
                            
                            self.imageView.image = photo.image
                            self.image = photo.image
                            self.imageButton.setTitle("", for: .normal)
                            self.photoChanged = true
                            
                            guard let channelID = self.channel?.channelID else { return }
                            guard let image = self.image else { return }
                            guard let imageData = image.jpegData(compressionQuality: 0.25) else { return }
                            let storageManager = StorageManager()
                            storageManager.uploadTheData(imageData, named: "channelPhoto") { (url, error) in
                                if error != nil {
                                    print("error // ", error!.localizedDescription)
                                    self.indicator.dismiss()
                                    self.view.isUserInteractionEnabled = true
                                    displayAlert(title: "ERROR", message: "Couldn't Edit Photo", preferredStyle: UIAlertController.Style.alert, actionTitle: "OK", controller: self)
                                    self.photoChanged = false
                                    return
                                }
                                
                                Firestore.firestore().collection("channels").document(channelID).updateData([
                                    "channelPhotoURL": url?.absoluteString as Any
                                    ], completion: { (error) in
                                        if error != nil {
                                            print("error // ", error!.localizedDescription)
                                            self.indicator.dismiss()
                                            self.view.isUserInteractionEnabled = true
                                            displayAlert(title: "ERROR", message: "Couldn't Edit Photo", preferredStyle: UIAlertController.Style.alert, actionTitle: "OK", controller: self)
                                            self.photoChanged = false
                                            return
                                        }
                                        self.indicator.dismiss()
                                        self.view.isUserInteractionEnabled = true
                                        self.photoChanged = false
                                })
                                self.view.isUserInteractionEnabled = true
                                self.indicator.dismiss()
                            }
                            
                        }
                        picker.dismiss(animated: true, completion: nil)
                    }
                    self.present(picker, animated: true, completion: nil)
                } else {
                    
                }
            }
        case .nonAdmin:
            actions.append(("View Image", UIAlertAction.Style.default))
            actions.append(("Dismiss", UIAlertAction.Style.cancel))
            Alerts.showActionsheet(viewController: self, title: "Event Photo", message: "Event Photo Options", actions: actions) { (index) in
                print("call action \(index)")
                if index == 0 {
                    print("VIEW IMAGE")
                } else {
                    
                }
            }
        }

    }
    
    @objc func didTapDelete() {
        let deleteAlert = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle yes logic here")
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle no Logic here")
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ParticipantsCell
        cell.users = self.users
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if (parent == nil) {
            delegate?.updatedTitle(title: "Sdsdsdd")
        }
    }
    
}
