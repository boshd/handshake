import UIKit
import Firebase
import FirebaseFirestore
import SDWebImage
import CoreLocation
import MapKit
import RealmSwift
import Foundation
import EventKit

enum RSVPType: String {
    case going = "Going"
    case maybe = "Maybe"
    case notGoing = "Not Going"
}

class ChannelDetailsController: UIViewController {
    
    let participantCellId = "participantCellId"

    var channel: Channel?
    
    var channelReference: DocumentReference?
    var usersReference: CollectionReference?
    
    var channelListener: ListenerRegistration?
    
    var channelDetailsDataDatabaseUpdater = ChannelDetailsDataDatabaseUpdater()
    var channelDetailsContainerView = ChannelDetailsContainerView()
    var avatarOpener = AvatarOpener()
    let fullDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    let informationMessageSender = InformationMessageSender()
    let eventStore = EKEventStore()
    let realmChannelsManager = ChannelsRealmManager()
    let realm = try! Realm(configuration: RealmKeychain.realmDefaultConfiguration())
    
    var allParticipants: [User] = [] {
        didSet {
            populateParticipantsCount()
            channelDetailsContainerView.participantsCollectionView.reloadData()
        }
    }
    
    private func loadViews() {
        let view = channelDetailsContainerView
        self.view = view
    }
    
