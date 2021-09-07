//
//  SettingsFooterContainerView.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-23.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import SafariServices

class SettingsFooterContainerView: UIView {
    
    var controller: UIViewController?
  
    lazy var footerView: UITextView = {
        let footerLabel = UITextView()
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.backgroundColor = .clear
        footerLabel.textAlignment = .right
        footerLabel.font = ThemeManager.currentTheme().secondaryFont(with: 6)
        footerLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        return footerLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        footerView.delegate = self
        addSubview(footerView)
        
        let mainString = "v1.5 (1)\nbeta"
        let stringToColor = "v1.5 (1)\nbeta"
        let range = (mainString as NSString).range(of: stringToColor)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeManager.currentTheme().generalSubtitleColor, range: range)
        mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: ThemeManager.currentTheme().secondaryFontBold(with: 6), range: range)
        mutableAttributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(3), range: range)
//        let termsRange = (mainString as NSString).range(of: termsString)
//        let privacyRange = (mainString as NSString).range(of: privacyString)
//        mutableAttributedString.setAttributes([.link: "https://kareemarab.now.sh/terms"], range: termsRange)
//        mutableAttributedString.setAttributes([.link: "https://kareemarab.now.sh/privacy"], range: privacyRange)
//        // mutableAttributedString.addAttributes([.link: "https://stripe.com"], range: privacyRange)
        footerView.attributedText = mutableAttributedString
        footerView.textAlignment = .right
        footerView.isUserInteractionEnabled = true
        footerView.isSelectable = false
        footerView.isEditable = false
        
//        footerView.dataDetectorTypes = .all
//        footerView.linkTextAttributes = [
//            .foregroundColor: ThemeManager.currentTheme().tintColor
//        ]
//        footerView.textAlignment = .center
//        footerView.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        NSLayoutConstraint.activate([
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            footerView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            footerView.heightAnchor.constraint(equalToConstant: 100),
            footerView.widthAnchor.constraint(equalToConstant: 250),
        ])
    
    }
    
    func setColor() {
        footerView.textColor = ThemeManager.currentTheme().generalSubtitleColor
    }
  
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

extension SettingsFooterContainerView: UITextViewDelegate {
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
        
        guard let controller = controller else { return true }
        controller.present(svc, animated: true, completion: nil)
        
        return false
    }
}


