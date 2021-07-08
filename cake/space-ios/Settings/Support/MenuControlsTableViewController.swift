//
//  MenuControlsTableViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class MenuControlsTableViewController: UITableViewController {
    let switchCellID = "switchCellID"
    let specialSwitchCellID = "specialSwitchCellID"
    let controlButtonCellID = "controlButtonCellID"
    let appearanceExampleTableViewCellID = "appearanceExampleTableViewCellID"
    let appearanceTextSizeTableViewCellID = "appearanceTextSizeTableViewCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
    }
    
    /*
     class Solution:
         def twoSum(self, nums: List[int], target: int) -> List[int]:
             key = {}
             for i in range(len(nums)):
                 if target - nums[i] in key :
                     return [key[target - nums[i]], i]
                 key.update({nums[i]: i })
     
     */

    fileprivate func configureController() {
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
        edgesForExtendedLayout = UIRectEdge.top
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        tableView.sectionIndexBackgroundColor = view.backgroundColor
        tableView.backgroundColor = view.backgroundColor
        tableView.isUserInteractionEnabled  = true
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(SpecialSwitchCell.self, forCellReuseIdentifier: specialSwitchCellID)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: switchCellID)
        tableView.register(AppearanceExampleTableViewCell.self, forCellReuseIdentifier: appearanceExampleTableViewCellID)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ControlButton.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ThemeManager.currentTheme().generalBackgroundColor
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 { return " " }
        return ""
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 0
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = ThemeManager.currentTheme().generalBackgroundColor
    }
}

