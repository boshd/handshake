//
//  DateCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-16.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit

class DateCell: UITableViewCell {
    
    let timeLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.text = "11:00 AM"
        
        return label
    }()
    
    let dateLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        label.text = "May 19, 2021"
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setColors()
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        
        selectionStyle = .default
        
        addSubview(timeLabel)
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            
            dateLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -15),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
        ])
        
    }
    
    fileprivate func setColors() {
        backgroundColor = ThemeManager.currentTheme().modalGroupedInsetCellBackgroundColor
        timeLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        dateLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//extension DateCell: DatePickerDelegate {
//    func didChangeDate(cell: UITableViewCell, date: Date) {
//        <#code#>
//    }
//}
