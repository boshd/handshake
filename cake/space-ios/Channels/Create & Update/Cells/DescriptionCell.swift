//
//  DescriptionCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-07.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import Foundation

protocol DescriptionCellDelegate: class {
    func updateHeightOfRow(_ cell: UITableViewCell, _ textView: UITextView)
}

class DescriptionCell: UITableViewCell {
    
    weak var delegate: DescriptionCellDelegate?

    var textChanged: ((String) -> Void)?
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textView.textColor = ThemeManager.currentTheme().generalSubtitleColor
        textView.returnKeyType = .done
        textView.autocorrectionType = .default
        textView.autocapitalizationType = .sentences
        textView.tintColor = ThemeManager.currentTheme().tintColor
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        userInteractionEnabledWhileDragging = false
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none
        
        textView.delegate = self
        
        setColor()
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            // nameTextView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setColor() {
//        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        accessoryView?.backgroundColor = backgroundColor
        selectionColor = ThemeManager.currentTheme().cellSelectionColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setColor()
    }
}

// UITextView
extension DescriptionCell: UITextViewDelegate {
    
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
            textView.textColor = ThemeManager.currentTheme().generalSubtitleColor

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        } else {
            return true
        }

        return false
    }
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let deletate = delegate {
            deletate.updateHeightOfRow(self, textView)
        }
        textChanged?(textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.contentView.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}

