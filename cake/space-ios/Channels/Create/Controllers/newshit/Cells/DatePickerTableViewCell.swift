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

class DatePickerCell: UITableViewCell {
    
    var datePicker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .dateAndTime
        picker.isUserInteractionEnabled = true
        picker.tintColor = ThemeManager.currentTheme().tintColor
        picker.minimumDate = Date()
        
        return picker
    }()
    
    var datePickerHeight: CGFloat {
        get {
            return datePicker.frame.height + 34.0
        }
    }
    
    var indexPath: IndexPath!
    weak var delegate: DatePickerDelegate?
    
    // Cell height
//    class func cellHeight() -> CGFloat {
//        return 200
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        clipsToBounds = true
        
//        contentView.isUserInteractionEnabled = true
//        selectionStyle = .none
        
        contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
//
//        textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
//        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
//        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
//
//        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 13)
//        datePicker.overrideUserInterfaceStyle = ThemeManager.currentTheme().generalOverrideUserInterfaceStyle
        
        addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            datePicker.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//            datePicker.heightAnchor.constraint(equalToConstant: datePicker.frame.height)
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
