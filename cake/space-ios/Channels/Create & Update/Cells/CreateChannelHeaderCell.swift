//
//  CreateChannelHeaderCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-06-04.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

protocol ChannelNameHeaderCellDelegate: class {
    func channelNameHeaderCell(_ cell: ChannelNameHeaderCell, didTapImageView: Bool)
    func channelNameHeaderCell(_ cell: ChannelNameHeaderCell, updatedChannelName: String)
}

class ChannelNameHeaderCell: UITableViewCell {

    var textChanged: ((String) -> Void)?
    let locationView = LocationView()

    weak var delegate: ChannelNameHeaderCellDelegate?
    
    var channelImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = ThemeManager.currentTheme().imageViewBackground
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.cornerRadius = 25
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let channelImagePlaceholderLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "📷"
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    let channelNameField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.font = ThemeManager.currentTheme().secondaryFontVeryBold(with: 18)
        textField.textColor = ThemeManager.currentTheme().generalTitleColor
        textField.placeholder = "What's the plan?"
        textField.returnKeyType = .done
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.tintColor = ThemeManager.currentTheme().tintColor
        textField.returnKeyType = .done
        textField.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        textField.attributedPlaceholder = NSAttributedString(string: "What's the plan?", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().placeholderTextColor])
        return textField
    }()
    
    let channelNameDescriptionLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter a name for your event and an optional event icon."
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    let hangingMiniBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 1.5
        
        return view
    }()
    
    let paddingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundSecondaryColor
        
        return view
    }()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none
        channelNameField.delegate = self
        
        channelNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        channelImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        
        setColor()
        contentView.addSubview(channelImageView)
        contentView.addSubview(channelImagePlaceholderLabel)
        contentView.addSubview(channelNameField)
        contentView.addSubview(channelNameDescriptionLabel)
//        contentView.addSubview(paddingView)
        
        NSLayoutConstraint.activate([
            channelImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            channelImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            channelImageView.heightAnchor.constraint(equalToConstant: 50),
            channelImageView.widthAnchor.constraint(equalToConstant: 50),
            
            channelImagePlaceholderLabel.topAnchor.constraint(equalTo: channelImageView.topAnchor, constant: 0),
            channelImagePlaceholderLabel.leadingAnchor.constraint(equalTo: channelImageView.leadingAnchor, constant: 0),
            channelImagePlaceholderLabel.trailingAnchor.constraint(equalTo: channelImageView.trailingAnchor, constant: 0),
            channelImagePlaceholderLabel.bottomAnchor.constraint(equalTo: channelImageView.bottomAnchor, constant: 0),
            
            channelNameField.centerYAnchor.constraint(equalTo: channelImageView.centerYAnchor, constant: 0),
            channelNameField.leadingAnchor.constraint(equalTo: channelImageView.trailingAnchor, constant: 15),
            channelNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
//            nameTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            channelNameDescriptionLabel.topAnchor.constraint(equalTo: channelImageView.bottomAnchor, constant: 5),
            channelNameDescriptionLabel.leadingAnchor.constraint(equalTo: channelNameField.leadingAnchor, constant: 0),
            channelNameDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            channelNameDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
//            paddingView.topAnchor.constraint(equalTo: channelNameDescriptionLabel.bottomAnchor, constant: 0),
//            paddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
//            paddingView.heightAnchor.constraint(equalToConstant: 15),
//            paddingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            paddingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setColor() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundSecondaryColor
        accessoryView?.backgroundColor = backgroundColor
        selectionColor = ThemeManager.currentTheme().cellSelectionColor
        channelImageView.backgroundColor = ThemeManager.currentTheme().imageViewBackground
        channelNameField.textColor = ThemeManager.currentTheme().generalTitleColor
        paddingView.backgroundColor = ThemeManager.currentTheme().secondaryButtonBackgroundColor
        channelNameDescriptionLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        channelNameField.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setColor()
    }
    
    @objc
    func imageTapped() {
        delegate?.channelNameHeaderCell(self, didTapImageView: true)
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.channelNameHeaderCell(self, updatedChannelName: text)
        }
    }
}

extension ChannelNameHeaderCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 25
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return false
    }
}
