//
//  ChannelDetailsMainView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-05-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class ChannelDetailsMainView: UIView {
  
    
    var channelDetailsContainerView = ChannelDetailsContainerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .offWhite()
        
        addSubview(channelDetailsContainerView)
//        channelDetailsContainerView.frame = bounds
        
        NSLayoutConstraint.activate([
            channelDetailsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            channelDetailsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            channelDetailsContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            channelDetailsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
