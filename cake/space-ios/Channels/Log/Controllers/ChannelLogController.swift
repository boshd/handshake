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
    var lastOutgoingMessageListener: ListenerRegistration?
    
    var first = true
    let typingIndicatorDatabaseID = "typingIndicator"
    let typingIndicatorStateDatabaseKeyID = "Is typing"
    let messagesToLoad = 25
    var isChannelLogHeaderShowing = false
    var shouldAnimateKeyboardChanges = false
    private var shouldScrollToBottom: Bool = true
    private var localTyping = false
    public var isDismissingInteractively = false
    public var hasAppearedAndHasAppliedFirstLoad = false
    public var canRefresh = true
    public var isKeyboardInitial = true
    
    var groupedMessages = [MessageSection]()
    var typingIndicatorSection: [String] = []
    var typingUserIds: [String] = []
    
    let contextMenuItems = [
        ContextMenuItem(title: "Edit", index: 0)
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
    let nonLocalRealm = try! Realm(configuration: RealmKeychain.realmNonLocalUsersConfiguration())
    public let inputAccessoryPlaceholder = InputAccessoryViewPlaceholder()
    
    public var keyboardHeight = CGFloat()
    
    public var safeContentHeight: CGFloat {
        // Don't use self.collectionView.contentSize.height as the collection view's
        // content size might not be set yet.
        //
        // We can safely call prepareLayout to ensure the layout state is up-to-date
        // since our layout uses a dirty flag internally to debounce redundant work.
        collectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    // The highest valid content offset when the view is at rest.
    internal var maxContentOffsetY: CGFloat {
        let contentHeight = self.safeContentHeight // same as collectionView.contentSize.height
        let adjustedContentInset = collectionView.adjustedContentInset
        let rawValue = contentHeight + adjustedContentInset.bottom - collectionView.bounds.size.height
        // Note the usage of MAX() to handle the case where there isn't enough
        // content to fill the collection view at its current size.
        let clampedValue = max(minContentOffsetY, rawValue)
        return clampedValue
    }
    
    // The lowest valid content offset when the view is at rest.
    private var minContentOffsetY: CGFloat {
        -collectionView.adjustedContentInset.top
    }
    
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
//                Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").document("XevIxNAQAPYxV4OWFhtQOIIJfH33").delete()
//                Firestore.firestore().collection("channels").document(channelID).collection("typingUserIds").document("ZFi01vpuzMhcpJWduO3KuAebDPv2").delete()
            }
        }
    }
    
    let bottomBarContainer: UIView = {
        let inputViewContainer = UIView()
        inputViewContainer.translatesAutoresizingMaskIntoConstraints = false
//        inputViewContainer.blurEffectView = UIVisualEffectView(effect: ThemeManager.currentTheme().tabBarBlurEffect)
        inputViewContainer.backgroundColor = .green
        
        return inputViewContainer
    }()
    
    lazy var inputContainerView: InputContainerView = {
        var inputContainerView = InputContainerView()
        inputContainerView.channelLogController = self
        //inputContainerView.delegate = self
        return inputContainerView
    }()
    
    lazy var inputBlockerContainerView: InputBlockerContainerView = {
        var inputBlockerContainerView = InputBlockerContainerView()
        inputBlockerContainerView.backButton.setTitle("Delete and exit", for: .normal)
        inputBlockerContainerView.backButton.addTarget(self, action: #selector(handleDeleteAndExitEvent), for: .touchUpInside)

        return inputBlockerContainerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            print("inputAccessoryView")
            // This getter is being called twice, it might be because this is an overridden computed property.
            return inputAccessoryPlaceholder
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    private var collectionViewLoaded = false {
        didSet {
            if collectionViewLoaded && shouldScrollToBottom && !oldValue {
                scrollToBottom(animated: false)
            }
        }
    }

    lazy var collectionView: ChannelCollectionView = {
        let collectionView = ChannelCollectionView()
        
        collectionView.isUserInteractionEnabled = true
        collectionView.allowsSelection = false
        collectionView.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        
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
        self.inputAccessoryPlaceholder.delegate = self
        
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
    func scrollToBottom(animated: Bool) {
        view.layoutIfNeeded()
        collectionView.setContentOffset(bottomOffset(), animated: animated)
    }
     
    func bottomOffset() -> CGPoint {
        return CGPoint(x: 0, y: max(-collectionView.contentInset.top, collectionView.contentSize.height - (collectionView.bounds.size.height - collectionView.contentInset.bottom - 20)))
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear \(collectionView.contentSize)")
        super.viewWillAppear(animated)
        becomeFirstResponder()
//        scrollToBottom(animated: false)
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
        print("viewDidAppear \(collectionView.contentSize)")
        self.hasAppearedAndHasAppliedFirstLoad = true
        
        self.collectionView.isPrefetchingEnabled = true
        self.shouldAnimateKeyboardChanges = true
        
        //unblockInputViewConstraints()
//        
//        if savedContentOffset != nil {
//            UIView.performWithoutAnimation { [weak self] in
//                guard let unwrappedSelf = self else { return }
//                unwrappedSelf.view.layoutIfNeeded()
//                unwrappedSelf.collectionView.contentOffset = unwrappedSelf.savedContentOffset
//            }
//        }
        
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
                if lastOutgoingMessageListener != nil {
                    lastOutgoingMessageListener?.remove()
                    lastOutgoingMessageListener = nil
                }
                messagesFetcher?.collectionDelegate = nil
                messagesFetcher?.delegate = nil
            }
        }
        
        // this can get run multiple time when you drag to go back from details controller,
        // but change your mind multiple times
        
        //blockInputViewConstraints()
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
    
    // MARK: - Setup/config
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
        
//        if let view = inputAccessoryView {
//            bottomScrollConainer.centerXAnchor.constraint(equalTo: view.centerXAnchor,
//            constant: 0).isActive = true
//            bottomScrollConainer.bottomAnchor.constraint(equalTo:  view.topAnchor,
//            constant: -10).isActive = true
//        }

    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: .themeUpdated, object: nil)
    }
    
    // MARK: - Misc.
    
