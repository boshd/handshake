//
//  LocationViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class LocationViewCell: UITableViewCell {
    
    let locationView = LocationView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(locationView)
        selectionStyle = .none
        locationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        locationView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        locationView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        locationView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        locationView.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
