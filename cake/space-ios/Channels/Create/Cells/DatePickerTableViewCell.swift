//
//  DatePickerTableViewCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-28.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

protocol DatePickerDelegate: class {
    func didChangeDate(cell: UITableViewCell, date: Date)
}

class DatePickerTableViewCell: UITableViewCell {
    
    var datePicker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .dateAndTime
        picker.isUserInteractionEnabled = true
        picker.tintColor = ThemeManager.currentTheme().tintColor
        picker.overrideUserInterfaceStyle = .dark
        return picker
    }()
    
    var indexPath: IndexPath!
    weak var delegate: DatePickerDelegate?
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 27.5
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none
        
        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
        
        textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        datePicker.overrideUserInterfaceStyle = ThemeManager.currentTheme().generalOverrideUserInterfaceStyle
        
        addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            // datePicker.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 15),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            datePicker.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            datePicker.heightAnchor.constraint(equalToConstant: DatePickerTableViewCell.cellHeight())
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateCell(date: Date, indexPath: IndexPath) {
        datePicker.setDate(date, animated: true)
        self.indexPath = indexPath
    }
    
    @objc func dateDidChange(_ sender: UIDatePicker) {
        delegate?.didChangeDate(cell: self, date: sender.date)
    }

}
