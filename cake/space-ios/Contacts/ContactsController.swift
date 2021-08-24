//
//  ContactsController.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-16.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import PhoneNumberKit
import RealmSwift

private let usersCellID = "usersCellID"
private let currentUserCellID = "currentUserCellID"

class ContactsController: CustomTableViewController {

    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    var users: Results<User>?
    
    var presentingController: UIViewController?

    var searchBar: UISearchBar?
    var searchContactsController: UISearchController?

    let phoneNumberKit = PhoneNumberKit()
    let viewPlaceholder = ViewPlaceholder()
    var usersFetcher = UsersFetcher()
    let contactsFetcher = ContactsFetcher()
    
    var permissionGranted = false
    
    let createButtonDelegate: CreateButtonDelegate? = nil

    let realm = try! Realm(configuration: RealmKeychain.realmUsersConfiguration())
    let nonLocalRealm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureNavigationBar()
        setupSearchController()
        addContactsObserver()
        addObservers()
        setupDataSource()
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadUsers()
            self?.contactsFetcher.fetchContacts()
        }
    }

    fileprivate var shouldReSyncUsers = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        guard shouldReSyncUsers else { return }
        shouldReSyncUsers = false
        usersFetcher.loadUsers()
        contactsFetcher.syncronizeContacts(contacts: contacts)
    }
    
    deinit {
        stopContiniousUpdate()
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }
    
    func setupDataSource() {
        users = realm.objects(User.self)
    }
    
    fileprivate func deselectItem() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    fileprivate func configureViewController() {
        usersFetcher.delegate = self
        contactsFetcher.delegate = self
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
        edgesForExtendedLayout = UIRectEdge.top
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        tableView.sectionIndexBackgroundColor = view.backgroundColor
        tableView.backgroundColor = view.backgroundColor
        tableView.separatorStyle = .none
        tableView.register(UsersTableViewCell.self, forCellReuseIdentifier: usersCellID)
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: currentUserCellID)
    }
    
    fileprivate func configureNavigationBar() {
        if let navigationController = navigationController {
            ThemeManager.setNavigationBarAppearance(navigationController.navigationBar)
        }
        
        navigationItem.title = "Contacts"
    }
    
    fileprivate func setupSearchController() {
        if #available(iOS 11.0, *) {
            searchContactsController = UISearchController(searchResultsController: nil)
            searchContactsController?.searchResultsUpdater = self
            searchContactsController?.obscuresBackgroundDuringPresentation = false
            searchContactsController?.searchBar.delegate = self
            navigationItem.searchController = searchContactsController
        } else {
            searchBar = UISearchBar()
            searchBar?.delegate = self
            searchBar?.tintColor = ThemeManager.currentTheme().tintColor
            searchBar?.placeholder = "Search"
            searchBar?.searchBarStyle = .minimal
            searchBar?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 35)
            tableView.tableHeaderView = searchBar
        }
    }
    
    fileprivate func addContactsObserver() {
        NotificationCenter.default.addObserver(self,
        selector: #selector(contactStoreDidChange),
        name: .CNContactStoreDidChange,
        object: nil)
    }

    fileprivate func removeContactsObserver() {
        NotificationCenter.default.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
        NotificationCenter.default.addObserver(self,
        selector: #selector(cleanUpController),
        name: NSNotification.Name(rawValue: "clearUserData"),
        object: nil)
    }

    @objc func contactStoreDidChange(notification: NSNotification) {
        guard Auth.auth().currentUser != nil else { return }
        removeContactsObserver()
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadUsers()
            self?.contactsFetcher.fetchContacts()
        }
    }

    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.sectionIndexBackgroundColor = view.backgroundColor
        tableView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.backgroundColor = ThemeManager.currentTheme().windowBackground
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc func cleanUpController() {
        stopContiniousUpdate()
        func deleteAll() {
            do {
                try realm.safeWrite {
                    realm.deleteAll()
                }
                try nonLocalRealm.safeWrite {
                    nonLocalRealm.deleteAll()
                }
            } catch {}
        }

        deleteAll()
        shouldReSyncUsers = true
        userDefaults.removeObject(for: userDefaults.contactsCount)
        userDefaults.removeObject(for: userDefaults.contactsSyncronizationStatus)
    }

    fileprivate var isAppLoaded = false

    fileprivate func reloadTableView(updatedUsers: [User]) {
        continiousUIUpdate(users: updatedUsers)
    }

    fileprivate var updateUITimer: DispatchSourceTimer?

    fileprivate func continiousUIUpdate(users: [User]) {
        guard users.count > 0 else { return }
        updateUITimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        updateUITimer?.schedule(deadline: .now(), repeating: .seconds(60))
        updateUITimer?.setEventHandler { [weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.performUIUpdate(users: users)
        }
        updateUITimer?.resume()
    }

    fileprivate func performUIUpdate(users: [User]) {
        autoreleasepool {
            if !realm.isInWriteTransaction {
                realm.beginWrite()
                for user in users {
                    realm.create(User.self, value: user, update: .modified)
                }
                try! realm.commitWrite()
            }
            
            if !nonLocalRealm.isInWriteTransaction {
                nonLocalRealm.beginWrite()
                let objectsToDelete = nonLocalRealm.objects(User.self).filter({ RealmKeychain.realmUsersArray().map({$0.id}).contains($0.id) })
                nonLocalRealm.delete(objectsToDelete)
                try! nonLocalRealm.commitWrite()
            }
        }

        guard isAppLoaded == false else {
            DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            }
            return
        }

        isAppLoaded = true
        UIView.transition(with: tableView, duration: 0.15, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.tableView.reloadData()
        }, completion: nil)
    }

    fileprivate func stopContiniousUpdate() {
        updateUITimer?.cancel()
        updateUITimer = nil
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
    
    @objc func dismissController() {
        hapticFeedback(style: .impact)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func reloadUsers() {
        hapticFeedback(style: .impact)
        if let presentingController = presentingController as? ChannelsController {
            dismiss(animated: true, completion: nil)
        }
    }

}

// MARK: - Table view data source

extension ContactsController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users?.count ?? 0
        } else {
            return filteredContacts.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if users?.count == 0 {
                return ""
            } else {
                return "AVAILABLE ON HANDSHAKE"
            }
        }
        guard section == 1, filteredContacts.count != 0 else { return " " }
        return "CONTACTS"
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let myLabel = UILabel()
//        myLabel.frame = CGRect(x: 15, y: 3, width: 320, height: 22)
//        myLabel.font = .boldSystemFont(ofSize: 10)
//        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
//        myLabel.textColor = .gray
//
////        let attributedString = NSMutableAttributedString(string: myLabel.text!)
////        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(1.5), range: NSRange(location: 0, length: attributedString.length))
////        myLabel.attributedText = attributedString
//
//        let headerView = UIView()
//        headerView.addSubview(myLabel)
//        headerView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
//
//        return headerView
//    }
    
    override func tableView(_  tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 10)
        header.textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        header.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if users?.count == 0 {
                return 0
            } else {
                return 30
            }
        }
        guard section == 1, filteredContacts.count != 0 else { return 0 }
        return 25
    }

