//
//  SelectParticipantsController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-31.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

protocol SelectedUsersDelegate: class {
    func selectedUsers(shouldBeUpdatedTo selectedUsers: [User])
}

class SelectParticipantsController: UIViewController {

    let usersCellID = "usersCellID"
    let selectedParticipantsCollectionViewCellID = "selectedParticipantsCollectionViewCellID"

    var users = [User]()
    var filteredUsers = [User]()
    var selectedUsers = [User]()
    var preSelectedUsers = [User]()
    var filteredUsersWithSection = [[User]]()
    
    var channel: Channel?

    var collation = UILocalizedIndexedCollation.current()
    var sectionTitles = [String]()
    var searchBar: UISearchBar?
    let tableView = UITableView()
    
    weak var delegate: SelectedUsersDelegate?
    
    var viewPlaceholder = ViewPlaceholder()

    var selectedParticipantsCollectionView: UICollectionView = {
        var selectedParticipantsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return selectedParticipantsCollectionView
    }()

    let alignedFlowLayout = CollectionViewLeftAlignFlowLayout()
    var collectionViewHeightAnchor: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupMainView()
        setupCollectionView()
        setupTableView()
        checkUsersPlease()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController?.visibleViewController is CreateChannelController { return }
        deselectAll()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        DispatchQueue.main.async {
            self.reloadCollectionView()
        }
    }

    fileprivate func deselectAll() {
        guard users.count > 0 else { return }
        _ = users.map { $0.isSelected = false }
        filteredUsers = users
        setUpCollation()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.checkUsersPlease()
        }
    }

    @objc func setUpCollation() {
        let (arrayContacts, arrayTitles) = collation.partitionObjects(array: self.filteredUsers, collationStringSelector: #selector(getter: User.name))
        filteredUsersWithSection = arrayContacts as! [[User]]
        sectionTitles = arrayTitles
    }

    fileprivate func setupMainView() {
        definesPresentationContext = true
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
    }

    func setupNavigationItemTitle(title: String, subTitle: String) {
        navigationItem.setTitle(title: title, subtitle: subTitle, url: nil)
    }

    func setupRightBarButton(with title: String) {
        if #available(iOS 11.0, *) {
//            let rightBarButton = UIButton(type: .system)
//            rightBarButton.setTitle(title, for: .normal)
            //rightBarButton.setTitleColor(ThemeManager.currentTheme().tintColor, for: .normal)
//            rightBarButton.setTitleColor(.lightGray, for: .disabled)
//            rightBarButton.titleLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 14)
//            rightBarButton.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
//            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
//
            let rightBarButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonTapped))
            navigationItem.rightBarButtonItem = rightBarButton
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonTapped))
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = ThemeManager.currentTheme().tintColor
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: ThemeManager.currentTheme().secondaryFontBold(with: 14)], for: .normal)
    }

    @objc func rightBarButtonTapped() {
//        hapticFeedback(style: .impact)
//        Firestore.firestore().collection("sdsd").wh
    }
    
    func checkIfThereAnyUsers(isEmpty: Bool) {
        guard isEmpty else {
            viewPlaceholder.remove(from: tableView, priority: .medium)
            return
        }

        viewPlaceholder.add(for: tableView, title: .noUsers, subtitle: .noUsers, priority: .medium, position: .center)
        tableView.reloadData()
    }
    
    func checkUsersPlease() {
        if users.count == 0 {
            checkIfThereAnyUsers(isEmpty: true)
        } else {
            checkIfThereAnyUsers(isEmpty: false)
        }
    }

    func CreateChannel() {
        let destination = CreateChannelController(style: .plain)
        if selectedUsers.count > 250 {
            hapticFeedback(style: .error)
            displayErrorAlert(title: basicErrorTitleForAlert, message: maximumAttendeesMessage, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        destination.selectedUsers = selectedUsers
        navigationController?.pushViewController(destination, animated: true)
    }

    var chatIDForUsersUpdate = String()
    var informationMessageSender = InformationMessageSender()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }

    // responsible for changing theme based on system theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print(userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme))
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) &&
            userDefaults.currentBoolObjectState(for: userDefaults.useSystemTheme) {
            if traitCollection.userInterfaceStyle == .light {
                ThemeManager.applyTheme(theme: .normal)
            } else {
                ThemeManager.applyTheme(theme: .dark)
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    fileprivate func setupTableView() {

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: selectedParticipantsCollectionView.bottomAnchor).isActive = true

        if #available(iOS 11.0, *) {
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        } else {
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        tableView.sectionIndexBackgroundColor = view.backgroundColor
        tableView.backgroundColor = view.backgroundColor
        tableView.allowsMultipleSelection = true
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        tableView.register(ParticipantTableViewCell.self, forCellReuseIdentifier: usersCellID)
        tableView.separatorStyle = .none
    }

    fileprivate func setupCollectionView() {

        selectedParticipantsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: alignedFlowLayout)

        view.addSubview(selectedParticipantsCollectionView)
        selectedParticipantsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        selectedParticipantsCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true

        collectionViewHeightAnchor = selectedParticipantsCollectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightAnchor.priority = UILayoutPriority(rawValue: 999)
        collectionViewHeightAnchor.isActive = true

        if #available(iOS 11.0, *) {
            selectedParticipantsCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            selectedParticipantsCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        } else {
            selectedParticipantsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
            selectedParticipantsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        }

        selectedParticipantsCollectionView.delegate = self
        selectedParticipantsCollectionView.dataSource = self
        selectedParticipantsCollectionView.showsVerticalScrollIndicator = true
        selectedParticipantsCollectionView.showsHorizontalScrollIndicator = false
        selectedParticipantsCollectionView.alwaysBounceVertical = true
        selectedParticipantsCollectionView.backgroundColor = .clear
        selectedParticipantsCollectionView.register(SelectedParticipantsCollectionViewCell.self, forCellWithReuseIdentifier: selectedParticipantsCollectionViewCellID)
        selectedParticipantsCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        selectedParticipantsCollectionView.isScrollEnabled = true
        selectedParticipantsCollectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        alignedFlowLayout.minimumInteritemSpacing = 5
        alignedFlowLayout.minimumLineSpacing = 5
        alignedFlowLayout.estimatedItemSize = CGSize(width: 100, height: 32)
    }

    fileprivate func setupSearchController() {
        searchBar = UISearchBar()
        searchBar?.delegate = self
        searchBar?.searchBarStyle = .minimal
        searchBar?.changeBackgroundColor(to: ThemeManager.currentTheme().searchBarColor)
        searchBar?.placeholder = "Search"
        searchBar?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 35)
        tableView.tableHeaderView = searchBar
        //SelectUsersContainerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 250))
    }
    
    @objc
    func changeTheme() {
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

    func reloadCollectionView() {
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
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        navigationItem.rightBarButtonItem?.isEnabled = true

        if selectedUsers.count == 1 {
            collectionViewHeightAnchor.constant = 140
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            return
        }
    }

    func didSelectUser(at indexPath: IndexPath) {
        let user = filteredUsersWithSection[indexPath.section][indexPath.row]

        if let filteredUsersIndex = filteredUsers.firstIndex(of: user) {
            filteredUsers[filteredUsersIndex].isSelected = true
        }

        if let usersIndex = users.firstIndex(of: user) {
            users[usersIndex].isSelected = true
        }

        filteredUsersWithSection[indexPath.section][indexPath.row].isSelected = true

        selectedUsers.append(filteredUsersWithSection[indexPath.section][indexPath.row])

        DispatchQueue.main.async {
            self.reloadCollectionView()
        }
    }

    func didDeselectUser(at indexPath: IndexPath) {
        let user = filteredUsersWithSection[indexPath.section][indexPath.row]

        if let findex = filteredUsers.firstIndex(of: user) {
            filteredUsers[findex].isSelected = false
        }

        if let index = users.firstIndex(of: user) {
            users[index].isSelected = false
        }

        if let selectedUserIndexInCollectionView = selectedUsers.firstIndex(of: user) {
            selectedUsers[selectedUserIndexInCollectionView].isSelected = false
            selectedUsers.remove(at: selectedUserIndexInCollectionView)
            DispatchQueue.main.async {
                self.reloadCollectionView()
            }
        }
        filteredUsersWithSection[indexPath.section][indexPath.row].isSelected = false
    }
}

