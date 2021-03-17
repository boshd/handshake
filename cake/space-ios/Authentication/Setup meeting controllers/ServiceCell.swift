//
//  ServiceCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-20.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class ServiceCell: InteractiveTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