//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.tintColor = ThemeManager.currentTheme().tintColor
//        guard section == 1 else { return }
//        view.tintColor = ThemeManager.currentTheme().tintColor
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: usersCellID,
        for: indexPath) as? UsersTableViewCell ?? UsersTableViewCell()
        let parameter = indexPath.section == 0 ? users?[indexPath.row] : filteredContacts[indexPath.row]
        cell.configureCell(for: parameter)
        cell.backgroundColor = ThemeManager.currentTheme().groupedInsetCellBackgroundColor
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hapticFeedback(style: .impact)
        searchBar?.resignFirstResponder()
        searchContactsController?.searchBar.resignFirstResponder()

        if indexPath.section == 0 {
            let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(CustomAlertAction(title: "View profile", style: .default , handler: { [unowned self] in
                let destination = ParticipantProfileController()
                
                guard let user = users?[indexPath.row] else { return }
                destination.member = user
                destination.userProfileContainerView.addPhotoLabel.isHidden = true
                destination.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destination, animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)

        } else if indexPath.section == 1 {
            let destination = ContactsDetailController()
            destination.contactName = filteredContacts[indexPath.row].givenName + " " + filteredContacts[indexPath.row].familyName
            if let photo = filteredContacts[indexPath.row].thumbnailImageData {
              destination.contactPhoto = UIImage(data: photo)
            }
            destination.contactPhoneNumbers.removeAll()
            destination.hidesBottomBarWhenPushed = true
            destination.contactPhoneNumbers = filteredContacts[indexPath.row].phoneNumbers
            navigationController?.pushViewController(destination, animated: true)
        }
    }
    
}

extension ContactsController: ContactsUpdatesDelegate {
    func contacts(shouldPerformSyncronization: Bool) {
        guard shouldPerformSyncronization else { return }
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.showActivityView(with: .updating)
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.usersFetcher.loadAndSyncUsers()
        }
    }
    
    func contacts(updateDatasource contacts: [CNContact]) {
        self.contacts = contacts
        self.filteredContacts = contacts
        DispatchQueue.main.async { [weak self] in
            UIView.performWithoutAnimation {
                self?.tableView.reloadSections([1], with: .none)
            }
        }
    }
    
    func contacts(handleAccessStatus: Bool) {
        //    guard handleAccessStatus, (users?.count ?? 0) > 0 else {
        //      viewPlaceholder.add(for: view, title: .denied, subtitle: .denied, priority: .high, position: .top)
        //      return
        //    }
        //    viewPlaceholder.remove(from: view, priority: .high)
    }
}

extension ContactsController: UsersUpdatesDelegate {
    func users(shouldBeUpdatedTo users: [User]) {
        reloadTableView(updatedUsers: users)

        let syncronizationStatus = userDefaults.currentBoolObjectState(for: userDefaults.contactsSyncronizationStatus)
        guard syncronizationStatus == true else { return }
        addContactsObserver()
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.hideActivityView(with: .updatingUsers)
        }
    }
}
