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

struct ContextMenuItem {
  var title = ""
//  var image = UIImage()
  var index = 0
}

class ChannelLogController: UIViewController, UIGestureRecognizerDelegate {

    weak var deleteAndExitDelegate: DeleteAndExitDelegate?
    
    var messagesFetcher: MessagesFetcher?
    
    var channel: Channel?
    
    var navigationBarTitleGestureRecognizer: UITapGestureRecognizer?
    private var savedContentOffset: CGPoint!
    var channelListener: ListenerRegistration?
    var typingIndicatorCollectionListener: ListenerRegistration?
    
    var first = true
    let typingIndicatorDatabaseID = "typingIndicator"
    let typingIndicatorStateDatabaseKeyID = "Is typing"
    let messagesToLoad = 25
    var isChannelLogHeaderShowing = false
    var shouldAnimateKeyboardChanges = false
    private var shouldScrollToBottom: Bool = true
    private var localTyping = false
    
    var groupedMessages = [MessageSection]()
    var typingIndicatorSection: [String] = []
    
    let contextMenuItems = [
        ContextMenuItem(title: "Edit", index: 0),
        ContextMenuItem(title: "Remove", index: 1),
        ContextMenuItem(title: "Promote", index: 2)
    ]
    
    private var dayFormatter = DateFormatter()
    private var monthFormatter = DateFormatter()
    private var dayNumericFormatter = DateFormatter()
    private let fullDateFormatter = DateFormatter()
    private let numberFormatter = NumberFormatter()
    private let timeFormatter  = DateFormatter()
    private let channelManager = ChannelManager()
    private let channelsRealmManager = ChannelsRealmManager()
    private let channelLogHistoryFetcher = ChannelLogHistoryFetcher()
    private let keyboardLayoutGuide = KeyboardLayoutGuide()
    public var channelLogContainerView = ChannelLogContainerView()
    public let realm = try! Realm(configuration: RealmKeychain.realmDefaultConfiguration())
    
