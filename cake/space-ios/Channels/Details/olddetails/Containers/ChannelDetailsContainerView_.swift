////
////  ChannelDetailsContainerView.swift
////  space-ios
////
////  Created by Kareem Arab on 2019-11-24.
////  Copyright © 2019 Kareem Arab. All rights reserved.
////
//
//import UIKit
//import MapKit
//import SVProgressHUD
//
//class ChannelDetailsContainerView: UIView {
//    
//    let ind = SVProgressHUD.self
//    
//    var scrollView: UIScrollView = {
//        var scrollView = UIScrollView(frame: .zero)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.backgroundColor = .clear
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.clipsToBounds = true
//        scrollView.scrollsToTop = false
//        
//        return scrollView
//    }()
//    
//    var rsvpView: UIView = {
//        var view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isUserInteractionEnabled = true
//        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
//        return view
//    }()
//    
//    var rsvpButton: InteractiveButton = {
//        var button = InteractiveButton()
//        button.scaler = 0.95
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = ThemeManager.currentTheme().buttonColor
//        button.setTitle("RSVP", for: .normal)
//        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 16)
//        button.titleLabel?.textColor = ThemeManager.currentTheme().buttonTextColor
//        button.layer.cornerRadius = 25
//        button.layer.cornerCurve = .continuous
//        
//        return button
//    }()
//    
//    var channelImageView: UIImageView = {
//        var channelImageView = UIImageView(frame: .zero)
//        channelImageView.translatesAutoresizingMaskIntoConstraints = false
//        channelImageView.backgroundColor = .clear
//        channelImageView.contentMode = .scaleAspectFill
//        channelImageView.layer.masksToBounds = true
//        channelImageView.isUserInteractionEnabled = true
//        channelImageView.layer.cornerRadius = 0
//        
//        return channelImageView
//    }()
//    
//    var startEndTimesLabel: DynamicLabel = {
//        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .left
//        label.textColor = .black
//        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
//        label.text = "FRI, DEC 19TH - MON, DEC 27TH"
//        return label
//    }()
//    
//    let channelName: UILabel = {
//        var label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .clear
//        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 25)
//        label.textColor = ThemeManager.currentTheme().generalTitleColor
//        label.tintColor = .black
//        label.numberOfLines = 0
//        
//        return label
//    }()
//    
//    let dateTimeCaptionLabel: DynamicLabel = {
//        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 16)
//        label.textColor = ThemeManager.currentTheme().generalTitleColor
//        label.sizeToFit()
//        label.textAlignment = .left
//        label.backgroundColor = .clear
//        label.text = "Date & Time"
//        
//        return label
//    }()
//    
//    let eventStatus: DynamicLabel = {
//        let label = DynamicLabel(withInsets: 2, 2, 3, 3)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = .priorityGreen()
//        label.backgroundColor = .greenEventStatusBackground()
//        label.textAlignment = .right
//        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 11)
//        label.cornerRadius = 3
//        label.text = "In progress"
//        
//        return label
//    }()
//    
//    var startingLabel: DynamicLabel = {
//        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = ThemeManager.currentTheme().generalTitleColor
//        label.textAlignment = .left
//        label.layer.masksToBounds = true
//        label.font = ThemeManager.currentTheme().secondaryFont(with: 11)
//        label.text = "Starts at 9 PM & ends 8 PM"
//        
//        return label
//    }()
//    
//    var addToCalendarButton: UIButton = {
//        var button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.masksToBounds = true
//        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBoldItalic(with: 10)
//        button.setTitle("Add to calendar", for: .normal)
//        button.cornerRadius = 5
//        button.backgroundColor = .black
//        button.setTitleColor(.white, for: .normal)
//        
//        return button
//    }()
//
//    var participantsCaptionLabel: DynamicLabel = {
//        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 16)
//        label.textColor = ThemeManager.currentTheme().generalTitleColor
//        label.sizeToFit()
//        label.textAlignment = .left
//        label.backgroundColor = .clear
//        
//        return label
//    }()
//    
//    var participantsDetailsLabel: DynamicLabel = {
//        let label = DynamicLabel(withInsets: 2, 2, 2, 2)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
//        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
//        label.text = "and 15 other people"
//
//        return label
//    }()
//
//    var participantsCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = -15
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//        
//        return collectionView
//    }()
//    
//    var descriptionCaptionLabel: DynamicLabel = {
//        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 16)
//        label.textColor = ThemeManager.currentTheme().generalTitleColor
//        label.sizeToFit()
//        label.textAlignment = .left
//        label.text = "About"
//        label.backgroundColor = .clear
//        
//        return label
//    }()
//    
//    var descriptionTextView: BioTextView = {
//        let bio = BioTextView()
//        bio.translatesAutoresizingMaskIntoConstraints = false
//        bio.textAlignment = .left
//        bio.font = ThemeManager.currentTheme().secondaryFont(with: 12)
//        bio.isScrollEnabled = false
//        bio.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
//        bio.backgroundColor = .clear
//        bio.textColor = .gray
//        bio.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
//        bio.layer.borderColor = UIColor.nude().cgColor
//        bio.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
//        bio.textContainer.lineBreakMode = .byTruncatingTail
//        bio.returnKeyType = .done
//        bio.textContainerInset = UIEdgeInsets.zero
//        bio.textContainer.lineFragmentPadding = 0
//        bio.isUserInteractionEnabled = false
//
//        bio.isEditable = false
//        bio.isScrollEnabled = false
//        bio.isUserInteractionEnabled = true
//        bio.isSelectable =  true
//        
//        bio.dataDetectorTypes = .all
//        bio.linkTextAttributes = [
//            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
//            NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 12)
//        ]
//        
//        return bio
//    }()
//    
//    let bioPlaceholderLabel: UILabel = {
//      let bioPlaceholderLabel = UILabel()
//      bioPlaceholderLabel.text = "Empty description"
//      bioPlaceholderLabel.sizeToFit()
//      bioPlaceholderLabel.textAlignment = .left
//      bioPlaceholderLabel.backgroundColor = .clear
//      bioPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
//      bioPlaceholderLabel.font = ThemeManager.currentTheme().secondaryFont(with: 12)
//      bioPlaceholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
//
//      return bioPlaceholderLabel
//    }()
//    
//    var eventTypeCaptionLabel: DynamicLabel = {
//        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 16)
//        label.textColor = ThemeManager.currentTheme().generalTitleColor
//        label.sizeToFit()
//        label.textAlignment = .left
//        label.text = "How to get there"
//        label.backgroundColor = .clear
//        
//        return label
//    }()
//    
//    var locationCaptionDetailsLabel: DynamicLabel = {
//        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
//        label.textColor = ThemeManager.currentTheme().generalTitleColor
//        label.sizeToFit()
//        label.numberOfLines = 0
//        label.textAlignment = .left
//        label.text = "Description of event details. Only admins can edit by directly interracting with the text."
//        label.backgroundColor = .clear
//        
//        return label
//    }()
//    
//    var footerLabel: DynamicLabel = {
//        let footerLabel = DynamicLabel(withInsets: 2, 2, 2, 2)
//        footerLabel.translatesAutoresizingMaskIntoConstraints = false
//        footerLabel.font = ThemeManager.currentTheme().secondaryFont(with: 11)
//        footerLabel.textColor = .gray
//        
//        return footerLabel
//    }()
//    
//    var footerSubLabel: DynamicLabel = {
//        let footerSubLabel = DynamicLabel(withInsets: 2, 2, 2, 2)
//        footerSubLabel.translatesAutoresizingMaskIntoConstraints = false
//        footerSubLabel.font = ThemeManager.currentTheme().secondaryFont(with: 11)
//        footerSubLabel.textColor = .gray
//
//        return footerSubLabel
//    }()
//    
//    var deleteAndExitButton: UIButton = {
//        var button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = .priorityRed()
//        button.setTitle("Delete and exit", for: .normal)
//        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 13)
//        button.titleLabel?.textColor = ThemeManager.currentTheme().buttonIconColor
//        button.layer.cornerRadius = 0
//        
//        return button
//    }()
//    
//    var overlayView: BlurView = {
//        var view = BlurView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear
////        view.borderColor = .nude()
////        view.blurTintColor = .white
////        view.borderWidth = 3
//        view.isUserInteractionEnabled = false
//        view.cornerRadius = 15
//        
//        return view
//    }()
//    
//    var remoteEventLabel: DynamicLabel = {
//        let label = DynamicLabel(withInsets: 2, 2, 2, 2)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 16)
//        label.textColor = .gray
//        label.text = "Remote event"
//
//        return label
//    }()
//    
//    var locationView = LocationView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        ind.setDefaultMaskType(.clear)
//        ind.setDefaultStyle(.light)
//        ind.setFont(ThemeManager.currentTheme().secondaryFontBoldItalic(with: 12))
//        ind.setHapticsEnabled(true)
//        
//        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//
//        addSubview(scrollView)
//        addSubview(rsvpView)
//        rsvpView.addSubview(rsvpButton)
////        channelImageView.addSubview(eventStatus)
//        scrollView.addSubview(channelImageView)
//        scrollView.addSubview(channelName)
////        scrollView.addSubview(startEndTimesLabel)
//        scrollView.addSubview(dateTimeCaptionLabel)
//        scrollView.addSubview(participantsCaptionLabel)
//        scrollView.addSubview(participantsCollectionView)
//        scrollView.addSubview(descriptionCaptionLabel)
//        scrollView.addSubview(descriptionTextView)
//        scrollView.addSubview(eventTypeCaptionLabel)
//        scrollView.addSubview(locationView)
//        scrollView.addSubview(footerLabel)
//        scrollView.addSubview(footerSubLabel)
//        descriptionTextView.addSubview(bioPlaceholderLabel)
//        bringSubviewToFront(rsvpView)
//        
//        NSLayoutConstraint.activate([
//            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//            
//            rsvpView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//            rsvpView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//            rsvpView.heightAnchor.constraint(equalToConstant: 120),
//            rsvpView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//            
//            rsvpButton.topAnchor.constraint(equalTo: rsvpView.topAnchor, constant: 10),
//            rsvpButton.leadingAnchor.constraint(equalTo: rsvpView.leadingAnchor, constant: 15),
//            rsvpButton.trailingAnchor.constraint(equalTo: rsvpView.trailingAnchor, constant: -15),
//            rsvpButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            channelImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
//            channelImageView.heightAnchor.constraint(equalToConstant: 250),
//            channelImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            channelImageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
//            
////            eventStatus.topAnchor.constraint(equalTo: channelImageView.topAnchor, constant: 15),
//            
////            startEndTimesLabel.topAnchor.constraint(equalTo: channelImageView.bottomAnchor, constant: 13),
////            startEndTimesLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0),
////            startEndTimesLabel.widthAnchor.constraint(equalTo: channelImageView.widthAnchor, constant: -40),
////
//            channelName.topAnchor.constraint(equalTo: channelImageView.bottomAnchor, constant: 15),
//            channelName.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0),
//            channelName.widthAnchor.constraint(equalTo: channelImageView.widthAnchor, constant: -40),
//            
//            dateTimeCaptionLabel.topAnchor.constraint(equalTo: channelName.bottomAnchor, constant: 25),
//            dateTimeCaptionLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            dateTimeCaptionLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//            
//            participantsCaptionLabel.topAnchor.constraint(equalTo: dateTimeCaptionLabel.bottomAnchor, constant: 25),
//            participantsCaptionLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            participantsCaptionLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//            
//            participantsCollectionView.topAnchor.constraint(equalTo: participantsCaptionLabel.bottomAnchor, constant: 8),
//            participantsCollectionView.heightAnchor.constraint(equalToConstant: 60),
//            participantsCollectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            participantsCollectionView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//            
//            descriptionCaptionLabel.topAnchor.constraint(equalTo: participantsCollectionView.bottomAnchor, constant: 20),
//            descriptionCaptionLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            descriptionCaptionLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//            
//            descriptionTextView.topAnchor.constraint(equalTo: descriptionCaptionLabel.bottomAnchor, constant: 8),
//            descriptionTextView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            descriptionTextView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//            
//            bioPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 0),
//            bioPlaceholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: 0),
//            
//            eventTypeCaptionLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 25),
//            eventTypeCaptionLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            eventTypeCaptionLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//            
////            eventStatus.trailingAnchor.constraint(equalTo: locationView.trailingAnchor, constant: 0),
//            locationView.topAnchor.constraint(equalTo: eventTypeCaptionLabel.bottomAnchor, constant: 13),
//            locationView.heightAnchor.constraint(equalToConstant: 200),
//            locationView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            locationView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//
//            footerLabel.topAnchor.constraint(equalTo: locationView.bottomAnchor, constant: 15),
//            
//            footerLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            footerLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//
//            footerSubLabel.topAnchor.constraint(equalTo: footerLabel.bottomAnchor, constant: 0),
//            footerSubLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            footerSubLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//            footerSubLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -115),
//        ])
//        
//        bioPlaceholderLabel.font = UIFont.systemFont(ofSize: 12) //(bio.font!.pointSize - 1)
//        bioPlaceholderLabel.isHidden = !descriptionTextView.text.isEmpty
//    }
//
//    func reloadOverlay(remote: Bool) {
//        
//        if scrollView.contains(overlayView) {
//            overlayView.removeFromSuperview()
//        }
//        
//        if remote {
//            scrollView.addSubview(overlayView)
//            overlayView.addSubview(remoteEventLabel)
//            NSLayoutConstraint.activate([
//                overlayView.topAnchor.constraint(equalTo: eventTypeCaptionLabel.bottomAnchor, constant: 13),
//                overlayView.heightAnchor.constraint(equalToConstant: 200),
//                overlayView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//                overlayView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
//                
//                remoteEventLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor, constant: 0),
//                remoteEventLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor, constant: 0)
//            ])
//        }
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