    // MARK: - Controller Life Cycle
    
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
    
    
    override func loadView() {
        super.loadView()
        loadViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        populateContainerView()
        addObservers()
        setupNavigationBar()
        hideKeyboardWhenTappedAround()
        listenToChannelChanges()
        configureController()
        configureUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Controller configuration
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reConfigureCurrentUser), name: .currentUserDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMemberAdded), name: .memberAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMemberRemoved), name: .memberRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelRemoved), name: .channelRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelStatusUpdated), name: .channlStatusUpdated, object: nil)
    }
    
    // MARK:- NOTIFICATIONS HANDLERS
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }
    
    @objc private func changeTheme() {
        
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        
        channelDetailsContainerView.locationView.mapView.overrideUserInterfaceStyle = ThemeManager.currentTheme().generalOverrideUserInterfaceStyle
        channelDetailsContainerView.locationView.locationLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        channelDetailsContainerView.locationView.locationNameLabel.textColor = ThemeManager.currentTheme().chatLogTitleColor
        channelDetailsContainerView.locationView.containerView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        channelDetailsContainerView.locationView.layer.shadowColor = ThemeManager.currentTheme().generalTitleColor.cgColor
        channelDetailsContainerView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        channelDetailsContainerView.channelName.textColor = ThemeManager.currentTheme().generalTitleColor
        channelDetailsContainerView.descriptionCaptionLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        channelDetailsContainerView.eventTypeCaptionLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        channelDetailsContainerView.descriptionTextView.textColor = ThemeManager.currentTheme().generalSubtitleColor
        channelDetailsContainerView.footerLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        channelDetailsContainerView.footerSubLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        channelDetailsContainerView.rsvpView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        channelDetailsContainerView.participantsCollectionView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        channelDetailsContainerView.participantsCaptionLabel.textColor = ThemeManager.currentTheme().generalTitleColor
        populateParticipantsCount()
        
        DispatchQueue.main.async { [weak self] in
            self?.channelDetailsContainerView.participantsCollectionView.reloadData()
        }
        channelDetailsContainerView.participantsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc
    func handleChannelRemoved(_ notification: Notification) {
        print("handleChannelRemoved HAS BEEN CALLED \(notification)")
        guard let obj = notification.object as? [String: Any],
              let removedChannelID = obj["channelID"] as? String,
              let currentChannelID = channel?.id
        else { return }
        
        if currentChannelID == removedChannelID {
            navigationController?.backToViewController(viewController: ChannelLogController.self)
        }
    }

    @objc
    func handleMemberAdded(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let newUserID = obj["id"] as? String
        else { configureUsers(); return }
        
        fetchUser(newUserID) { [weak self] (user) in
            guard let user = user else { return }
            self?.allParticipants.append(user)
        }
    }

    @objc
    func handleMemberRemoved(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let id = obj["id"] as? String,
              let currentUserID = Auth.auth().currentUser?.uid
        else { return }
        allParticipants.removeAll(where: { $0.id == id })
        
        if id == currentUserID {
            navigationController?.backToViewController(viewController: ChannelLogController.self)
        }
    }
    
    @objc func handleChannelStatusUpdated(_ notification: Notification) {
        print("calledpre")
        guard let obj = notification.object as? [String: Any],
              let channelID = obj["channelID"] as? String,
              let currentChannelID = channel?.id,
              channelID == currentChannelID else { return }
        print("called")
        populateContainerView()
    }
    
//    @objc fileprivate func initialConfigureCurrentUser() {
//        guard let currentUser = globalCurrentUser else { return }
//        allParticipants.append(currentUser)
//        DispatchQueue.main.async { [weak self] in
//            self?.channelDetailsContainerView.participantsCollectionView.reloadData()
//        }
//    }
    
    @objc fileprivate func reConfigureCurrentUser() {
        guard let currentUser = globalCurrentUser else { return }
        if let index = allParticipants.enumerated().filter({ $0.element.id == currentUser.id }).map({ $0.offset }).first { allParticipants[index] = currentUser }
        DispatchQueue.main.async { [weak self] in
            self?.channelDetailsContainerView.participantsCollectionView.reloadData()
        }
    }
    
    // MARK:- CONFIG.
    
    func reloadLocationView() {
        guard let isVirtual = channel?.isVirtual.value else { return }
        if let currentView = self.view as? ChannelDetailsContainerView {
            DispatchQueue.main.async {
                currentView.reloadOverlay(virtual: isVirtual)
            }
        }
    }
    
    fileprivate func setupNavigationBar() {
        title = "Event details"
        let closeButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(goBack))
        // closeButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = closeButtonItem
        
        guard let channel = channel,
              let state = channelState(channel: channel),
              let cancelled = channel.isCancelled.value,
              let currentUserID = Auth.auth().currentUser?.uid
        else { print("stuck heybaindcd"); return }

        if !cancelled && state != .Past && channel.participantIds.contains(currentUserID) {
            let editButtonItem = UIBarButtonItem(image: UIImage(named: "menu-6"), style: .plain, target: self, action: #selector(moreTapped))
            editButtonItem.tintColor  = .black
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }
    
    func configureUsers() {
        guard let channel = channel
        else { return }
        
        fetchAllUsers(participantIds: Array(channel.participantIds)) { [weak self] (users) in
            guard let users = users else { return }
            self?.allParticipants = users
        }
    }
    
    fileprivate func configureController() {
        guard let channelID = channel?.id else { return }
        
        channelReference = Firestore.firestore().collection("channels").document(channelID)
        usersReference = Firestore.firestore().collection("users")
        
        channelDetailsContainerView.participantsCollectionView.delegate = self
        channelDetailsContainerView.participantsCollectionView.dataSource = self
        avatarOpener.delegate = self
        channelDetailsContainerView.descriptionTextView.delegate = self
        
        channelDetailsContainerView.participantsCollectionView.register(ParticipantCell.self, forCellWithReuseIdentifier: participantCellId)
        
        channelDetailsContainerView.channelImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openChannelProfilePicture)))
        channelDetailsContainerView.participantsCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToParticipants)))
        channelDetailsContainerView.locationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentLocationActions)))
        channelDetailsContainerView.rsvpButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentRSVPActions)))
        channelDetailsContainerView.addToCalendarButton.addTarget(self, action: #selector(addToCalendar), for: .touchUpInside)
    }
    
    // MARK: - Datasource

    func listenToChannelChanges() {
        guard let channelID = channel?.id else { return }
        var first = true
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        channelListener = channelReference.addSnapshotListener { [weak self] (snapshot, error) in
            if first { first = false; return }
            guard let unwrappedSelf = self else { return }
            if error != nil { print(error?.localizedDescription ?? "error"); return }
            guard let data = snapshot?.data() as [String:AnyObject]? else { return }
            let newChannel = Channel(dictionary: data)
            unwrappedSelf.channel = newChannel
            unwrappedSelf.populateContainerView()
            unwrappedSelf.setupNavigationBar()
        }
    }
    
    fileprivate func fetchAllUsers(participantIds: [String?], completetion: @escaping (([User]?) -> Void )) {
        var users = [User]()
        let participantFetchingGroup = DispatchGroup()
        for _ in 0 ..< participantIds.count { participantFetchingGroup.enter() }
        for participantId in participantIds {
            guard let participantId = participantId else { participantFetchingGroup.leave(); completetion(users); return }
            fetchUser(participantId) { (user) in
                participantFetchingGroup.leave()
                guard let user = user else { completetion(nil); return }
                users.append(user)
            }
        }
        participantFetchingGroup.notify(queue: .main) {
            completetion(users)
        }
    }
    
    func fetchUser(_ id: String, completion: @escaping (User?) -> Void) {
        guard let usersReference = usersReference else { completion(nil); return }
        usersReference.document(id).getDocument(completion: { (snapshot, error) in
            if error != nil { print(error?.localizedDescription ?? ""); completion(nil) }
            guard let data = snapshot?.data() else { completion(nil); return }
            let user = User(dictionary: data as [String:AnyObject])
            completion(user)
        })
    }
    
    // MARK: - Populating container view

    func populateParticipantsCount() {
        // participants -- call function to get users
        let participantsCount = allParticipants.count
        var mainString = ""
        if participantsCount == 1 {
            mainString = "1 Attendee →"
        } else {
            mainString = "\(participantsCount) Attendees →"
        }
        
        let stringToColor = "→"
        let range = (mainString as NSString).range(of: stringToColor)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeManager.currentTheme().tintColor, range: range)
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: ThemeManager.currentTheme().secondaryFontBold(with: 13), range: range)
        channelDetailsContainerView.participantsCaptionLabel.attributedText = mutableAttributedString
        
    }
    
    func populateImage() {
        // image
        if let url = channel?.imageUrl {
            self.channelDetailsContainerView.channelImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "GroupIcon"), options: [.continueInBackground, .scaleDownLargeImages], completed: { (_, error, _, _) in
                print(error?.localizedDescription ?? "")
            })
        }
    }
    
    func populateName() {
        // name
        channelDetailsContainerView.channelName.text = channel?.name ?? "event name"
    }
    
    func populateDescription() {
        // description
        if let bio = channel?.description_ {
            channelDetailsContainerView.descriptionTextView.text = bio
            channelDetailsContainerView.bioPlaceholderLabel.isHidden = !channelDetailsContainerView.descriptionTextView.text.isEmpty
        }
    }
    
    func populateTime() {
        // start & end time
        let startDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel?.startTime.value ?? 0)))
        let endDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel?.endTime.value ?? 0)))
        
        fullDateFormatter.dateFormat = "MMM d @ h:mm a"
        timeFormatter.dateFormat = "h:mm a"
        var endFullDate = fullDateFormatter.string(from: endDate)
        
        if startDate.isInSameDay(as: endDate) {
            endFullDate = timeFormatter.string(from: endDate)
            fullDateFormatter.dateFormat = "EE, MMM d @ h:mm a"
        }
        
        let startFullDate = fullDateFormatter.string(from: startDate)
        
        // →
        
        let mainString = "\(startFullDate) → \(endFullDate)"
        let stringToColor = "→"
        let range = (mainString as NSString).range(of: stringToColor)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.eventOrange(), range: range)
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: ThemeManager.currentTheme().secondaryFontBold(with: 12), range: range)
        channelDetailsContainerView.startEndTimesLabel.attributedText = mutableAttributedString
    }

    func populateEventTypeView() {
        if let isVirtual = channel?.isVirtual.value, isVirtual {
            channelDetailsContainerView.eventTypeCaptionLabel.text = "How to get there"
            channelDetailsContainerView.locationView.isUserInteractionEnabled = false
        } else {
            channelDetailsContainerView.eventTypeCaptionLabel.text = "How to get there"
            configureMapView()
        }
        reloadLocationView()
    }
    
    func populateFooter() {
        // footer & sub footer labels
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let createdAt = fullDateFormatter.string(from: Date(timeIntervalSince1970: Double(channel?.createdAt.value ?? 0)))
        
        Firestore.firestore().collection("users").document(channel?.author ?? "").getDocument { [weak self] (snapshot, error) in
            guard let data = snapshot?.data() as [String:AnyObject]?, error == nil else { return }
            let user = User(dictionary: data)
            
            if user.id == currentUserID {
                self?.channelDetailsContainerView.footerLabel.text = "You created this event"
            } else {
                if let realmUser = RealmKeychain.realmUsersArray().first(where: { $0.id == user.id }),
                   let name = realmUser.localName {
                    self?.channelDetailsContainerView.footerLabel.text = "Created by \(name)"
                } else {
                    self?.channelDetailsContainerView.footerLabel.text = "Created by \(user.name ?? self?.channel?.authorName ?? "someone")"
                }
            }
        }
        
        channelDetailsContainerView.footerSubLabel.text = "Created \(createdAt)"
    }
    
    func populateRSVPView() {
        guard let channel = channel,
              let state = channelState(channel: channel),
              let currentUserID = Auth.auth().currentUser?.uid,
              let isCancelled = channel.isCancelled.value
        else { return }
           
        if isCancelled || state == .Past || !channel.participantIds.contains(currentUserID) {
            channelDetailsContainerView.rsvpButton.isHidden = true
        } else {
            channelDetailsContainerView.rsvpButton.isHidden = false
        }
    }
    
    /*
        
    */
    
    func populateEventStatus() {
        // event status
        let calendar = Calendar.current
        let startDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel?.startTime.value ?? 0)))
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: startDate)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        guard let channel = channel, let state = channelState(channel: channel) else { return }
        
        if let isCancelled = channel.isCancelled.value, isCancelled {
            channelDetailsContainerView.eventStatus.textColor = .priorityRed()
            channelDetailsContainerView.eventStatus.backgroundColor = .redEventStatusBackground()
            channelDetailsContainerView.eventStatus.text = "Cancelled"
        } else {
            if state == .Upcoming {
                channelDetailsContainerView.eventStatus.textColor = .priorityGreen()
                channelDetailsContainerView.eventStatus.backgroundColor = .greenEventStatusBackground()
                if let days = components.day {
                    if days == 1 {
                        channelDetailsContainerView.eventStatus.text = "Tomorrow"
                    } else if days == 0 {
                        channelDetailsContainerView.eventStatus.text = "Today"
                    } else {
                        channelDetailsContainerView.eventStatus.text = "\(days) days"
                    }
                }
            } else if state == .InProgress {
                channelDetailsContainerView.eventStatus.textColor = .priorityGreen()
                channelDetailsContainerView.eventStatus.backgroundColor = .greenEventStatusBackground()
                channelDetailsContainerView.eventStatus.text = "In progress"
            } else {
                channelDetailsContainerView.eventStatus.textColor = .priorityRed()
                channelDetailsContainerView.eventStatus.backgroundColor = .redEventStatusBackground()
                channelDetailsContainerView.eventStatus.text = "Expired"
            }
        }
    }
    
    func populateContainerView() {
        populateParticipantsCount()
        populateImage()
        populateName()
        populateDescription()
        populateTime()
        populateEventTypeView()
        populateFooter()
        populateRSVPView()
        populateEventStatus()
    }
    
    // MARK: - Controller @objc functions
    
    @objc
    fileprivate func moreTapped() {
        guard Auth.auth().currentUser != nil, currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        
        guard let channel = channel,
              let currentUserID = Auth.auth().currentUser?.uid
        else { return }
        
        hapticFeedback(style: .impact)
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
        if channel.admins.contains(currentUserID) {
            
            let editEventAction = CustomAlertAction(title: "Edit event", style: .default , handler: {
                self.handleEditEvent()
                
            })
            alert.addAction(editEventAction)
            
        }
        let addToCalendarAction = CustomAlertAction(title: "Add to calendar", style: .default , handler: { [weak self] in
            self?.addToCalendar()
        })
        alert.addAction(addToCalendarAction)
        
        if channel.admins.contains(currentUserID) {
            let cancelEventAction = CustomAlertAction(title: "Cancel event", style: .default , handler: {
                self.handleCancelEvent()
            })
            alert.addAction(cancelEventAction)
        }
        
        let deleteAction = CustomAlertAction(title: "Delete and exit", style: .destructive , handler: {
            self.deleteAndExitHandler()
        })
        alert.addAction(deleteAction)
        self.present(alert, animated: true)
    }
    
    // MARK: - Channel editing handlers
    
    @objc
    fileprivate func handleEditEvent() {
        guard let channel = channel, let state = channel.updateAndReturnStatus() else {
            displayErrorAlert(title: basicErrorTitleForAlert, message: "Something went wrong", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        if state == .inProgress || state == .expired || state == .cancelled {
            displayErrorAlert(title: basicErrorTitleForAlert, message: cannotDoThisState, preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
            return
        }
        
        let destination = UpdateChannelController()
        destination.channelName = channel.name ?? ""
        destination.startTime = Int(channel.startTime.value ?? 0)
        destination.endTime = Int(channel.endTime.value ?? 0)
        destination.location = (channel.latitude.value ?? 0, channel.longitude.value ?? 0)
        destination.locationName = channel.locationName ?? ""
        destination.channelDescription = channel.description_
        destination.channel = channel
        destination.isVirtual = channel.isVirtual.value ?? false
        
        if channel.imageUrl != nil {
            destination.selectedImage = channelDetailsContainerView.channelImageView.image
        }

        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc
    fileprivate func handleCancelEvent() {
        let alert = CustomAlertController(title_: "Confirmation", message: "Are you sure you want to cancel this event? This can't be undone.", preferredStyle: .alert)
        alert.addAction(CustomAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(CustomAlertAction(title: "Yes", style: .destructive, handler: {
            
            guard self.currentReachabilityStatus != .notReachable else {
                basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
                return
            }
            
            guard let currentUserID = Auth.auth().currentUser?.uid, let channel = self.channel, let channelID = channel.id, channel.admins.contains(currentUserID) else { return }
            
            if self.channelReference != nil {
                self.channelReference?.updateData([
                    "isCancelled": true
                ], completion: { (error) in
                    hapticFeedback(style: .success)
                    NotificationCenter.default.post(name: .eventCancelled, object: nil)
                    self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel.name ?? "", participantIDs: [], text: "Event has been cancelled", channel: channel)
                    self.dismiss(animated: true, completion: nil)
                })
            }
            
        
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeChannelListener() {
        if channelListener != nil {
            channelListener?.remove()
            channelListener = nil
        }
    }
    
    @objc
    fileprivate func deleteAndExitHandler() {
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        
        guard let channelID = channel?.id else { return }
        
        hapticFeedback(style: .impact)
        let alert = CustomAlertController(title_: "Confirmation", message: "Are you sure you want to delete and exit this event?", preferredStyle: .alert)
        alert.addAction(CustomAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(CustomAlertAction(title: "Yes", style: .destructive, handler: {
            
            let obj: [String: Any] = ["channelID": channelID]
            self.removeChannelListener()
            NotificationCenter.default.post(name: .deleteAndExit, object: obj)
            NotificationCenter.default.removeObserver(self)
            self.navigationController?.popToRootViewController(animated: false)
//            self.navigationController?.backToViewController(viewController: ChannelsController.self)
//            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//            self.navigationController?.popToViewController(channelsController!, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    fileprivate func openChannelProfilePicture() {
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }

//        guard let editImageAllowed = editImageAllowed else { return }
        
        avatarOpener.handleAvatarOpening(avatarView: channelDetailsContainerView.channelImageView, at: self, isEditButtonEnabled: false, title: .group)
    }
    
    // MARK: - Navigation
    
    @objc
    fileprivate func goToParticipants() {
        guard let channel = self.channel,
              let currentUserID = Auth.auth().currentUser?.uid
        else { return }
        hapticFeedback(style: .selectionChanged)
        let destination = ParticipantsController()

        destination.admin = channel.admins.contains(currentUserID)
        destination.channel = channel
        destination.participants = allParticipants
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc
    fileprivate func goBack() {
        hapticFeedback(style: .impact)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Misc.
    
    @objc
    fileprivate func presentLocationActions() {
        hapticFeedback(style: .impact)
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(CustomAlertAction(title: "Maps", style: .default , handler: { [weak self] in
            self?.openInMaps(type: "apple")
        }))

        alert.addAction(CustomAlertAction(title: "Google Maps", style: .default , handler: { [weak self] in
            self?.openInMaps(type: "google")
        }))
        
//        let cancelAction = CustomAlertAction(title: "Dismiss", style: .cancel , handler: {})
//        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @objc
    fileprivate func presentRSVPActions() {
        guard let channel = channel, let currentUserID = Auth.auth().currentUser?.uid else { return }
        hapticFeedback(style: .impact)
        
        let alert = CustomAlertController(title_: nil, message: nil, preferredStyle: .actionSheet)
        
        let goingAction = CustomAlertAction(title: "Going", style: .default , handler: { [weak self] in
            self?.registerRSVP(decision: .going)
        })
        
        let maybeAction = CustomAlertAction(title: "Maybe", style: .default , handler: { [weak self] in
            self?.registerRSVP(decision: .maybe)
        })
        
        let notGoingAction = CustomAlertAction(title: "Not Going", style: .default , handler: { [weak self] in
            self?.registerRSVP(decision: .notGoing)
        })
        
//        let cancelAction = CustomAlertAction(title: "Dismiss", style: .cancel , handler: {})
//        alert.addAction(cancelAction)
        
        if channel.goingIds.contains(currentUserID) {
            goingAction.isEnabled = false
        } else if channel.maybeIds.contains(currentUserID) {
            maybeAction.isEnabled = false
        } else if channel.notGoingIds.contains(currentUserID) {
            notGoingAction.isEnabled = false
        }
        
        alert.addAction(goingAction)
        alert.addAction(maybeAction)
        alert.addAction(notGoingAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    func addToCalendar() {

        guard let unwrappedChannel = channel else { return }
//        let channelObject = ThreadSafeReference(to: unwrappedChannel)
//        guard let channel = realm.resolve(channelObject) else { return }
        
        let name = unwrappedChannel.name
        let endTime = unwrappedChannel.endTime.value
        let description_ = unwrappedChannel.description_
        let locationName = unwrappedChannel.locationName
        let startTime = unwrappedChannel.startTime.value
        let isVirtual = unwrappedChannel.isVirtual.value
        let lat = unwrappedChannel.latitude.value
        let lon = unwrappedChannel.longitude.value
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: self.eventStore)

                event.title = name
                event.startDate = Date(timeIntervalSince1970: TimeInterval(startTime ?? 0))
                event.endDate = Date(timeIntervalSince1970: TimeInterval(endTime ?? 0))
                event.notes = description_
                
                
                if let isVirtual = isVirtual, isVirtual {
                    event.location = "Virtual"
                } else {
                    if let lat = lat, let lon = lon, let locationName = locationName {
                        let location = CLLocation(latitude: lat, longitude: lon)
                        let structuredLocation = EKStructuredLocation(title: locationName)
                        structuredLocation.geoLocation = location
                        event.structuredLocation = structuredLocation
                    }
                }
                
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                
                hapticFeedback(style: .success)
                displayAlert(title: "Success", message: "The event has been saved to your calendar", preferredStyle: .alert, actionTitle: "Got it", controller: self)
            }
            else{
                print("failed to save event with error : \(error?.localizedDescription ?? "") or access not granted")
                displayErrorAlert(title: basicErrorTitleForAlert, message: "Could not save event, check permissions?", preferredStyle: .alert, actionTitle: "Got it", controller: self)
                
            }
        }
    }
    
    // MARK: - Helper functions
    
    fileprivate func registerRSVP(decision: RSVPType) {
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        guard let channel = channel, let channelID = channel.id, let currentUserID = Auth.auth().currentUser?.uid else { return }
        globalIndicator.show()
        let batch = Firestore.firestore().batch()
        if let channelReference = channelReference {
            switch decision {
            case .going:
                if !channel.goingIds.contains(currentUserID) {
                    batch.updateData(["goingIds": FieldValue.arrayUnion([currentUserID])], forDocument: channelReference)
                }
                if channel.maybeIds.contains(currentUserID) {
                    batch.updateData(["maybeIds": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
                }
                if channel.notGoingIds.contains(currentUserID) {
                    batch.updateData(["notGoingIds": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
                }
            case .maybe:
                if !channel.maybeIds.contains(currentUserID) {
                    batch.updateData(["maybeIds": FieldValue.arrayUnion([currentUserID])], forDocument: channelReference)
                }
                if channel.goingIds.contains(currentUserID) {
                    batch.updateData(["goingIds": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
                }
                if channel.notGoingIds.contains(currentUserID) {
                    batch.updateData(["notGoingIds": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
                }
            case .notGoing:
                if !channel.notGoingIds.contains(currentUserID) {
                    batch.updateData(["notGoingIds": FieldValue.arrayUnion([currentUserID])], forDocument: channelReference)
                }
                if channel.goingIds.contains(currentUserID) {
                    batch.updateData(["goingIds": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
                }
                if channel.maybeIds.contains(currentUserID) {
                    batch.updateData(["maybeIds": FieldValue.arrayRemove([currentUserID])], forDocument: channelReference)
                }
            }
            
            batch.commit { [unowned self] (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                    globalIndicator.dismiss()
                    displayErrorAlert(title: basicErrorTitleForAlert, message: "Could not comeplete operation", preferredStyle: .alert, actionTitle: basicActionTitle, controller: self)
                    return
                }
                globalIndicator.showSuccess(withStatus: "rsvp'd!")
                var text = ""
                if decision == .going {
                    text = "\(globalCurrentUser?.name ?? "") is going"
                } else if decision == .notGoing {
                    text = "\(globalCurrentUser?.name ?? "") can't make it"
                } else {
                    text = "\(globalCurrentUser?.name ?? "") rsvp'd as 'maybe'"
                }
                self.informationMessageSender.sendInformationMessage(channelID: channelID, channelName: channel.name ?? "", participantIDs: [], text: text, channel: channel)
            }
        }
    }
    
    fileprivate func openInMaps(type: String) {
        guard let latitude = channel?.latitude.value, let longitude = channel?.longitude.value else { return }
        
        if type == "apple" {
            let latitude: CLLocationDegrees = latitude
            let longitude: CLLocationDegrees = longitude

            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Event Location"
            mapItem.openInMaps(launchOptions: options)
        } else if type == "google" {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }}
            else {
                //Open in browser
                if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination)
                }
            }


            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app
                if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:])
                }
            } else {
                if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                    UIApplication.shared.open(urlDestination)
                }
            }

        }
    }
    
    func configureMapView() {
        channelDetailsContainerView.locationView.locationNameLabel.text = channel?.locationName
        guard let latitude = channel?.latitude.value, let longitude = channel?.longitude.value else { return }
        if let placemark = channel?.placemark {
            channelDetailsContainerView.locationView.locationLabel.text = parseAddress(selectedItem: placemark)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            channelDetailsContainerView.locationView.mapView.addAnnotation(annotation)
            channelDetailsContainerView.locationView.mapView.showAnnotations([annotation], animated: false)
        } else {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: { [weak self] placemarks, error -> Void in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                guard let placeMark = placemarks?.first else { return }
                let item = MKPlacemark(placemark: placeMark)
                
                if let channel = self?.channel {
                    self?.channel?.placemark = item
                    self?.realmChannelsManager.update(channel: channel)
                }
                
                self?.channelDetailsContainerView.locationView.locationLabel.text = parseAddress(selectedItem: item)
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self?.channelDetailsContainerView.locationView.mapView.addAnnotation(annotation)
                self?.channelDetailsContainerView.locationView.mapView.showAnnotations([annotation], animated: false)
            })
        }
    }
}

extension ChannelDetailsController: CreateChannelDelegate {
    func channel(doneUpdatinigChannel: Bool) {
        if doneUpdatinigChannel {
            goBack()
        }
    }
}

import SafariServices
extension ChannelDetailsController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard interaction != .preview else { return false }
        guard ["http", "https"].contains(URL.scheme?.lowercased() ?? "")  else { return true }
        var svc = SFSafariViewController(url: URL as URL)

        if #available(iOS 11.0, *) {
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true
            svc = SFSafariViewController(url: URL as URL, configuration: configuration)
        }

        svc.preferredControlTintColor = ThemeManager.currentTheme().tintColor
        svc.preferredBarTintColor = ThemeManager.currentTheme().generalBackgroundColor
        self.present(svc, animated: true, completion: nil)
        
        

        return false
    }
}
