////
////  CreateChannelController+DatePicker.swift
////  space-ios
////
////  Created by Kareem Arab on 2020-11-01.
////  Copyright © 2020 Kareem Arab. All rights reserved.
////
//
//import UIKit
//
//extension CreateChannelController: DatePickerDelegate {
//    func didChangeDate(cell: UITableViewCell, date: Date) {
//        let indexPath = tableView.indexPath(for: cell)
//        
//        let cell = cell as! DatePickerTableViewCell
//        cell.datePicker.date = date
//        tableView.reloadData()
//        if indexPath?.row == 0 {
//            startTime = Int(date.timeIntervalSince1970)
//        } else {
//            endTime = Int(date.timeIntervalSince1970)
//        }
//    }
//}
