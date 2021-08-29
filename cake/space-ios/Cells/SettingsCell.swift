//
//  SettingsCell.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit

class SettingsCell: InteractiveTableViewCell {
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else { return }
            textLabel?.text = sectionType.description
            textLabel?.font = UIFont()
            switchControl.isHidden = !sectionType.containsSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return  switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
    }
    
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
        } else {
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Account
    case AboutSpaces
    case Other
    
    var description: String {
        switch self {
        case .Account:
            return "Account"
        case .AboutSpaces:
            return "About"
        case .Other:
            return "Other"
        }
    }
}

enum AccountOptions: Int, CaseIterable, SectionType {
    case editProfile
    case blockedAccounts
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .editProfile: return "Edit Profile"
        case .blockedAccounts: return "Blocked Accounts"
        }
    }
}

enum AboutSpacesOptions: Int, CaseIterable, SectionType {
    case privacyPolicy
    case faq
    case downloadAgreement
    case feedback
    case crisis
    
    var containsSwitch: Bool { return false }
    
//    var containsSwitch: Bool {
//        switch self {
//        case .privacyPolicy: return true
//        case .faq: return true
//        case .downloadAgreement: return true
//        case .feedback:
//            return true
//        }
//    }
    
    var description: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .faq:
            return "FAQ"
        case .downloadAgreement:
            return "Download Agreement"
        case .feedback:
            return "Feedback"
        case .crisis:
            return "In Crisis? Chat now"
        }
    }
}

enum OtherOptions: Int, CaseIterable, SectionType {
    case logout
    case deleteAccount
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .logout:
            return "Logout"
        case .deleteAccount:
            return "Delete Account"
        }
    }
}
