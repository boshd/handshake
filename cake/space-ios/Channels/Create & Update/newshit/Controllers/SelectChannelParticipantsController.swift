//
//  SelectChannelParticipantsController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class SelectChannelParticipantsController: SelectParticipantsController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissButton = UIBarButtonItem(image: UIImage(named: "i-remove"), style: .plain, target: self, action: #selector(dismissController))
        dismissButton.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = dismissButton
        setupRightBarButton(with: "Next")
        navigationItem.rightBarButtonItem?.isEnabled = true
        title = "Select Participants"
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationController.navigationBar)
        }
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        tableView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        tableView.sectionIndexBackgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
    }
    
    override func reloadCollectionView() {
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                self.selectedParticipantsCollectionView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    self.selectedParticipantsCollectionView.reloadSections([0])
                }
            }
        }

        if selectedUsers.count == 0 {
            collectionViewHeightAnchor.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = true

        if selectedUsers.count == 1 {
            collectionViewHeightAnchor.constant = 120
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            return
        }
    }

    
    override func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setSecondaryNavigationBarAppearance(navigationBar)
        }
        tableView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        tableView.sectionIndexBackgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    override func rightBarButtonTapped() {
        super.rightBarButtonTapped()
        CreateChannel()
    }
    
    @objc fileprivate func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
            headerTitle.textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        }
    }
}
