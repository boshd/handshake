//
//  CustomAlertController.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-03.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class CustomAlertController: UIViewController {
    
    public enum Style : Int {
        case actionSheet = 0
        case alert = 1
    }
    
    var title_: String?
    var message: String?
    var preferredStyle: Style?
    
    private var actionSheetContainerView = ActionSheetContainerView(frame: CGRect.zero)
    private var alertContainerView = AlertContainerView(frame: CGRect.zero)
    
    var actions = [CustomAlertAction]()
    private var buttons = [CustomAlertButton]()
    private var cancelButtons = [CustomAlertButton]()
    var textFields = [CustomAlertTextField]()
    
    private let CONSTANT_ACTION_BUTTON_SIZE = 60.0
    private let CONSTANT_ALERT_BUTTON_SIZE = 45.0
    private let CONSTANT_TEXT_FIELD_HEIGHT = CGFloat(30.0)
    
    private var action_view_y_position = 0.0
    private var alert_view_y_position = 0.0
    
    init(title_: String?, message: String?, preferredStyle: CustomAlertController.Style) {
        super.init(nibName: nil, bundle: nil)
        self.title_ = title_
        self.message = message
        self.preferredStyle = preferredStyle
        modalPresentationStyle = .custom
        transitioningDelegate = self
        
        if preferredStyle == .alert {
            modalTransitionStyle = .crossDissolve
        }
    }
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        switch preferredStyle {
            case .actionSheet:
                calculateViewSizeForActionController()
            case .alert:
                calculateViewSizeForAlertController()
            case .none:
                break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration & view setup
    
    private func setupView() {
        switch preferredStyle {
        case .actionSheet:
            setupActionSheetContainerView()
        case .alert:
            setupAlertContainerView()
        case .none:
            break
        }
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
    
    @objc private func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        if preferredStyle == .actionSheet {
            actionSheetContainerView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            actionSheetContainerView.headerView.backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
            actionSheetContainerView.titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
            actionSheetContainerView.detailsLabel.textColor = ThemeManager.currentTheme().generalTitleColor
            actionSheetContainerView.reloadButtons()
        } else {
            alertContainerView.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            alertContainerView.headerView.backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
            alertContainerView.titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
            alertContainerView.detailsLabel.textColor = ThemeManager.currentTheme().generalTitleColor
            alertContainerView.reloadButtons()
        }
    }
    
    private func setupActionSheetContainerView() {
        guard cancelButtons.count <= 1 else { fatalError("Cannot have multiple cancel buttons") }
        if let title = title_, let message = message { actionSheetContainerView.addHeaderView(title: title, details: message) }
        if actions.count > 0  { actionSheetContainerView.addButtonStackView(buttons: buttons) }
        if cancelButtons.count == 1 {
            if let button = cancelButtons.first {
                actionSheetContainerView.addCancelButton(button: button)
            }
        }
        view = actionSheetContainerView
    }
    
    private func setupAlertContainerView() {
        if let title = title_, let message = message, textFields.count == 1 {
            alertContainerView.addHeaderViewWithTextField(title: title, details: message, textField: textFields.first!)
        } else if let title = title_, let message = message {
            alertContainerView.addHeaderView(title: title, details: message)
        }
        
        
        
        if actions.count > 0 && actions.count < 3 && textFields.count == 0 {
            alertContainerView.addHorizontalButtonStackView(buttons: buttons)
        } else if (actions.count > 2 && actions.count < 11) || textFields.count == 1 {
            alertContainerView.addVerticalButtonStackView(buttons: buttons)
        }
        
        view = alertContainerView
    }
    
    private func calculateViewSizeForActionController() {
        var height = 40.0
        
        if let _ = title_, let _ = message {
            height += Double(actionSheetContainerView.headerView.bounds.height)
        }
        height += Double(buttons.count) * CONSTANT_ACTION_BUTTON_SIZE
        
        if cancelButtons.count == 1 {
            height += CONSTANT_ACTION_BUTTON_SIZE + 10
        }
        
        let width = view.bounds.width
        
        self.view.frame = CGRect(x: 0,
                                 y: Double(UIScreen.main.bounds.height) - height,
                                 width: Double(width),
                                 height: height)
        
        action_view_y_position = Double(UIScreen.main.bounds.height) - height - 40.0
    }
    
    private func calculateViewSizeForAlertController() {
        var height = 0.0
        
        if let _ = title_, let _ = message {
            height = Double(alertContainerView.headerView.frame.height)
        }
        
        if actions.count > 0 && actions.count < 3 && textFields.count == 0  {
            height += CONSTANT_ALERT_BUTTON_SIZE
        } else if (actions.count > 2 && actions.count < 11) || textFields.count == 1 {
            height += CONSTANT_ALERT_BUTTON_SIZE * Double(actions.count)
        }
        alertContainerView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: Double(UIScreen.main.bounds.width - 100),
                                 height: height)
        
        alertContainerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100).isActive = true
        
        view.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        alert_view_y_position = Double(UIScreen.main.bounds.height / 2)
    }
    
    // MARK: - Direct methods
    
    @objc
    open func addAction(_ action: CustomAlertAction) {
        actions.append(action)
        let button = CustomAlertButton()
        button.setTitle(action.title_, for: .normal)
        button.action = action
        button.isEnabled = action.isEnabled
        switch action.style {
            case .destructive:
                button.setTitleColor(.priorityRed(), for: .normal)
                button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 14)
                button.addTarget(self, action: #selector(alertButtonTap(_:)), for: .touchUpInside)
                buttons.append(button)
            case .cancel:
                button.addTarget(self, action: #selector(cancelButtonTap(_:)), for: .touchUpInside)
                button.titleLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 14)
                if preferredStyle == .actionSheet {
                    cancelButtons.append(button)
                } else {
                    button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 14)
                    buttons.append(button)
                }
            default:
                
                if preferredStyle == .actionSheet {
                    button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 14)
                }
                
                button.addTarget(self, action: #selector(alertButtonTap(_:)), for: .touchUpInside)
                buttons.append(button)
        }
    }
    
    @objc
    open func addTextfield(configurationHandler: ((UITextField) -> Void)? = nil) {
        let textField = CustomAlertTextField()
        if configurationHandler != nil { configurationHandler!(textField) }
        textFields.append(textField)
    }
    
    // MARK: - Navigation-ish
    
    @objc
    private func cancelButtonTap(_ sender: CustomAlertButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc
    private func alertButtonTap(_ sender: CustomAlertButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async { [weak sender] in
            sender?.action?.handler?()
        }
    }
    
    @objc
    private func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    var keyboardOpen = false
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, !keyboardOpen {
            keyboardOpen = true
            var y_position = 0.0
            switch preferredStyle {
                case .actionSheet:
                    y_position = action_view_y_position
                case .alert:
                    y_position = alert_view_y_position
                case .none: break
            }
            if self.view.frame.origin.y == self.alertContainerView.frame.origin.y {
                self.view.frame.origin.y -= keyboardSize.height - (self.view.frame.origin.y / 2) -  20
            }
        }
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        keyboardOpen = false
        var y_position = 0.0
        switch preferredStyle {
            case .actionSheet:
                y_position = action_view_y_position
            case .alert:
                y_position = alert_view_y_position
            case .none: break
        }
        if self.view.frame.origin.y != CGFloat(y_position) {
            self.view.frame.origin.y = CGFloat(y_position)
        }
    }
}

