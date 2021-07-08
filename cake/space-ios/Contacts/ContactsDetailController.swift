//
//  ContactsDetailController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-17.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MessageUI
import Contacts

private let currentUserCellID = "currentUserCellID"
private let contactPhoneNnumberTableViewCellID = "contactPhoneNnumberTableViewCellID"
private let invitationText = "Hey 👋, I'm inviting you to join Handshake's beta program. Handshake is a new private events app that features chat, rsvp, location and more. Sign up here with your Apple account email: https://forms.gle/eoCN5hkBV9tPfLu37"

class ContactsDetailController: UITableViewController {

    var contactName = String()
    var contactPhoto: UIImage!
    var contactPhoneNumbers = [CNLabeledValue<CNPhoneNumber>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = contactName
        configureNavigationBar()
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        extendedLayoutIncludesOpaqueBars = true
        tableView.separatorStyle = .none
//        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: currentUserCellID)
        tableView.register(ContactPhoneNumberTableViewCell.self, forCellReuseIdentifier: contactPhoneNnumberTableViewCellID)
    }
    
    fileprivate func configureNavigationBar() {
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(goBack))
        backButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = backButtonItem
        
        self.navigationItem.hidesBackButton = true
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return contactPhoneNumbers.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactPhoneNnumberTableViewCellID,
                     for: indexPath) as? ContactPhoneNumberTableViewCell ?? ContactPhoneNumberTableViewCell()
        if indexPath.section == 0 {
            let contact = contactPhoneNumbers[indexPath.row]
            cell.configureCell(contact: contact)
        } else {
            cell.textLabel?.textColor = view.tintColor
            cell.textLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 20)
            cell.textLabel?.text = "Invite to Handshake 🙌"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if MFMessageComposeViewController.canSendText() {
                guard contactPhoneNumbers.indices.contains(0) else {
                    basicErrorAlertWith(title: "Error",
                    message: "This user doesn't have any phone number provided.",
                    controller: self)
                    return
                }
                let destination = MFMessageComposeViewController()
                destination.body = invitationText
                destination.recipients = [contactPhoneNumbers[0].value.stringValue]
                destination.messageComposeDelegate = self
                present(destination, animated: true, completion: nil)
            } else {
                basicErrorAlertWith(title: "Error", message: "You cannot send texts.", controller: self)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return 80
        }
    }
}

extension ContactsDetailController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}

