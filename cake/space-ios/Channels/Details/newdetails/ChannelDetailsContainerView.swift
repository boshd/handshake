//
//  ChannelDetailsContainerView_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class ChannelDetailsContainerView: UIView {
    
    let channelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = ThemeManager.currentTheme().imageViewBackground
        
        return imageView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    var rsvpView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        return view
    }()

    var rsvpButton: InteractiveButton = {
        var button = InteractiveButton()
        button.scaler = 0.95
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ThemeManager.currentTheme().buttonColor
        button.setTitle("RSVP", for: .normal)
        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 14)
        button.titleLabel?.textColor = ThemeManager.currentTheme().buttonTextColor
        button.layer.cornerRadius = 15
        button.layer.cornerCurve = .continuous

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        addSubview(tableView)
        addSubview(rsvpView)
        rsvpView.addSubview(rsvpButton)
        bringSubviewToFront(rsvpView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            rsvpView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            rsvpView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            rsvpView.heightAnchor.constraint(equalToConstant: 100),
            rsvpView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            rsvpButton.topAnchor.constraint(equalTo: rsvpView.topAnchor, constant: 10),
            rsvpButton.leadingAnchor.constraint(equalTo: rsvpView.leadingAnchor, constant: 15),
            rsvpButton.trailingAnchor.constraint(equalTo: rsvpView.trailingAnchor, constant: -15),
            rsvpButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