//    func scrollToBottom(animated: Bool) {
//        let newContentOffset = CGPoint(x: 0, y: maxContentOffsetY)
//        collectionView.setContentOffset(newContentOffset, animated: animated)
//    }
    
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
        print("viewSafeAreaInsetsDidChange \(collectionView.contentSize)")
         updateContentInsets(animated: false)
//        scrollToBottom(animated: false)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if let observedObject = object as? ChannelCollectionView, observedObject == collectionView {
            print("observeValue")
            collectionViewLoaded = true
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
        
    }
    
//    public func inputAccessoryPlaceholderKeyboardIsDismissingInteractively() {
//
//        // No animation, just follow along with the keyboard.
//        self.isDismissingInteractively = true
//        print("inputAccessoryPlaceholderKeyboardIsDismissingInteractively")
//        self.isDismissingInteractively = false
//    }
    
    @objc private func instantMoveToBottom() {
        hapticFeedback(style: .impact)
        scrollToBottom(animated: true)
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
    
//    func configureCellContextMenuView() -> FTConfiguration {
//        let config = FTConfiguration()
//        config.backgoundTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
//        config.borderColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.0)
//        config.menuWidth = 100
//        config.menuSeparatorColor = .clear
//        config.menuRowHeight = 40
//        config.cornerRadius = 25
//        config.textAlignment = .center
//        return config
//    }
    
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
        
        guard let channel = channel else { return }

        if let uid = Auth.auth().currentUser?.uid,
           channel.participantIds.contains(uid) {
            inputAccessoryPlaceholder.add(inputContainerView)
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = true
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = false
            navigationBarTitleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToChannelDetails))
        } else {
            messagesFetcher?.removeListener()
            inputAccessoryPlaceholder.add(inputBlockerContainerView)
            if let navigationBarTitleGestureRecognizer = navigationBarTitleGestureRecognizer {
                self.navigationController?.navigationBar.removeGestureRecognizer(navigationBarTitleGestureRecognizer)
            }
            channelLogContainerView.channelLogHeaderView.isUserInteractionEnabled = false
            channelLogContainerView.channelLogHeaderView.viewDetails.isHidden = true
        }
        self.view = view
    }

//    func reloadInputView(view: UIView) {
////        if let currentView = self.view as? ChannelLogContainerView {
////            DispatchQueue.main.async {
////                currentView.add(view)
////            }
////        }
//    }
    
//    private func setupInputView() {
//        guard let view = view as? ChannelLogContainerView else {
//            fatalError("Root view is not ChannelLogContainerView")
//        }
////        view.addLayoutGuide(keyboardLayoutGuide)
//
//        if #available(iOS 13.0, *) {
//            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
//            if let bottom = window?.safeAreaInsets.bottom {
////                view.inputViewContainer.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: 0).isActive = true
//            }
//        } else {
////            view.inputViewContainer.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor).isActive = true
//        }
//    }
//
//    func blockInputViewConstraints() {
//        guard let view = view as? ChannelLogContainerView else { return }
//        if let constant = keyboardLayoutGuide.topConstant {
//            if inputContainerView.inputTextView.isFirstResponder {
//                if #available(iOS 13.0, *) {
//                    let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
//                    if let bottom = window?.safeAreaInsets.bottom {
//                        view.blockBottomConstraint(constant: -constant + bottom)
//                    }
//                } else {
//                    view.blockBottomConstraint(constant: -constant)
//                }
//
//                view.layoutIfNeeded()
//            }
//        }
//    }
//
//    func unblockInputViewConstraints() {
//        guard let view = view as? ChannelLogContainerView else { return }
//        view.unblockBottomConstraint()
//    }
    
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
    
    func resetBadgeForSelf() {
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
    
    @objc func pleasePopController() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupTitle() {
        if let title = channel?.name {
            navigationItem.setTitle(title: title, subtitle: "Tap for more information")
        }
    }
    
}
