//
//  UpdateChannelController+DatePicker.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension UpdateChannelController: DatePickerDelegate {
    func didChangeDate(cell: UITableViewCell, date: Date) {
        let indexPath = tableView.indexPath(for: cell)
        
        let cell = cell as! DatePickerTableViewCell
        cell.datePicker.date = date
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        if indexPath?.row == 0 {
            startTime = Int(date.timeIntervalSince1970)
        } else {
            endTime = Int(date.timeIntervalSince1970)
        }
    }
}
