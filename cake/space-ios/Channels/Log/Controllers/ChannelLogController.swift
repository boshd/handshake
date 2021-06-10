//
//  ChannelLogController_.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-15.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Photos
import AudioToolbox
import SafariServices
import RealmSwift
import Firebase
import AVFoundation
import FTPopOverMenu_Swift

protocol DeleteAndExitDelegate: class {
    func deleteAndExit(from channelID: String)
}

class ChannelLogController: UIViewController, UIGestureRecognizerDelegate {

    weak var deleteAndExitDelegate: DeleteAndExitDelegate?
    
    var messagesFetcher: MessagesFetcher?
    
    var channel: Channel?
    
    let typingIndicatorDatabaseID = "typingIndicator"
    let typingIndicatorStateDatabaseKeyID = "Is typing"
    
    var groupedMessages = [MessageSection]()
    var typingIndicatorSection: [String] = []
    
    var dayFormatter = DateFormatter()
    var monthFormatter = DateFormatter()
    var dayNumericFormatter = DateFormatter()
    let fullDateFormatter = DateFormatter()
    let numberFormatter = NumberFormatter()
    let timeFormatter  = DateFormatter()
    
    var channelListener: ListenerRegistration?
    var typingIndicatorCollectionListener: ListenerRegistration?
    
    let channelManager = ChannelManager()

    let realm = try! Realm(configuration: RealmKeychain.realmDefaultConfiguration())
    let channelsRealmManager = ChannelsRealmManager()
    let messagesToLoad = 25
    let channelLogHistoryFetcher = ChannelLogHistoryFetcher()

    private var shouldScrollToBottom: Bool = true
    private let keyboardLayoutGuide = KeyboardLayoutGuide()
    
    var channelLogContainerView = ChannelLogContainerView()
    
    private var collectionViewLoaded = false {
        didSet {
            if collectionViewLoaded && shouldScrollToBottom && !oldValue {
                collectionView.scrollToBottom(animated: false)
            }
        }
    }
    
    lazy var inputContainerView: InputContainerView = {
        var channelInputContainerView = InputContainerView()
        channelInputContainerView.channelLogController = self

        return channelInputContainerView
    }()
    
