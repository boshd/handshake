//
//  LoadMoreCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class LoadMoreCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.text = "LOAD MORE PLZ"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
