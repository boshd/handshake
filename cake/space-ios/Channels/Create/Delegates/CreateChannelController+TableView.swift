//
//  CreateChannelController+TableView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

extension CreateChannelController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: createChannelHeaderCellId, for: indexPath) as? CreateChannelHeaderCell ?? CreateChannelHeaderCell()
            headerCell.createChannelHeaderCellDelegate = self
            
            if let channelName = channelName, isInChannelEditing {
                headerCell.channelNameDescriptionLabel.text = ""
                headerCell.channelNameField.text = channelName
            }
            
            if selectedImage != nil {
                headerCell.channelImageView.image = selectedImage
            }
            headerCell.paddingView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            headerCell.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            headerCell.contentView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            
            return headerCell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: specialSwitchCellId, for: indexPath) as? SpecialSwitchCell ?? SpecialSwitchCell()
                cell.setupCell(title: "Go virtual?", subtitle: "Share the details in the description below")
                cell.isUserInteractionEnabled = true

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
                cell.selectionStyle = .none
                cell.contentView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
                cell.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: createChannelCellId, for: indexPath) as? CreateChannelCell ?? CreateChannelCell()
                
                cell.detailTextLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
                cell.selectionStyle = .none
                cell.textLabel?.text = "Location"
                
                if locationName != nil {
                    cell.detailTextLabel?.text = locationName
                } else {
                    cell.detailTextLabel?.text = nil
                }
                cell.contentView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
                cell.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: datePickerCellId, for: indexPath) as? DatePickerTableViewCell ?? DatePickerTableViewCell()
            cell.delegate = self
            cell.textLabel?.text = datesSection[indexPath.row].title
            cell.datePicker.minimumDate = Date()
            
            if let startTime = startTime {
                if indexPath.row == 0 {
                    cell.datePicker.date = Date(timeIntervalSince1970: TimeInterval(startTime))
                }
                
                if indexPath.row == 1 && endTime == nil {
                    guard let oneHourInFutureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date(timeIntervalSince1970: TimeInterval(startTime)).nextHour) else { return cell }
                    cell.datePicker.date = oneHourInFutureDate
                    endTime = Int(oneHourInFutureDate.timeIntervalSince1970)
                }
                
            } else {
                if indexPath.row == 0 {
                    cell.datePicker.date = Date().nextHour
                }
            }
            
            if let endTime = endTime {
                if indexPath.row == 1 {
                    cell.datePicker.date = Date(timeIntervalSince1970: TimeInterval(endTime))
                }
            } else {
                if indexPath.row == 1 {
                    guard let oneHourInFutureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date().nextHour) else { return cell }
                    cell.datePicker.date = oneHourInFutureDate
                }
            }
            

            if indexPath.row == 1 {
                if let startTime = startTime {
                    cell.datePicker.minimumDate = Date(timeIntervalSince1970: TimeInterval(startTime))
                }
                
            }
            
            cell.contentView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            cell.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: createChannelCellId, for: indexPath) as? CreateChannelCell ?? CreateChannelCell()
            cell.textLabel?.text = mainSection[indexPath.row].title
            cell.detailTextLabel?.text = mainSection[indexPath.row].secondaryTitle
            
            if let description = channelDescription {
                if indexPath.row == 1 {
                    cell.textLabel?.text = "Event description"
                    cell.detailTextLabel?.text = description
                }
            }
            cell.detailTextLabel?.textColor = ThemeManager.currentTheme().generalTitleColor

            cell.contentView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            cell.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if isVirtual {
                return 1
            } else {
                return 2
            }
        } else if section == 2 {
            return datesSection.count
        } else {
            return mainSection.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else if indexPath.section == 3 {
            return UITableView.automaticDimension
        } else {
            return 55
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 10
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        headerView.backgroundColor = ThemeManager.currentTheme().seperatorColor

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                addLocationPressed()
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                addDescriptionPressed()
            }
        }
        
        //tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