    lazy var inputBlockerContainerView: InputBlockerContainerView = {
        var inputBlockerContainerView = InputBlockerContainerView()
        inputBlockerContainerView.backButton.setTitle("Delete and exit", for: .normal)
        inputBlockerContainerView.backButton.addTarget(self, action: #selector(handleDeleteAndExitEvent), for: .touchUpInside)

        return inputBlockerContainerView
    }()

    lazy var collectionView: ChannelCollectionView = {
        let collectionView = ChannelCollectionView()
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = false
        
        return collectionView
    }()

    lazy var refreshControl: UIRefreshControl = {
        var refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        refreshControl.tintColor = ThemeManager.currentTheme().generalTitleColor
        refreshControl.addTarget(self, action: #selector(performRefresh), for: .valueChanged)

        return refreshControl
    }()
    
    lazy var bottomScrollConainer: BottomScrollContainer = {
        var bottomScrollContainer = BottomScrollContainer()
        bottomScrollContainer.scrollButton.addTarget(self, action: #selector(instantMoveToBottom), for: .touchUpInside)
        bottomScrollContainer.isHidden = true
        return bottomScrollContainer
    }()
    
    /* fixes bug of not setting refresh control tint color on initial refresh */
    fileprivate func configureRefreshControlInitialTintColor() {
        collectionView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
        refreshControl.endRefreshing()
    }
    
    @objc private func instantMoveToBottom() {
        hapticFeedback(style: .impact)
        collectionView.scrollToBottom(animated: true)
    }

    @objc func performRefresh() {
        refreshControl.endRefreshing()
        guard let channel = self.channel else { return }
        let allMessages = groupedMessages.flatMap { (sectionedMessage) -> Results<Message> in
            return sectionedMessage.messages
        }
        channelLogHistoryFetcher.loadPreviousMessages(allMessages, channel, messagesToLoad)
    }
    
    @objc func goToChannelDetails() {
        hapticFeedback(style: .selectionChanged)
        guard let channelID = channel?.id else { return }

        let destination = ChannelDetailsController()
        destination.channel = RealmKeychain.defaultRealm.object(ofType: Channel.self, forPrimaryKey: channelID)
        navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - Controller Lifecycle
    override func loadView() {
        super.loadView()
        loadViews()
        configureController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTitleName()
        setupInputView()
        setupBottomScrollButton()
        setupHeaderView()
        addObservers()
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        guard let channel = channel else { return }
        
        if let uid = Auth.auth().currentUser?.uid,
           channel.participantIds.contains(uid) {
            if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
                self.navigationController?.navigationBar.addGestureRecognizer(navigationBarTitleGestureRecognizer)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        unblockInputViewConstraints()
        
        if savedContentOffset != nil {
            UIView.performWithoutAnimation { [weak self] in
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.view.layoutIfNeeded()
                unwrappedSelf.collectionView.contentOffset = unwrappedSelf.savedContentOffset
            }
        }
        
        setupHeaderView()
        checkChannelStateAndPermissions()
        
        if let uid = Auth.auth().currentUser?.uid, let channel = channel, channel.participantIds.contains(uid) {
            if typingIndicatorCollectionListener == nil  {
                observeTypingIndicator()
            }
        }
        
        if collectionView.numberOfSections == groupedMessages.count + 1 {
            guard let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: groupedMessages.count)) as? TypingIndicatorCell else { return }
            cell.restart()
        }
    }
    var navigationBarTitleGestureRecognizer: UITapGestureRecognizer?
    private var savedContentOffset: CGPoint!
//    var goingForwards = false
    
    func removeChannelListener() {
        if channelListener != nil {
            channelListener?.remove()
            channelListener = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        isTyping = false
        
        if typingIndicatorCollectionListener != nil {
            typingIndicatorCollectionListener?.remove()
            typingIndicatorCollectionListener = nil
            //typingIndicatorReference.removeObserver(withHandle: typingIndicatorHandle)
        }

    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let viewControllers = self.navigationController?.viewControllers {
            print("viewcontrollers not nil")
            if viewControllers.count > 1 && viewControllers[viewControllers.count-2] == self {
                print("forwards")
            } else {
                print("backwards")
                removeChannelListener()

                for message in groupedMessages {
                    message.notificationToken?.invalidate()
                }

                channelLogPresenter.tryDeallocate()

                messagesFetcher?.removeListener()
                messagesFetcher?.collectionDelegate = nil
                messagesFetcher?.delegate = nil
            }
        }
        
        
//        if self.isMovingFromParent {
//            print("pushed")
//        } else if self.isMovingToParent {
//            print("popped")
//            removeChannelListener()
//
//            for message in groupedMessages {
//                message.notificationToken?.invalidate()
//            }
//
//            channelLogPresenter.tryDeallocate()
//
//            messagesFetcher?.removeListener()
//            messagesFetcher?.collectionDelegate = nil
//            messagesFetcher?.delegate = nil
//        }
        blockInputViewConstraints()
        savedContentOffset = collectionView.contentOffset
        
//        resignFirstResponder()
        if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
            self.navigationController?.navigationBar.removeGestureRecognizer(navigationBarTitleGestureRecognizer)
        }
//        inputContainerView.inputTextView.endEditing(true)
    }
    
    deinit {
        print("DEINITED LOG")
        NotificationCenter.default.removeObserver(self)
        channelManager.removeAllListeners()
        
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? ChannelCollectionView, observedObject == collectionView {
            collectionViewLoaded = true
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    func configureController() {
        channelManager.delegate = self
        channelManager.setupListeners(channel)
    }
    
    func configureCellContextMenuView() -> FTConfiguration {
        let config = FTConfiguration()
        config.backgoundTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        config.borderColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.0)
        config.menuWidth = 100
        config.menuSeparatorColor = .clear
        config.menuRowHeight = 40
        config.cornerRadius = 25
        config.textAlignment = .center
        return config
    }
    
    func getMessages() {
        let dates = channel!.messages.map({ $0.shortConvertedTimestamp ?? "" })
        let uniqueDates = Array(Set(dates))
        guard uniqueDates.count > 0 else { return }

        let keys = uniqueDates.sorted(by: { (time1, time2) -> Bool in
            return Date.dateFromCustomString(customString: time1) < Date.dateFromCustomString(customString: time2)
        })

        var loadedCount = 0

        autoreleasepool {
            for date in keys.reversed() {

                var messages = channel!.messages.filter("shortConvertedTimestamp == %@", date)
                messages = messages.sorted(byKeyPath: "timestamp", ascending: true)

                if messages.count > messagesToLoad {
                    var numberToLoad = 0
                    if loadedCount < messagesToLoad {
                        numberToLoad = messagesToLoad - loadedCount

                        messages = messages.filter("timestamp >= %@", messages[messages.count - numberToLoad].timestamp.value ?? "")
                    } else {
                        break
                    }
                }

                if loadedCount >= messagesToLoad {
                    break
                } else {
                    loadedCount += messages.count
                }
                
                let section = MessageSection(messages: messages, title: date)
                groupedMessages.insert(section, at: 0)
            }
        }
    }
    
    // MARK: - Setup

    private func loadViews() {
        let view = channelLogContainerView
        view.add(collectionView)
        collectionView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
        guard let channel = channel else { return }

        if let uid = Auth.auth().currentUser?.uid,
           channel.participantIds.contains(uid) {
            view.add(inputContainerView)
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = true
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = false
            navigationBarTitleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToChannelDetails))
            configurePlaceholderTitleView()
        } else {
            messagesFetcher?.removeListener()
            view.add(inputBlockerContainerView)
            if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
                self.navigationController?.navigationBar.removeGestureRecognizer(navigationBarTitleGestureRecognizer)
            }
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = false
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = true
        }
        self.view = view
    }
    
    func checkChannelStateAndPermissions() {
        guard let channel = channel else { return }
        
        if let uid = Auth.auth().currentUser?.uid,
           channel.participantIds.contains(uid) {
            reloadInputView(view: inputContainerView)
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = true
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = false
            configurePlaceholderTitleView()
        } else {
            messagesFetcher?.removeListener()
            reloadInputView(view: inputBlockerContainerView)
            if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
                self.navigationController?.navigationBar.removeGestureRecognizer(navigationBarTitleGestureRecognizer)
            }
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = false
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = true
        }
    }

