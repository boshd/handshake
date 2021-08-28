//
//  CreateChannelController+DatePickerDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-17.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Firebase

extension CreateChannelController: DatePickerDelegate {
    func didChangeDate(cell: UITableViewCell, date: Date) {
        print("REACHED \(tableView.indexPath(for: cell))")
        let indexPath = tableView.indexPath(for: cell)
        let cell = cell as! DatePickerCell
        
        cell.datePicker.date = date
        if indexPath?.row == 1 {
            if let endTime = endTime {
                if Int64(date.timeIntervalSince1970) > endTime {
                    self.endTime = Int64(date.nextHour.timeIntervalSince1970)
//                    let prevHr = Date(timeIntervalSince1970: TimeInterval(endTime)).previousHour
//                    if prevHr < Date() {
//                        startTime = Int64(Date().timeIntervalSince1970)
//                    } else {
//                        startTime = Int64(prevHr.timeIntervalSince1970)
//                    }
//                    return
                }
            }
            startTime = Int64(date.timeIntervalSince1970)
        } else if indexPath?.row == 2 {
            print("in here")
            if let startTime = startTime {
                if Int64(date.timeIntervalSince1970) < startTime {
                    endTime = Int64(Date(timeIntervalSince1970: TimeInterval(startTime)).nextHour.timeIntervalSince1970)
                    cell.datePicker.date = Date(timeIntervalSince1970: TimeInterval(startTime)).nextHour
                    print("in here2")
                    return
                }
            }
            print("in here3")
            endTime = Int64(date.timeIntervalSince1970)
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
}
