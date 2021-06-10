//
//  CreateChannelOptionsContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-10-17.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class CreateChannelOptionsContainerView: UIView {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .nude()
        
        return scrollView
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Create group"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.sizeToFit()
        
        return titleLabel
    }()
    
    let channelImageView: UIImageView = {
        let channelImageView = UIImageView(frame: .zero)
        channelImageView.translatesAutoresizingMaskIntoConstraints = false
        channelImageView.layer.cornerRadius = 15
        channelImageView.backgroundColor = .lightGray
        channelImageView.contentMode = UIView.ContentMode.scaleAspectFill
        channelImageView.clipsToBounds = true
        channelImageView.isUserInteractionEnabled = true
        
        return channelImageView
    }()
    
    let addImageLabel: UILabel = {
        let addImageLabel = UILabel(frame: .zero)
        addImageLabel.translatesAutoresizingMaskIntoConstraints = false
        addImageLabel.text = "Add an image (required)"
        addImageLabel.backgroundColor = .gray
        addImageLabel.layer.cornerRadius = 15
        addImageLabel.textColor = .white
        addImageLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        addImageLabel.isEnabled = true
        addImageLabel.isUserInteractionEnabled = true
        addImageLabel.textAlignment = .center
        
        return addImageLabel
    }()
    
    let participantsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: ScreenSize.width - 20, height: 100)
        let participantsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        participantsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        participantsCollectionView.backgroundColor = .nude()
        participantsCollectionView.layer.cornerRadius = 5
        
        return participantsCollectionView
    }()
    
    let locationButtonView: UIView = {
        let locationButtonView = UIView(frame: .zero)
        locationButtonView.translatesAutoresizingMaskIntoConstraints = false
        locationButtonView.backgroundColor = .nude()
        locationButtonView.layer.borderWidth = 0.5
        locationButtonView.layer.borderColor = UIColor.white.cgColor
        
        return locationButtonView
    }()
    
    let locationButtonTitleLabel: UILabel = {
        let locationButtonTitleLabel = UILabel(frame: .zero)
        locationButtonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationButtonTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        locationButtonTitleLabel.textColor = .black
        locationButtonTitleLabel.text = "Set Location (required)"
        
        return locationButtonTitleLabel
    }()
    
    let locationButtonTitleSublabel: UILabel = {
        let locationButtonTitleSublabel = UILabel(frame: .zero)
        locationButtonTitleSublabel.translatesAutoresizingMaskIntoConstraints = false
        locationButtonTitleSublabel.font = UIFont(name: "HelveticaNeue", size: 11)
        locationButtonTitleSublabel.textColor = .gray
        locationButtonTitleSublabel.text = "The place you will hold your event."
        
        return locationButtonTitleSublabel
    }()
    
    let descButtonView: UIView = {
        let descButtonView = UIView(frame: .zero)
        descButtonView.translatesAutoresizingMaskIntoConstraints = false
        descButtonView.backgroundColor = .nude()
//        descButtonView.layer.cornerRadius = 12
        descButtonView.layer.borderWidth = 0.5
        descButtonView.layer.borderColor = UIColor.white.cgColor
        
        return descButtonView
    }()
    
    let descButtonTitleLabel: UILabel = {
        let descButtonTitleLabel = UILabel(frame: .zero)
        descButtonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        descButtonTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        descButtonTitleLabel.textColor = .black
        descButtonTitleLabel.text = "Add description (required)"
        
        return descButtonTitleLabel
    }()
    
    let descButtonTitleSublabel: UILabel = {
        let descButtonTitleSublabel = UILabel(frame: .zero)
        descButtonTitleSublabel.translatesAutoresizingMaskIntoConstraints = false
        descButtonTitleSublabel.font = UIFont(name: "HelveticaNeue", size: 11)
        descButtonTitleSublabel.textColor = .gray
        descButtonTitleSublabel.text = "eg. Bring nachos and some drinks!"
        
        return descButtonTitleSublabel
    }()
    
    let dateButtonView: UIView = {
        let dateButtonView = UIView(frame: .zero)
        dateButtonView.translatesAutoresizingMaskIntoConstraints = false
        dateButtonView.backgroundColor = .nude()
//        dateButtonView.layer.cornerRadius = 12
        dateButtonView.layer.borderWidth = 0.5
        dateButtonView.layer.borderColor = UIColor.white.cgColor
        
        return dateButtonView
    }()
    
    let dateButtonTitleLabel: UILabel = {
        let dateButtonTitleLabel = UILabel(frame: .zero)
        dateButtonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateButtonTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        dateButtonTitleLabel.textColor = .black
        dateButtonTitleLabel.text = "Pick a date & time (required)"
        
        return dateButtonTitleLabel
    }()
    
    let dateButtonTitleSublabel: UILabel = {
        let dateButtonTitleSublabel = UILabel(frame: .zero)
        dateButtonTitleSublabel.translatesAutoresizingMaskIntoConstraints = false
        dateButtonTitleSublabel.font = UIFont(name: "HelveticaNeue", size: 11)
        dateButtonTitleSublabel.textColor = .gray
        dateButtonTitleSublabel.text = "The day and time of your event."
        
        return dateButtonTitleSublabel
    }()
    
    let seperator: UIView = {
        let seperator = UIView(frame: .zero)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .lightStuff()
        
        return seperator
    }()
    
    let nextButton: LoadingButton = {
        let nextButton = LoadingButton(frame: .zero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Publish", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = .black
        nextButton.layer.cornerRadius = 10
        nextButton.isEnabled = true
        nextButton.isUserInteractionEnabled = true
//        nextButton.addTarget(self, action: #selector(CreateChannelOptionsViewController.createChannel), for: .touchUpInside)
        
        return nextButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .nude()

        addSubview(scrollView)
        
        var contentRect = CGRect.zero

        for view in scrollView.subviews {
           contentRect = contentRect.union(view.frame)
        }
        scrollView.contentSize = contentRect.size
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(channelImageView)
        channelImageView.addSubview(addImageLabel)
        scrollView.addSubview(participantsCollectionView)
//        scrollView.addSubview(seperator)
        scrollView.addSubview(locationButtonView)
        locationButtonView.addSubview(locationButtonTitleLabel)
        locationButtonView.addSubview(locationButtonTitleSublabel)
        scrollView.addSubview(descButtonView)
        descButtonView.addSubview(descButtonTitleLabel)
        descButtonView.addSubview(descButtonTitleSublabel)
        scrollView.addSubview(dateButtonView)
        dateButtonView.addSubview(dateButtonTitleLabel)
        dateButtonView.addSubview(dateButtonTitleSublabel)
        scrollView.addSubview(nextButton)
        
        scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
//        scrollView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -15).isActive = true

        channelImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        channelImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        channelImageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        channelImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        channelImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        
        addImageLabel.centerXAnchor.constraint(equalTo: channelImageView.centerXAnchor, constant: 0).isActive = true
        addImageLabel.centerYAnchor.constraint(equalTo: channelImageView.centerYAnchor, constant: 0).isActive = true
        addImageLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addImageLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        participantsCollectionView.topAnchor.constraint(equalTo: channelImageView.bottomAnchor, constant: 15).isActive = true
        participantsCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        participantsCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        participantsCollectionView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
//        seperator.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
//        seperator.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
//        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        seperator.topAnchor.constraint(equalTo: participantsCollectionView.bottomAnchor, constant: 5).isActive = true
        
        locationButtonView.topAnchor.constraint(equalTo: participantsCollectionView.bottomAnchor, constant: 5).isActive = true
        locationButtonView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        locationButtonView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        locationButtonView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        locationButtonTitleLabel.topAnchor.constraint(equalTo: locationButtonView.topAnchor, constant: 15).isActive = true
        locationButtonTitleLabel.leadingAnchor.constraint(equalTo: locationButtonView.leadingAnchor, constant: 20).isActive = true
        locationButtonTitleLabel.trailingAnchor.constraint(equalTo: locationButtonView.trailingAnchor, constant: -20).isActive = true
        
        locationButtonTitleSublabel.bottomAnchor.constraint(equalTo: locationButtonView.bottomAnchor, constant: -13).isActive = true
        locationButtonTitleSublabel.leadingAnchor.constraint(equalTo: locationButtonView.leadingAnchor, constant: 20).isActive = true
        locationButtonTitleSublabel.trailingAnchor.constraint(equalTo: locationButtonView.trailingAnchor, constant: -20).isActive = true
        
        descButtonView.topAnchor.constraint(equalTo: locationButtonView.bottomAnchor, constant: 12).isActive = true
        descButtonView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        descButtonView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        descButtonView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        descButtonTitleLabel.topAnchor.constraint(equalTo: descButtonView.topAnchor, constant: 15).isActive = true
        descButtonTitleLabel.leadingAnchor.constraint(equalTo: descButtonView.leadingAnchor, constant: 20).isActive = true
        descButtonTitleLabel.trailingAnchor.constraint(equalTo: descButtonView.trailingAnchor, constant: -20).isActive = true
        
        descButtonTitleSublabel.bottomAnchor.constraint(equalTo: descButtonView.bottomAnchor, constant: -13).isActive = true
        descButtonTitleSublabel.leadingAnchor.constraint(equalTo: descButtonView.leadingAnchor, constant: 20).isActive = true
        descButtonTitleSublabel.trailingAnchor.constraint(equalTo: descButtonView.trailingAnchor, constant: -20).isActive = true
        
        dateButtonView.topAnchor.constraint(equalTo: descButtonView.bottomAnchor, constant: 12).isActive = true
        dateButtonView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        dateButtonView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        dateButtonView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        dateButtonTitleLabel.topAnchor.constraint(equalTo: dateButtonView.topAnchor, constant: 15).isActive = true
        dateButtonTitleLabel.leadingAnchor.constraint(equalTo: dateButtonView.leadingAnchor, constant: 20).isActive = true
        dateButtonTitleLabel.trailingAnchor.constraint(equalTo: dateButtonView.trailingAnchor, constant: -20).isActive = true
        
        dateButtonTitleSublabel.bottomAnchor.constraint(equalTo: dateButtonView.bottomAnchor, constant: -13).isActive = true
        dateButtonTitleSublabel.leadingAnchor.constraint(equalTo: dateButtonView.leadingAnchor, constant: 20).isActive = true
        dateButtonTitleSublabel.trailingAnchor.constraint(equalTo: dateButtonView.trailingAnchor, constant: -20).isActive = true
        
        nextButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

     func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
}