    func reloadInputView(view: UIView) {
        if let currentView = self.view as? ChannelLogContainerView {
            DispatchQueue.main.async {
                currentView.add(view)
            }
        }
    }
    
    private func setupInputView() {
        guard let view = view as? ChannelLogContainerView else {
            fatalError("Root view is not ChannelLogContainerView")
        }
        view.addLayoutGuide(keyboardLayoutGuide)
        view.inputViewContainer.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    func blockInputViewConstraints() {
        guard let view = view as? ChannelLogContainerView else { return }
        if let constant = keyboardLayoutGuide.topConstant {
            if inputContainerView.inputTextView.isFirstResponder {
                view.blockBottomConstraint(constant: -constant)
                view.layoutIfNeeded()
            }
        }
    }

    func unblockInputViewConstraints() {
        guard let view = view as? ChannelLogContainerView else { return }
        view.unblockBottomConstraint()
    }
    
    @objc func closeChatLog() {
        channelLogPresenter.tryDeallocate(force: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarStyle
    }
    
    @objc
    func handleDeleteAndExitEvent() {
        hapticFeedback(style: .impact)
        guard let channelID = channel?.id else { return }
        let alert = CustomAlertController(title_: "Confirmation", message: "Are you sure you want to delete and exit this event?", preferredStyle: .alert)
        alert.addAction(CustomAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(CustomAlertAction(title: "Yes", style: .destructive, handler: { [weak self] in
//            let obj: [String: Any] = ["channelID": channelID]
//            NotificationCenter.default.post(name: .deleteAndExit, object: obj)
            self?.deleteAndExitHandler()
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action:  #selector(pleasePopController))
////        backButton.tintColor = ThemeManager.currentTheme().tintColor
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
//
//        if let navigationBar = navigationController?.navigationBar {
//            ThemeManager.setNavigationBarAppearance(navigationBar)
//        }
        
//        let btnProfile = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
////        btnProfile.setTitle("SY", for: .normal)
//        btnProfile.setImage(UIImage(named: "ctrl-left"), for: .normal)
//        btnProfile.backgroundColor = .handshakeLightPurple
//        btnProfile.layer.cornerRadius = 20
//        btnProfile.layer.cornerCurve = .circular
//        btnProfile.tintColor = ThemeManager.currentTheme().buttonIconColor
//        btnProfile.layer.masksToBounds = true
////        Now create the UIBarButtonItem from that button and set it with the rightBarButtonItems.
//
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnProfile)
    }

    private func setupBottomScrollButton() {
        view.addSubview(bottomScrollConainer)
        bottomScrollConainer.translatesAutoresizingMaskIntoConstraints = false
        bottomScrollConainer.widthAnchor.constraint(equalToConstant: 40).isActive = true
        bottomScrollConainer.heightAnchor.constraint(equalToConstant: 40).isActive = true

        guard let view = view as? ChannelLogContainerView else {
            fatalError("Root view is not ChatLogContainerView")
        }

        bottomScrollConainer.centerXAnchor.constraint(equalTo: view.inputViewContainer.centerXAnchor,
        constant: 0).isActive = true
        bottomScrollConainer.bottomAnchor.constraint(equalTo: view.inputViewContainer.topAnchor,
        constant: -10).isActive = true
    }
    
    private func setupCollectionView() {
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = UIRectEdge.bottom
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        setupNavigationBar()

        collectionView.delegate = self
        collectionView.dataSource = self
        channelLogHistoryFetcher.delegate = self

        collectionView.addObserver(self, forKeyPath: "contentSize", options: .old, context: nil)

        collectionView.addSubview(refreshControl)
        configureRefreshControlInitialTintColor()
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelRemoved), name: .channelRemoved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteAndExitHandler), name: .deleteAndExit, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChannelStatusUpdated), name: .channlStatusUpdated, object: nil)
    }
    
    func listenToChannelChanges() {
        guard let channelID = channel?.id, let currentUserID = Auth.auth().currentUser?.uid else { return }
        let channelReference = Firestore.firestore().collection("channels").document(channelID)
        channelListener = channelReference.addSnapshotListener { [weak self] (snapshot, error) in
            guard let unwrappedSelf = self else { return }
            if error != nil {
                print(error?.localizedDescription ?? "error")
                return
            }
            
            let oldChannel = self?.channel

            guard let data = snapshot?.data() as [String:AnyObject]? else { return }
            let newChannel = Channel(dictionary: data)
            self?.channel = newChannel
            if let messages = oldChannel?.messages, newChannel.participantIds.contains(currentUserID) {
                self?.channel?.messages = messages
                
                if newChannel.lastMessageId == oldChannel?.lastMessageId {
                    unwrappedSelf.checkChannelStateAndPermissions()
                }

                if newChannel.name != oldChannel?.name {
                    unwrappedSelf.setupTitleName()
                }

                if (newChannel.startTime != oldChannel?.startTime) || (newChannel.locationName != oldChannel?.locationName) {
                    unwrappedSelf.setupHeaderView()
                }
            }
            
        }
    }
    
    @objc func handleChannelStatusUpdated(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let channelID = obj["channelID"] as? String,
              let currentChannelID = channel?.id,
              channelID == currentChannelID else { return }
        setupHeaderView()
        checkChannelStateAndPermissions()
    }
    
    @objc func handleChannelUpdated(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let channel = obj["channel"] as? Channel,
              let channelID = obj["channelID"] as? String,
              let currentChannelID = channel.id,
              channelID == currentChannelID else { return }
        
        self.channel = channel
    }
    
    @objc func handleChannelRemoved(_ notification: Notification) {}
    
    
    fileprivate func resetBadgeForSelf() {
        print("resetting badge for self...")
        guard let unwrappedChannel = channel else { return }
        let channelObject = ThreadSafeReference(to: unwrappedChannel)
        guard let channel = realm.resolve(channelObject) else { return }
        
        guard let toId = channel.id,
              let currentUserID = Auth.auth().currentUser?.uid
        else { return }
        
        Firestore.firestore().collection("users").document(currentUserID).collection("channelIds").document(toId).setData([
            "badge": 0
        ], merge: true) { (error) in
            if error != nil { print("error // ", error?.localizedDescription ?? "error") }
        }
    }

    @objc
    fileprivate func deleteAndExitHandler() {
        print("HERE AT CHATLOG")
        guard let channelID = channel?.id else { return }
        NotificationCenter.default.removeObserver(self)
        removeChannelListener()
        messagesFetcher?.removeListener()
        messagesFetcher?.collectionDelegate = nil
        messagesFetcher?.delegate = nil
        deleteAndExitDelegate?.deleteAndExit(from: channelID)
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    fileprivate func eventCancelledHandler() {
        reloadInputView(view: inputBlockerContainerView)
    }

    @objc private func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        channelLogContainerView.channelLogHeaderView.setColors()
        channelLogContainerView.inputViewContainer.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        inputContainerView.inputTextView.changeTheme()
        inputContainerView.setColors()
        refreshControl.tintColor = ThemeManager.currentTheme().generalTitleColor
        collectionView.updateColors()

        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        
        func updateTypingIndicatorIfNeeded() {
            if collectionView.numberOfSections == groupedMessages.count + 1 {
                guard let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? TypingIndicatorCell else { return }
                cell.restart()
            }
        }
        updateTypingIndicatorIfNeeded()

        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setupHeaderView() {
        // start & end time
        guard let channel = channel else { return }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToChannelDetails))
        tapRecognizer.delaysTouchesBegan = false
        channelLogContainerView.channelLogHeaderView.addGestureRecognizer(tapRecognizer)
        
        let startDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel.startTime.value ?? 0)))
        
        fullDateFormatter.dateFormat = "EEEE, MMM d • h:mm a"
        monthFormatter.dateFormat = "MMM"
        dayFormatter.dateFormat = "EEEE"
        timeFormatter.dateFormat = "h:mm a"
        
        channelLogContainerView.channelLogHeaderView.timeLabel.text = "\(fullDateFormatter.string(from: startDate))"
        
