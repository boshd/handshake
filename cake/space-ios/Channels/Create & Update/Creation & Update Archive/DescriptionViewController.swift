//
//  PickLocationViewController.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-10-25.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import SafariServices

protocol DescriptionDelegate: class {
    func didPressDone(description: String)
}

class DescriptionViewController: UIViewController {
    
    weak var descriptionDelegate: DescriptionDelegate?
    var nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
    
    let textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        textView.backgroundColor = .clear
        textView.tintColor = ThemeManager.currentTheme().tintColor
        textView.textColor = ThemeManager.currentTheme().generalTitleColor
        textView.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isSelectable =  true
        
        textView.dataDetectorTypes = .all
        textView.linkTextAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 13)
        ]
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationbar()
        setupController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.async {
            self.textView.becomeFirstResponder()
        }
    }
    
    fileprivate func setupController() {
        textView.delegate = self
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        view.addSubview(textView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
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
    
    @objc func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
//        if let navigationBar = navigationController?.navigationBar {
//            ThemeManager.setNavigationBarAppearance(navigationBar)
//        }
        textView.font = ThemeManager.currentTheme().secondaryFont(with: 13)
        textView.backgroundColor = .clear
        textView.tintColor = ThemeManager.currentTheme().tintColor
        textView.textColor = ThemeManager.currentTheme().generalTitleColor
        textView.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isSelectable =  true
        
        textView.dataDetectorTypes = .all
        textView.linkTextAttributes = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 13)
        ]
    }
    
    fileprivate func setupNavigationbar() {
        let cancelButtonItem = UIBarButtonItem(image: UIImage(named: "ctrl-left"), style: .plain, target: self, action: #selector(popController))
        cancelButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = cancelButtonItem
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ThemeManager.currentTheme().generalTitleColor, .font: ThemeManager.currentTheme().secondaryFontBoldItalic(with: 15)]
        
        nextButton.tintColor = ThemeManager.currentTheme().tintColor
        nextButton.isEnabled = false
        navigationItem.rightBarButtonItem = nextButton
//        navigationItem.setTitle(title: "Event description", subtitle: "")
        
        
        title = "Event description"
    }
    
    @objc func doneTapped() {
        descriptionDelegate?.didPressDone(description: textView.text)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func popController() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension DescriptionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
            nextButton.isEnabled = true
            nextButton.tintColor = ThemeManager.currentTheme().generalTitleColor
            navigationItem.rightBarButtonItem = nextButton
        } else {
            nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
            nextButton.isEnabled = false
            nextButton.tintColor = ThemeManager.currentTheme().generalTitleColor
            navigationItem.rightBarButtonItem = nextButton
        }
    }
    
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let limit = 600
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
//        navigationController?.navigationItem.setTitle(title: "Event description", subtitle: String(numberOfChars))
//        title  = String(numberOfChars)
        title = "\(numberOfChars)/\(limit)"
        if numberOfChars == 0 {
           title = "Event description"
        }
        return numberOfChars < limit    // 10 Limit Value
    }
}
