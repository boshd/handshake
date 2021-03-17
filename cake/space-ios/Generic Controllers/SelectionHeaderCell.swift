//
//  SelectionHeaderCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-23.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class SelectionHeaderCell: UITableViewCell {

    let headerView = HeaderView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
       
        addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            headerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setColor() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        accessoryView?.backgroundColor = backgroundColor
        selectionColor = ThemeManager.currentTheme().cellSelectionColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setColor()
    }
    
    
}
