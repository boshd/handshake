//
//  AlertContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-03.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class AlertContainerView: UIView {
    
    // MARK: - Header view
    
    var headerView: UIView  = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
        
        return view
    }()
    
    var titleLabel: DynamicLabel  = {
        var label = DynamicLabel(withInsets: 5, 5, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 16)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        return label
    }()
    
    var detailsLabel: DynamicLabel  = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        return label
    }()
    
    var headerStackView: UIStackView  = {
        var stackView =  UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    
    var seperator: UIView  = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().alertControllerSeperatorColor
        
        return view
    }()
    
    // MARK: - Horizontal Button View
    
    var horizontalButtonStackView: UIStackView  = {
        var stackView =  UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    
    // MARK: - Vertical Button View
    
    var verticalButtonStackView: UIStackView  = {
        var stackView =  UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    
    // MARK: - Other
    
    var cancelButton: CustomAlertButton  = {
        var button = CustomAlertButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dismiss", for: .normal)
        button.cornerRadius = 15
        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 14)
        
        return button
    }()
    
//    var textField: CustomAlertTextField  = {
//        var textField = CustomAlertTextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//
//        return textField
//    }()
    var buttons: [CustomAlertButton]?
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
        cornerRadius = 15
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadButtons() {
        if let buttons = buttons {
            for button in buttons {
                if button.action?.style == .destructive {
                    button.setTitleColor(.priorityRed(), for: .normal)
                } else {
                    button.setTitleColor(ThemeManager.currentTheme().buttonTextColor, for: .normal)
                }
                button.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
                
                button.setTitleColor(.lightGray, for: .disabled)
                
//                backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
//                button.setTitleColor(ThemeManager.currentTheme().buttonTextColor, for: .normal)
//                button.setTitleColor(.lightGray, for: .disabled)
            }
        }
    }
    
    func addHeaderView(title: String, details: String) {
        titleLabel.text = title
        detailsLabel.text = details
        
        addSubview(headerView)
        headerView.addSubview(headerStackView)
        headerView.addSubview(seperator)
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            headerStackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 0),
            headerStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0),
            headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            headerStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            headerStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            
            seperator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            seperator.heightAnchor.constraint(equalToConstant: 0.3),
            seperator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
            seperator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0),
        ])
    }
    
    let CONSTANT_TEXT_FIELD_HEIGHT = CGFloat(30)
    
    func addHeaderViewWithTextField(title: String, details: String, textField: CustomAlertTextField) {
        titleLabel.text = title
        detailsLabel.text = details
        
//        textField.becomeFirstResponder()
        
        addSubview(headerView)
        headerView.addSubview(headerStackView)
        headerView.addSubview(textField)
        headerView.addSubview(seperator)
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            headerStackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 0),
            headerStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: CONSTANT_TEXT_FIELD_HEIGHT),
            headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            headerStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            headerStackView.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -10),
            
//            textField.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 5),
            textField.widthAnchor.constraint(equalTo: headerView.widthAnchor, constant: -20),
            textField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 0),
            textField.heightAnchor.constraint(equalToConstant: CONSTANT_TEXT_FIELD_HEIGHT),
            textField.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15),
            
            seperator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            seperator.heightAnchor.constraint(equalToConstant: 0.5),
            seperator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
            seperator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0),
        ])
    }
    
    func addTextField(textField: CustomAlertTextField) {
        guard self.contains(headerView) else {
            fatalError("No header view available")
        }
        
        headerView.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            textField.heightAnchor.constraint(equalToConstant: 30),
            textField.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15)
        ])
    }
    
    func addHorizontalButtonStackView(buttons: [CustomAlertButton]) {
        addSubview(horizontalButtonStackView)
        
        if self.contains(headerView) {
            horizontalButtonStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        } else {
            horizontalButtonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        }
        
        NSLayoutConstraint.activate([
            horizontalButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            horizontalButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            horizontalButtonStackView.heightAnchor.constraint(equalToConstant: 45),
        ])
        
        addButtonsToStack(buttons: buttons, orientation: .horizontal)
    }
    
    func addVerticalButtonStackView(buttons: [CustomAlertButton]) {
        addSubview(verticalButtonStackView)
        
        if self.contains(headerView) {
            verticalButtonStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        } else {
            verticalButtonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        }
        
        NSLayoutConstraint.activate([
            verticalButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            verticalButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
        ])
        
        addButtonsToStack(buttons: buttons, orientation: .vertical)
    }
    
    enum StackOrientation {
        case vertical
        case horizontal
    }
    
    private func addButtonsToStack(buttons: [CustomAlertButton], orientation: StackOrientation) {
        for button in buttons {
            button.heightAnchor.constraint(equalToConstant: 45).isActive = true
            button.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            switch orientation {
                case .horizontal:
                    horizontalButtonStackView.addArrangedSubview(button)
                case .vertical:
                    verticalButtonStackView.addArrangedSubview(button)
            }
        }
        self.buttons = buttons
    }
}