    public var safeContentHeight: CGFloat {
        // Don't use self.collectionView.contentSize.height as the collection view's
        // content size might not be set yet.
        //
        // We can safely call prepareLayout to ensure the layout state is up-to-date
        // since our layout uses a dirty flag internally to debounce redundant work.
        collectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    private var collectionViewLoaded = false {
        didSet {
            if collectionViewLoaded && shouldScrollToBottom && !oldValue {
                collectionView.scrollToBottom(animated: false)
            }
            
            updateContentInsets(animated: false)
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
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Controller Lifecycle
    
    override func loadView() {
        super.loadView()
        loadViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomScrollButton()
        setupHeaderView()
        addObservers()
        setupNavigationBar()
        createContents()
    }
    
    private func createContents() {
        // We use the root view bounds as the initial frame for the collection
        // view so that its contents can be laid out immediately.
        //
        // TODO: To avoid relayout, it'd be better to take into account safeAreaInsets,
        //       but they're not yet set when this method is called.
        self.collectionView.frame = view.bounds
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.keyboardDismissMode = .interactive
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.addObserver(self, forKeyPath: "contentSize", options: .old, context: nil)
        self.collectionView.addSubview(refreshControl)

        // To minimize time to initial apearance, we initially disable prefetching, but then
        // re-enable it once the view has appeared.
        self.collectionView.isPrefetchingEnabled = false
        
        channelLogHistoryFetcher.delegate = self
        channelManager.delegate = self
        
        channelManager.setupListeners(channel)
        
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = UIRectEdge.bottom
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        configureRefreshControlInitialTintColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
        
        guard let channelParticipants = channel?.participantIds else { return }
        
        if let uid = Auth.auth().currentUser?.uid,
           channelParticipants.contains(uid) {
            if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
                self.navigationController?.navigationBar.addGestureRecognizer(navigationBarTitleGestureRecognizer)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.isPrefetchingEnabled = true
        self.shouldAnimateKeyboardChanges = true
        
        unblockInputViewConstraints()
        
        if savedContentOffset != nil {
            UIView.performWithoutAnimation { [weak self] in
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.view.layoutIfNeeded()
                unwrappedSelf.collectionView.contentOffset = unwrappedSelf.savedContentOffset
            }
        }
        
        setupHeaderView()
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.shouldAnimateKeyboardChanges = true
        if self.navigationController?.visibleViewController is ChannelDetailsController { return }
        isTyping = false
        
        if typingIndicatorCollectionListener != nil {
            typingIndicatorCollectionListener?.remove()
            typingIndicatorCollectionListener = nil
        }
        
        NotificationCenter.default.removeObserver(self)
        channelManager.removeAllListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let viewControllers = self.navigationController?.viewControllers {
            if viewControllers.count > 1 && viewControllers[viewControllers.count-2] == self {
                // do nothing
            } else {
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
        
        // this can get run multiple time when you drag to go back from details controller,
        // but change your mind multiple times
        
        blockInputViewConstraints()
        savedContentOffset = collectionView.contentOffset
        
        if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
            self.navigationController?.navigationBar.removeGestureRecognizer(navigationBarTitleGestureRecognizer)
        }
    }
    
    deinit {
        print("DEINITED LOG")
        NotificationCenter.default.removeObserver(self)
        channelManager.removeAllListeners()
        
    }
    
    // MARK: - skmclsmf
    
    /// fixes bug of not setting refresh control tint color on initial refresh
    fileprivate func configureRefreshControlInitialTintColor() {
        collectionView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
        refreshControl.beginRefreshing()
        refreshControl.endRefreshing()
    }

    func removeChannelListener() {
        if channelListener != nil {
            channelListener?.remove()
            channelListener = nil
        }
    }
    
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // updateContentInsets(animated: false)
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? ChannelCollectionView, observedObject == collectionView {
            collectionViewLoaded = true
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
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
    
    @objc
    func goToChannelDetails() {
        guard let channelID = channel?.id else { return }

        let destination = ChannelDetailsController()
        destination.channelID = channelID

        navigationController?.pushViewController(destination, animated: true)
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
//            view.add(inputContainerView)
//            inputAccessoryView = inputContainerView
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = true
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = false
            navigationBarTitleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToChannelDetails))
        } else {
            messagesFetcher?.removeListener()
//            view.add(inputBlockerContainerView)
            if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
                self.navigationController?.navigationBar.removeGestureRecognizer(navigationBarTitleGestureRecognizer)
            }
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = false
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = true
        }
        self.view = view
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
//        view.addLayoutGuide(keyboardLayoutGuide)
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            if let bottom = window?.safeAreaInsets.bottom {
                view.inputViewContainer.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: 0).isActive = true
            }
        } else {
            view.inputViewContainer.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor).isActive = true
        }
    }
    
    func blockInputViewConstraints() {
        guard let view = view as? ChannelLogContainerView else { return }
        if let constant = keyboardLayoutGuide.topConstant {
            if inputContainerView.inputTextView.isFirstResponder {
                if #available(iOS 13.0, *) {
                    let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
                    if let bottom = window?.safeAreaInsets.bottom {
                        view.blockBottomConstraint(constant: -constant + bottom)
                    }
                } else {
                    view.blockBottomConstraint(constant: -constant)
                }

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
//            self?.deleteAndExitHandler()
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupNavigationBar() {
        setupTitle()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action:  #selector(pleasePopController))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.delegate = self
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
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: .themeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func resetBadgeForSelf() {
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
                self.collectionView.insertSections([groupedMessages.count])
            }, completion: { (isCompleted) in
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
    
    // MARK: - DATABASE MESSAGE STATUS
    func updateMessageStatus(messageRef: DocumentReference) {
        guard let uid = Auth.auth().currentUser?.uid, currentReachabilityStatus != .notReachable else { return }
        var senderID: String?
        
        messageRef.getDocument { (snapshot, error) in
            guard error == nil else { print(error?.localizedDescription ?? "error"); return }
            
            guard let data = snapshot?.data() else { return }
            
            senderID = data["fromId"] as? String
            
            guard uid != senderID,
                  (UIApplication.topViewController() is ChannelLogController ||
                    UIApplication.topViewController() is ChannelDetailsController ||
                    UIApplication.topViewController() is ParticipantsController ||
//                    UIApplication.topViewController() is UpdateChannelController ||
                    UIApplication.topViewController() is INSPhotosViewController ||
                    UIApplication.topViewController() is SFSafariViewController)
            else { senderID = nil; return }
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
        SystemSoundID.playFileNamed(fileName: "sent", withExtenstion: "caf")
        
//        AudioServicesPlaySystemSound (1004)
    }
    
    // MARK: - Title view
    
    func setupTitle() {
        if let title = channel?.name {
            navigationItem.setTitle(title: title, subtitle: "Tap for more information")
        }
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

//        inputContainerView.resignAllResponders()
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
//        inputContainerView.prepareForSend()
        resendTextMessage(channel, message.text, at: indexPath)
    }

    fileprivate func resendTextMessage(_ channel: Channel, _ text: String?, at indexPath: IndexPath) {
        handleResend(channel: channel, text: text, indexPath: indexPath)
    }
    
    fileprivate func handleResend(channel: Channel, text: String?, indexPath: IndexPath) {
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
        navigationController?.popViewController(animated: true)
    }
    
}
