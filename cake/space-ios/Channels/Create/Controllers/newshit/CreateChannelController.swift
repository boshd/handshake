//
//  CreateChannelController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-08.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class CreateChannelController: UITableViewController {

    var channelName: String?
    var locationName: String?
    var startTime: Int64?
    var endTime: Int64?
    var latitude: Double?
    var longitude: Double?
    
    var selectedUsers = [User]()
    
    var secondSection = [
        "Remote",
        "Location"
    ]
    
    var thirdSection = [
        "Starts",
        "Ends"
    ]
    var fourthSection = [
        "Description"
    ]
    
    var datePickerIndexPath: IndexPath?
    
    let channelNameHeaderCellId = "channelNameHeaderCellId"
    let datePickerCellId = "datePickerCellId"
    let dateCellId = "dateCellId"
    let locationCellId = "locationCellId"
    let selectLocationCellId = "selectLocationCellId"
    let specialSwitchCellId = "specialSwitchCellId"
    let descriptionCellId = "descriptionCellId"
    
    var datePickerVisible = false
    var expandPicker = false
    
    var isVirtual: Bool = false {
        didSet {
            updateVirtuality()
        }
    }
    
    
    // MARK: - Controller life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Controller setup/config.
    
    fileprivate func configureTableView() {
        tableView.register(ChannelNameHeaderCell.self, forCellReuseIdentifier: channelNameHeaderCellId)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: datePickerCellId)
        tableView.register(DateCell.self, forCellReuseIdentifier: dateCellId)
        tableView.register(LocationCell.self, forCellReuseIdentifier: locationCellId)
        tableView.register(SpecialSwitchCell.self, forCellReuseIdentifier: specialSwitchCellId)
        tableView.register(SelectLocationCell.self, forCellReuseIdentifier: selectLocationCellId)
        tableView.register(DescriptionCell.self, forCellReuseIdentifier: descriptionCellId)
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func configureNavigationBar() {
        
    }
    
    // MARK: - Date Picker Logic
    
    fileprivate func showDatePicker(at indexPath: IndexPath) {
//        datePickerIndexPath = indexPath
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.tableView.beginUpdates()
            self?.datePickerIndexPath = indexPath
//            self?.tableView.deselectRow(at: indexPath, animated: true)
            self?.tableView.endUpdates()
        }
    }
    
    fileprivate func hideDatePicker(at indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.tableView.beginUpdates()
            self?.datePickerIndexPath = nil
//            self?.tableView.deselectRow(at: indexPath, animated: true)
            self?.tableView.endUpdates()
        }
    }
    
    // MARK: - Virtuality
    
    fileprivate func updateVirtuality() {
//        guard let channelID = channelId, !isVirtual else { return }
//        let channelReference = Firestore.firestore().collection("channels").document(channelID)
//        print("update virtuality")
//        batchUpdate.updateData([
//            "isVirtual": isVirtual as AnyObject
//        ], forDocument: channelReference)
    }
}

extension CreateChannelController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: channelNameHeaderCellId, for: indexPath) as? ChannelNameHeaderCell ?? ChannelNameHeaderCell()
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: specialSwitchCellId, for: indexPath) as? SpecialSwitchCell ?? SpecialSwitchCell()
                cell.textLabel?.text = secondSection[0]
                cell.detailTextLabel?.text = "Hold a remote a event."
                
                cell.switchAccessory.isOn = isVirtual
                cell.switchTapAction = { isOn in
                    DispatchQueue.main.async { [weak self] in
                        self?.isVirtual = isOn

                        if isOn {
                            self?.tableView.beginUpdates()
                            self?.tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
                            self?.tableView.endUpdates()
                        } else {
                            self?.tableView.beginUpdates()
                            self?.tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
                            self?.tableView.endUpdates()
                        }
                    }
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: selectLocationCellId, for: indexPath) as? SelectLocationCell ?? SelectLocationCell()
                cell.textLabel?.text = secondSection[1]
                return cell
            }
        } else if indexPath.section == 2 {
            
            if let datePickerIndexPathRow = datePickerIndexPath?.row, datePickerIndexPath != nil && datePickerIndexPathRow + 1 == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: datePickerCellId, for: indexPath) as? DatePickerCell ?? DatePickerCell()
                return cell
            } else if indexPath.row == 1 || indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: datePickerCellId, for: indexPath) as? DatePickerCell ?? DatePickerCell()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: dateCellId, for: indexPath) as? DateCell ?? DateCell()
                cell.textLabel?.text = indexPath.row == 0 ? thirdSection[0] : thirdSection[1]
                return cell
            }
            
//
//            if datePickerIndexPath != nil {
//                if datePickerIndexPath == indexPath {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: datePickerCellId, for: indexPath) as? DatePickerCell ?? DatePickerCell()
//                    return cell
//                }
//            }
//            print(indexPath.row)
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: descriptionCellId, for: indexPath) as? DescriptionCell ?? DescriptionCell()
            cell.textLabel?.text = fourthSection[0]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 125
        } else if indexPath.section == 2 {
            if let datePickerIndexPathRow = datePickerIndexPath?.row, datePickerIndexPath != nil && datePickerIndexPathRow + 1 == indexPath.row {
                return DatePickerCell().datePickerHeight
//                return DatePickerCell.cellHeight()
//                return super.tableView(tableView, heightForRowAt: indexPath)
//                return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            } else if indexPath.row == 1 || indexPath.row == 3 {
                return 0
            } else {
                return 50
            }
        } else {
            return 50
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return isVirtual ? 1 : secondSection.count
        } else if section == 2 {
            return 4
            // return datePickerIndexPath != nil ? thirdSection.count + 1 : thirdSection.count
        } else {
            return fourthSection.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundSecondaryColor
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 0 ? 15 : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if datePickerIndexPath != nil {
                // something is already expanded, therefore we should collapse
                hideDatePicker(at: indexPath)
            } else {
                // nothing is expanded, therefore expand
                showDatePicker(at: indexPath)
            }
        }
    }
    
}
