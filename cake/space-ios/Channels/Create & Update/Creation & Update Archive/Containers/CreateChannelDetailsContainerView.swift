//
//  CreateChannelDetailsContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-05-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class CreateChannelDetailsContainerView: UIView {
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    var channelNameLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 22)
        label.textColor = .black
        label.sizeToFit()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.numberOfLines = 2
        
        return label
    }()
    
    var addImageLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 26)
        label.textColor = .darkGray
        label.sizeToFit()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.text = "Add image"
        
        return label
    }()
    
    var channelImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 0
        
        return imageView
    }()

    var participantsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = -15
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    var descriptionView: UITextViewFixed = {
        let descriptionView = UITextViewFixed()
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionView.backgroundColor = .clear
        descriptionView.sizeToFit()
        descriptionView.isScrollEnabled = false
        descriptionView.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        descriptionView.textColor = .lightGray
        descriptionView.text = "Describe the event"
        
        return descriptionView
    }()
    
    var locationCaptionLabel: DynamicLabel = {
        let locationLabel = DynamicLabel(withInsets: 0, 0, 0, 0)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = ThemeManager.currentTheme().secondaryFontBold(with: 16)
        locationLabel.textColor = .black
        locationLabel.sizeToFit()
        locationLabel.textAlignment = .left
        locationLabel.numberOfLines = 2
        locationLabel.text = "How to get there?"
        locationLabel.backgroundColor = .clear
        
        return locationLabel
    }()
    
    var locationView = LocationView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .offWhite()

        addSubview(scrollView)
        
        scrollView.addSubview(channelImageView)
        scrollView.addSubview(channelNameLabel)
        scrollView.addSubview(participantsCollectionView)
        scrollView.addSubview(descriptionView)
        scrollView.addSubview(locationCaptionLabel)
        scrollView.addSubview(locationView)
        
        channelImageView.addSubview(addImageLabel)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            channelImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            channelImageView.heightAnchor.constraint(equalToConstant: 250),
            channelImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            channelImageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            addImageLabel.centerYAnchor.constraint(equalTo: channelImageView.centerYAnchor, constant: 0),
            addImageLabel.centerXAnchor.constraint(equalTo: channelImageView.centerXAnchor, constant: 0),
            
            channelNameLabel.topAnchor.constraint(equalTo: channelImageView.bottomAnchor, constant: 15),
            channelNameLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            channelNameLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            
            participantsCollectionView.topAnchor.constraint(equalTo: channelNameLabel.bottomAnchor, constant: 10),
            participantsCollectionView.heightAnchor.constraint(equalToConstant: 40),
            participantsCollectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            participantsCollectionView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            
            descriptionView.topAnchor.constraint(equalTo: participantsCollectionView.bottomAnchor, constant: 10),
            descriptionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            descriptionView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            
            locationCaptionLabel.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 20),
            locationCaptionLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            locationCaptionLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            
            locationView.topAnchor.constraint(equalTo: locationCaptionLabel.bottomAnchor, constant: 10),
            locationView.heightAnchor.constraint(equalToConstant: 200),
            locationView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            locationView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
