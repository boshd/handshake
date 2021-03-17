//
//  ActionSheetContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-03.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class CustomStackView: UIStackView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ActionSheetContainerView: UIView {
    
    var mainView: UIView  = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
        return view
    }()
    
    // MARK: Header view
    
    var headerView: UIView  = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var titleLabel: DynamicLabel  = {
        var label = DynamicLabel(withInsets: 2, 2, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 15)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        return label
    }()
    
    var detailsLabel: DynamicLabel  = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        return label
    }()
    
    var headerStackView: UIStackView  = {
        var stackView =  UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .clear
        
        return stackView
    }()
    
    var seperator: UIView  = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().alertControllerSeperatorColor
        
        return view
    }()
    
    // MARK: - Buttons
    
    var buttonStackView: CustomStackView  = {
        var stackView = CustomStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    var cancelButton: CustomAlertButton  = {
        var button = CustomAlertButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dismiss", for: .normal)
        button.cornerRadius = 15
        button.titleLabel?.font = ThemeManager.currentTheme().secondaryFontBold(with: 14)
        
        return button
    }()
    
    var mainViewBottomAnchor: NSLayoutAnchor<AnyObject>?
    var buttons: [CustomAlertButton]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainView)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
        ])
        
        backgroundColor = ThemeManager.currentTheme().alertControllerBackgroundColor
        cornerRadius = 15
    }
    
    func addHeaderView(title: String, details: String) {
        titleLabel.text = title
        detailsLabel.text = details
        
        mainView.addSubview(headerView)
        headerView.addSubview(headerStackView)
        headerView.addSubview(seperator)
        
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0),
            headerView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            
            headerStackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 0),
            headerStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 0),
            headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            headerStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15),
            headerStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            
            seperator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            seperator.heightAnchor.constraint(equalToConstant: 0.3),
            seperator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
            seperator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0),
        ])
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
            }
        }
    }
    
    func addButtonStackView(buttons: [CustomAlertButton]) {
        mainView.addSubview(buttonStackView)
        
//        if !self.contains(headerView) {
//            print("inheyaaaa")
//            headerView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0).isActive = true
//        }
        
        if self.contains(headerView) {
            buttonStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        } else {
            buttonStackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0).isActive = true
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            buttonStackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            buttonStackView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0),
        ])
        
        for button in buttons {
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.widthAnchor.constraint(equalToConstant: 200).isActive = true
            buttonStackView.addArrangedSubview(button)
        }
        
        self.buttons = buttons
    }
    
    func addCancelButton(button: CustomAlertButton) {
        addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
/*
 
 //
 //  ActionSheetContainerView.swift
 //  space-ios
 //
 //  Created by Kareem Arab on 2021-01-03.
 //  Copyright © 2021 Kareem Arab. All rights reserved.
 //

 import UIKit

 class CustomStackView: UIStackView {


     override init(frame: CGRect) {
         super.init(frame: frame)
         translatesAutoresizingMaskIntoConstraints = false
     }
     
     required init(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
 }

 class ActionSheetContainerView: UIView {
     
     var buttonStackView: CustomStackView  = {
         var stackView = CustomStackView()
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.backgroundColor = .fabGold()
         stackView.cornerRadius = 15
         stackView.axis = .vertical
         stackView.distribution = .fillEqually
         
         return stackView
     }()
     
     var cancelButton: CustomAlertButton  = {
         var button = CustomAlertButton()
         button.translatesAutoresizingMaskIntoConstraints = false
         button.setTitle("Dismiss", for: .normal)
         button.cornerRadius = 15
         
         return button
     }()

     override init(frame: CGRect) {
         super.init(frame: frame)
         backgroundColor = .clear
         cornerRadius = 15
         
         addSubview(buttonStackView)
         addSubview(cancelButton)

         NSLayoutConstraint.activate([
             buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
             buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
             buttonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
             buttonStackView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
             
             cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
             cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
             cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
             cancelButton.heightAnchor.constraint(equalToConstant: 60),
         ])
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
 }

 
 
 */