//        if let startTime = channel.startTime.value, let endTime = channel.endTime.value {
//            channelLogContainerView.channelLogHeaderView.dateLabel.text = getDateString(startTime: startTime, endTime: endTime)
//        }
        
        if let locationName = channel.locationName {
            channelLogContainerView.channelLogHeaderView.locationNameLabel.text = "\(locationName)"
        } else {
            if let remote = channel.isRemote.value, remote {
                channelLogContainerView.channelLogHeaderView.locationNameLabel.text = "Remote event"
            }
        }
    }
    
    // MARK: - DATABASE TYPING INDICATOR // TO MOVE
    private var localTyping = false

    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }
            let typingData: NSDictionary = [currentUserID: newValue]
            if localTyping {
                sendTypingStatus(data: typingData)
            } else {
                guard let channelID = channel?.id else { return }
                Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").document(currentUserID).delete()
            }
        }
    }
    
    func sendTypingStatus(data: NSDictionary) {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channel?.id
        else { return }
        Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").document(currentUserID).setData(data as! [String : Any], merge: true)
    }
    
    func observeTypingIndicator() {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let channelID = channel?.id
        else { return }
        
        typingIndicatorCollectionListener = Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                self.handleTypingIndicatorAppearance(isEnabled: false)
                return
            }
            
            guard let empty = snapshot?.isEmpty else { return }
            
            if empty {
                self.handleTypingIndicatorAppearance(isEnabled: false)
            }
            
            snapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    print("added")
                    if change.document.documentID != currentUserID {
                        self.handleTypingIndicatorAppearance(isEnabled: true)
                    }
                    
                }
                if change.type == .removed {
                    if let count = snapshot?.documents.count, count < 1 {
                        self.handleTypingIndicatorAppearance(isEnabled: false)
                    }
                }
            })
            
        }
    }
    
    func handleTypingIndicatorAppearance(isEnabled: Bool) {
        if isEnabled {
            guard collectionView.numberOfSections == groupedMessages.count else { return }
            hapticFeedback(style: .selectionChanged)
            self.typingIndicatorSection = ["TypingIndicator"]
            self.collectionView.performBatchUpdates ({
                print("inserting")
                self.collectionView.insertSections([groupedMessages.count])
            }, completion: { (isCompleted) in
                print(isCompleted)
                if self.isScrollViewAtTheBottom() {
                    if self.collectionView.contentSize.height < self.collectionView.bounds.height {
                        return
                    }
                    self.collectionView.scrollToBottom(animated: true)
                }
            })
        } else {
            guard collectionView.numberOfSections == groupedMessages.count + 1 else { return }
            self.collectionView.performBatchUpdates ({
                self.typingIndicatorSection.removeAll()

                if self.collectionView.numberOfSections > groupedMessages.count {
                    self.collectionView.deleteSections([groupedMessages.count])

                    guard let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: groupedMessages.count)) as? TypingIndicatorCell else {
                        return
                    }
                    cell.typingIndicator.stopAnimating()
                    if isScrollViewAtTheBottom() {
                        collectionView.scrollToBottom(animated: true)
                    }
                }
            }, completion: nil)
        }
    }
    
    // MARK: - Keyboard

    @objc open dynamic func keyboardWillShow(_ notification: Notification) {
        if isScrollViewAtTheBottom() {
            collectionView.scrollToBottom(animated: false)
        }

//        channelLogContainerView.headerHeightConstraint?.constant = 1
        
        channelLogContainerView.headerTopConstraint?.constant = -75

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

    }

    @objc open dynamic func keyboardWillHide(_ notification: Notification) {
        if channelLogContainerView.headerTopConstraint?.constant == -75 {
            channelLogContainerView.headerTopConstraint?.constant = 10

            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    // MARK: - DATABASE MESSAGE STATUS
    func updateMessageStatus(messageRef: DocumentReference) {
        print("arrived")
        guard let uid = Auth.auth().currentUser?.uid, currentReachabilityStatus != .notReachable else { return }
        var senderID: String?
        
        messageRef.getDocument { (snapshot, error) in
            guard error == nil else { print(error?.localizedDescription ?? "error"); return }
            
            guard let data = snapshot?.data() else { return }
            
            senderID = data["fromId"] as? String
            print("in here")
            print(UIApplication.topViewController())
            
            guard uid != senderID,
                  (UIApplication.topViewController() is ChannelLogController ||
                    UIApplication.topViewController() is ChannelDetailsController ||
                    UIApplication.topViewController() is ParticipantsController ||
//                    UIApplication.topViewController() is UpdateChannelController ||
                    UIApplication.topViewController() is INSPhotosViewController ||
                    UIApplication.topViewController() is SFSafariViewController)
            else { senderID = nil; print("stuck hererer"); return }
            print("in here2")
            messageRef.updateData([
                "seen": true,
                "status": messageStatusRead
            ]) { (error) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                }
                self.resetBadgeForSelf()
            }
        }
    }
    
    func updateMessageStatusUI(sentMessage: Message) {
        guard let messageToUpdate = channel?.messages.filter("messageUID == %@", sentMessage.messageUID ?? "").first else { return }
        try! realm.safeWrite {
            messageToUpdate.status = sentMessage.status
            let section = collectionView.numberOfSections - 1
            if section >= 0 {
                let index = self.collectionView.numberOfItems(inSection: section) - 1
                if index >= 0 {
                    UIView.performWithoutAnimation { [weak self] in
                        self?.collectionView.reloadItems(at: [IndexPath(item: index, section: section)] )
                    }
                }
            }
        }
        guard sentMessage.status == messageStatusDelivered,
        messageToUpdate.messageUID == self.groupedMessages.last?.messages.last?.messageUID,
        userDefaults.currentBoolObjectState(for: userDefaults.inAppSounds) else { return }
//        SystemSoundID.playFileNamed(fileName: "sent", withExtenstion: "caf")
        
        AudioServicesPlaySystemSound (1004)
    }
    
    // MARK: - Title view
    
    func setupTitleName() {
        guard let _ = Auth.auth().currentUser?.uid, let _ = channel?.id else { return }
        self.title = channel?.name ?? ""
    }

    func configurePlaceholderTitleView() {
        if let title = channel?.name,
           let _ = channel?.participantIds.count {
            self.title = title
            navigationBarTitleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToChannelDetails))
            if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
                self.navigationController?.navigationBar.addGestureRecognizer(navigationBarTitleGestureRecognizer)
            }
            return
        }
    }
    
    func configureTitleView() {

        if let title = channel?.name, let membersCount = channel?.participantIds.count {
            navigationItem.setTitle(title: title, subtitle: "\(String(membersCount)) attendees")
            return
        }

        guard let _ = Auth.auth().currentUser?.uid, let _ = channel?.id else { return }
    }

    // MARK: Scroll view
    func isScrollViewAtTheBottom() -> Bool {
        if collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.frame.size.height - 450) {
            return true
        }
        return false
    }

    private var canRefresh = true

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollViewAtTheBottom() {
            DispatchQueue.main.async {
                self.bottomScrollConainer.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.bottomScrollConainer.isHidden = false
            }
        }

        if scrollView.contentOffset.y <= 0 { //change 100 to whatever you want
            if collectionView.contentSize.height < UIScreen.main.bounds.height - 50 {
                canRefresh = false
            }

            if canRefresh && !refreshControl.isRefreshing {
                canRefresh = false
                refreshControl.beginRefreshing()
                performRefresh()
            }
        } else if scrollView.contentOffset.y >= 0 {
            canRefresh = true
        }
    }
    
    // MARK: Messages sending
    @objc func sendMessage() {
        hapticFeedback(style: .impact)
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        isTyping = false
        let text = inputContainerView.inputTextView.text
        inputContainerView.prepareForSend()
        guard let channel = self.channel else { return }
        let messageSender = MessageSender(realmChannel(from: channel), text: text)
        messageSender.delegate = self
        messageSender.sendMessage()
    }
    
    @objc func presentResendActions(_ sender: UIButton) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let resendAction = UIAlertAction(title: "Resend", style: .default) { (action) in
            self.resendMessage(sender)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(resendAction)
        controller.addAction(cancelAction)

        inputContainerView.resignAllResponders()
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func resendMessage(_ sender: UIButton) {
        let point = collectionView.convert(CGPoint.zero, from: sender)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        guard let channel = self.channel else { return }
        let message = groupedMessages[indexPath.section].messages[indexPath.row]

        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        isTyping = false
        inputContainerView.prepareForSend()
        resendTextMessage(channel, message.text, at: indexPath)
    }

    fileprivate func resendTextMessage(_ channel: Channel, _ text: String?, at indexPath: IndexPath) {
        handleResend(channel: channel, text: text, indexPath: indexPath)
    }
    
    fileprivate func handleResend(channel: Channel, text: String?, indexPath: IndexPath) {
        print("gonna send")
        let messageSender = MessageSender(channel, text: text)
        messageSender.delegate = self
        messageSender.sendMessage()

        deleteLocalMessage(at: indexPath)
    }
    
    fileprivate func deleteLocalMessage(at indexPath: IndexPath) {
        let message = groupedMessages[indexPath.section].messages[indexPath.row]
        try! realm.safeWrite {
            guard let object = realm.object(ofType: Message.self, forPrimaryKey: message.messageUID ?? "") else { return }
            realm.delete(object)

            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            }, completion: nil)
        }
    }
    
    fileprivate func realmChannel(from channel: Channel) -> Channel {
        guard realm.objects(Channel.self).filter("id == %@", channel.id ?? "").first == nil else { return channel }
        try! realm.safeWrite {
            realm.create(Channel.self, value: channel, update: .modified)
        }

        let newChannel = realm.objects(Channel.self).filter("id == %@", channel.id ?? "").first
        self.channel = newChannel
        return newChannel ?? channel
    }
    
    // MARK: - Misc.
    
    @objc func pleasePopController() {
        hapticFeedback(style: .impact)
        navigationController?.popViewController(animated: true)
    }
    
}
