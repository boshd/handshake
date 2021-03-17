//
//  RSVPView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-05-18.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class RSVPView: UIView {
    
    var rsvpIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "letter")
        
        return imageView
    }()
    
    var acceptButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("accept", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    var declineButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("decline", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    var buttonsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rsvpIcon)
        addSubview(buttonsContainer)
        buttonsContainer.addSubview(acceptButton)
        buttonsContainer.addSubview(declineButton)
        
        NSLayoutConstraint.activate([
            rsvpIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            rsvpIcon.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            rsvpIcon.heightAnchor.constraint(equalToConstant: 20),
            rsvpIcon.widthAnchor.constraint(equalToConstant: 20),
            
            buttonsContainer.leadingAnchor.constraint(equalTo: rsvpIcon.trailingAnchor, constant: 10),
            buttonsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            buttonsContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            buttonsContainer.bottomAnchor.constraint(equalTo: rsvpIcon.bottomAnchor, constant: 0),
            
            acceptButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor, constant: 0),
            acceptButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor, constant: 0),
            acceptButton.widthAnchor.constraint(equalToConstant: 120),
            acceptButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor, constant: 0),
            
            declineButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor, constant: 0),
            declineButton.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor, constant: 0),
            declineButton.widthAnchor.constraint(equalToConstant: 120),
            declineButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

