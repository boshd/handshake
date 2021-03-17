//
//  CheckableTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-03.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

class CheckableTableViewCell: InteractiveTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}
