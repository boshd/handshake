//
//  DescriptionCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-07.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Foundation

class DescriptionCell: UITableViewCell, UITextViewDelegate {

    var textChanged: ((String) -> Void)?
    
    let nameTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.font = ThemeManager.currentTheme().secondaryFontBold(with: 17)
        textView.text = "Description"
        textView.textColor = .lightGray
        textView.returnKeyType = .done
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.tintColor = .black
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        userInteractionEnabledWhileDragging = false
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none
        
        nameTextView.delegate = self
        
        setColor()
        contentView.addSubview(nameTextView)
        
        NSLayoutConstraint.activate([
            // nameTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            nameTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            nameTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            nameTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
    }

    fileprivate func setColor() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        accessoryView?.backgroundColor = backgroundColor
        selectionColor = ThemeManager.currentTheme().cellSelectionColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setColor()
    }
}

// UITextView
extension DescriptionCell {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.contentView.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else if updatedText.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        } else {
            return true
        }

        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.contentView.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}

