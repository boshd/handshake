//
//  AppearanceController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-11-20.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

enum DefaultMessageTextFontSize: Float {
    case extraSmall = 14
    case small = 15
    case medium = 16
    case regular = 17
    case large = 19
    case extraLarge = 23
    case extraLargeX2 = 26

    static func allFontSizes() -> [Float] {
        return [DefaultMessageTextFontSize.extraSmall.rawValue,
                DefaultMessageTextFontSize.small.rawValue,
                DefaultMessageTextFontSize.medium.rawValue,
                DefaultMessageTextFontSize.regular.rawValue,
                DefaultMessageTextFontSize.large.rawValue,
                DefaultMessageTextFontSize.extraLarge.rawValue,
                DefaultMessageTextFontSize.extraLargeX2.rawValue]
    }
}

class AppearanceTableViewController: MenuControlsTableViewController {

    fileprivate let sectionTitles = ["THEME CHOICE", "Preview"]
    fileprivate let themesTitles = ["Default", "Dark mode"]
    fileprivate let themes = [Theme.normal, Theme.dark]
    fileprivate let userDefaultsManager = UserDefaultsManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Appearance"
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 10.0
        setupNavigationbar()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearanceExampleTheme()
    }
    
    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    }

    fileprivate func updateAppearanceExampleTheme() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AppearanceExampleTableViewCell else { return }
        cell.appearanceExampleCollectionView.updateTheme()
        DispatchQueue.main.async { [weak self] in self?.tableView.reloadData() }
    }
    
    fileprivate func setupNavigationbar() {
        let dismissButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(dismissController))
        dismissButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        dismissButton.tintColor = ThemeManager.currentTheme().tintColor
        navigationItem.leftBarButtonItem = dismissButton
        
    }
    
    @objc fileprivate func dismissController() {
        navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 35
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = SpecialSwitchCell(style: .subtitle, reuseIdentifier: specialSwitchCellID)
            cell.contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
            cell.textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
            cell.detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
            cell.isUserInteractionEnabled = true
            cell.selectionStyle = .none
            
            
            if indexPath.row == 0 {
                cell.setupCell(title: "Dark mode", subtitle: "Toggle Dark mode settings for the app.")
                cell.switchAccessory.isOn = userDefaults.currentBoolObjectState(for: userDefaults.selectedTheme)
                cell.switchTapAction = { isOn in
                    DispatchQueue.main.async { [weak self] in
                        self?.themeToggled(dark: isOn)
                    }
                }
                if userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
                    cell.switchAccessory.isEnabled = false
                } else {
                    cell.switchAccessory.isEnabled = true
                }
                
            } else {
                cell.setupCell(title: "Automatic", subtitle: "If toggled, Handshake will automatically change\nit's appearance based on the device settings.")
                cell.switchAccessory.isOn = userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme)
                cell.switchTapAction = { isOn in
                    DispatchQueue.main.async { [weak self] in
                        self?.useSystemThemeToggled(isOn)
                    }
                }
            }
            
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: appearanceExampleTableViewCellID, for: indexPath) as? AppearanceExampleTableViewCell ?? AppearanceExampleTableViewCell()
        cell.contentView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        cell.appearanceExampleCollectionView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 13)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor

        let headerView = UIView()
        headerView.addSubview(label)
        headerView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15)
        ])

        return headerView
    }

    @objc fileprivate func themeToggled(dark: Bool) {
        hapticFeedback(style: .impact)
        if dark {
            ThemeManager.applyTheme(theme: .dark)
        } else {
            ThemeManager.applyTheme(theme: .normal)
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.backgroundColor = ThemeManager.currentTheme().windowBackground
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc fileprivate func useSystemThemeToggled(_ doSo: Bool) {
        hapticFeedback(style: .impact)
        
        userDefaults.updateObject(for: userDefaults.useSystemTheme, with: doSo)
        if userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            if traitCollection.userInterfaceStyle == .light {
                ThemeManager.applyTheme(theme: .normal)
            } else {
                ThemeManager.applyTheme(theme: .dark)
            }
        } else {
            ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.backgroundColor = ThemeManager.currentTheme().windowBackground
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    // responsible for changing theme based on system theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
}
