//
//  ChannelDetailsController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-05.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class ChannelDetailsController: UIViewController {
    
    var channel: Channel?
    
    var attendees = [User]()
    
    let channelDetailsContainerView = ChannelDetailsContainerView()
    
    var channelListener: ListenerRegistration?
    var channelPartiticapntsListener: ListenerRegistration?
    
    let accountSettingsCellId = "accountSettingsCellId"
    let channelNameCellId = "channelNameCellId"
    let locationViewCellId = "locationViewCellId"
    let userCellId = "userCellId"
    let channelDescriptionCellId = "channelDescriptionCellId"
    let channelDetailsCellId = "channelDetailsCellId"
    let loadMoreCellId = "loadMoreCellId"
    
    let tableSectionHeaderHeight: CGFloat = 45.0
    
    let initialNumberOfAttendees = 1
    
    var allAttendeesLoaded = false
    var initialAttendeesLoaded = false
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        view = channelDetailsContainerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNaviationBar()
        observeChannelAttendees()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Config/setup
    
    fileprivate func configureNaviationBar() {
        navigationItem.title = "Event details"
    }

    fileprivate func configureTableView() {
        channelDetailsContainerView.tableView.delegate = self
        channelDetailsContainerView.tableView.dataSource = self
        channelDetailsContainerView.tableView.register(AccountSettingsTableViewCell.self, forCellReuseIdentifier: accountSettingsCellId)
        channelDetailsContainerView.tableView.register(ChannelNameCell.self, forCellReuseIdentifier: channelNameCellId)
        channelDetailsContainerView.tableView.register(LocationViewCell.self, forCellReuseIdentifier: locationViewCellId)
        channelDetailsContainerView.tableView.register(UsersTableViewCell.self, forCellReuseIdentifier: userCellId)
        channelDetailsContainerView.tableView.register(ChannelDescriptionCell.self, forCellReuseIdentifier: channelDescriptionCellId)
        channelDetailsContainerView.tableView.register(ChannelDetailsCell.self, forCellReuseIdentifier: channelDetailsCellId)
        channelDetailsContainerView.tableView.register(LoadMoreCell.self, forCellReuseIdentifier: loadMoreCellId)
    }
    
    fileprivate func removeListeners() {
        if channelListener != nil {
            channelListener = nil
            channelListener?.remove()
        }
        
        if channelPartiticapntsListener != nil {
            channelPartiticapntsListener = nil
            channelPartiticapntsListener?.remove()
        }
    }
    
    // observe actual channel
    // make segmented observations
    fileprivate func observeChannel() {
        guard let channelID = channel?.id else { return }
        channelListener = Firestore.firestore().collection("channels").document(channelID).addSnapshotListener({ snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            
            
        })
    
    }
    
    func loadAllAttendees(at indexPath: IndexPath) {
        guard let attendeeIds = channel?.participantIds else { return }
        let group = DispatchGroup()
        var allUsers = [User]()
        for id in attendeeIds {
            group.enter()
            fetchUser(id: id) { user, error in
                group.leave()
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    return
                }
                if let user = user {
                    allUsers.append(user)
                    allUsers.append(user)
                    allUsers.append(user)
                    allUsers.append(user)
                    allUsers.append(user)
                }
            }
        }
        
        group.notify(queue: .main, execute: { [weak self] in
            self?.attendees = allUsers
            self?.allAttendeesLoaded = true
            
//            self?.channelDetailsContainerView.tableView.beginUpdates()
//            self?.channelDetailsContainerView.tableView.reloadData()
//            self?.channelDetailsContainerView.tableView.endUpdates()
            
            self?.channelDetailsContainerView.tableView.beginUpdates()
            self?.channelDetailsContainerView.tableView.deleteRows(at: [indexPath], with: .none)
            self?.channelDetailsContainerView.tableView.insertRows(at: [indexPath], with: .middle)
            self?.channelDetailsContainerView.tableView.endUpdates()
            
        })
    }
    
    // observe users
    fileprivate func observeChannelAttendees() {
        // APPEND SELF MANUALLY + DON'T RRETURN SELF
        guard let channelID = channel?.id else { return }
        channelPartiticapntsListener = Firestore.firestore().collection("channels").document(channelID).collection("participantIds").limit(to: initialNumberOfAttendees).addSnapshotListener({ [weak self] snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            guard let docs = snapshot?.documents else { return }
            
            let group = DispatchGroup()

            for doc in docs {
                group.enter()
                self?.fetchUser(id: doc.documentID) { user, error in
                    group.leave()
                    if let user = user {
                        self?.attendees.append(user)
                    }
                }
            }

            group.notify(queue: .main) { [weak self] in
                
                self?.initialAttendeesLoaded = true
                
                if let participantIdCount = self?.channel?.participantIds.count {
                    if self?.attendees.count == (participantIdCount + 3) {
                        self?.allAttendeesLoaded = true
                    } else {
                        self?.allAttendeesLoaded = false
                    }
                }
                
                self?.channelDetailsContainerView.tableView.reloadData()
            }
            
        })
    }
    
    // MARK: - Helper methods
    
    // user fetching method
    func fetchUser(id: String, completion: @escaping (User?, Error?) -> ()) {
        Firestore.firestore().collection("users").document(id).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                completion(nil, error)
                return
            }
            guard let userData = snapshot?.data() as [String : AnyObject]? else { return }
            completion(User(dictionary: userData), nil)
        }
    }
    
}
