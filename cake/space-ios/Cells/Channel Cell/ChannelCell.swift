//
//  ChannelCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class ChannelCell: UITableViewCell {
    
    private var timer: Timer?
    private var timeCounter: Double = 0
    
//    var channel: Channel?
    var channelId: String?
    
    let mainView: UIView = {
        let mainView = UIView(frame: .zero)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.layer.cornerRadius = 0
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.backgroundColor = .clear
        mainView.borderWidth = 0
        mainView.borderColor = .lighterGray()
        mainView.cornerRadius = 15
        
        return mainView
    }()
    
    let customAccessoryView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()

    let title: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 13)
        
        return label
    }()
    
    let subTitle: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        label.numberOfLines = 1
//        label.backgroundColor = .red
//        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let messageLabel: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.numberOfLines = 2
//        label.textAlignment = .left
//        label.textAlignment = .justified
        
        return label
    }()
    
    let dateTitle: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = ThemeManager.currentTheme().secondaryFont(with: 11)
        label.textColor = ThemeManager.currentTheme().tintColor
        label.cornerRadius = 3
        
        return label
    }()
    
    let statusIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 5
        view.backgroundColor = .handshakeGreen
        
        return view
    }()
    
    let eventStatus: DynamicLabel = {
        let label = DynamicLabel(withInsets: 1, 1, 1, 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.textAlignment = .right
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        // label.cornerRadius = 10
        label.layer.cornerCurve = .continuous
        
        return label
    }()
    
    let channelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lighterGray()
        imageView.cornerRadius = 35
        imageView.layer.cornerCurve = .circular
        imageView.contentMode = .scaleAspectFill
//        imageView.borderColor = .handshakeLightPurple
//        imageView.borderWidth = 2
        return imageView
    }()
    
    let fontSize: CGFloat = 12
    
    lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: fontSize)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = ThemeManager.currentTheme().tintColor
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.layer.cornerRadius = 15
        userInteractionEnabledWhileDragging = true
        contentView.isUserInteractionEnabled = true

        contentView.addSubview(mainView)
        
        mainView.addSubview(channelImageView)
        mainView.addSubview(title)
        mainView.addSubview(subTitle)
//        mainView.addSubview(messageLabel)
        mainView.addSubview(badgeLabel)
        mainView.addSubview(customAccessoryView)
        mainView.addSubview(statusIndicator)
        
        customAccessoryView.addSubview(dateTitle)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        contentView.backgroundColor = .clear
        selectionColor = ThemeManager.currentTheme().cellSelectionColor
        
        dateTitle.centerYAnchor.constraint(equalTo: channelImageView.centerYAnchor, constant: 0).isActive = true
        dateTitle.leadingAnchor.constraint(equalTo: title.leadingAnchor, constant: 0).isActive = true
        dateTitle.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -25).isActive = true
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            statusIndicator.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 15),
            statusIndicator.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 5),
            statusIndicator.heightAnchor.constraint(equalToConstant: 10),
            statusIndicator.widthAnchor.constraint(equalToConstant: 10),
            
            channelImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10),
            channelImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            channelImageView.heightAnchor.constraint(equalToConstant: 70),
            channelImageView.widthAnchor.constraint(equalToConstant: 70),
            channelImageView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10),
            
            title.bottomAnchor.constraint(equalTo: dateTitle.topAnchor, constant: -7),
            title.leadingAnchor.constraint(equalTo: channelImageView.trailingAnchor, constant: 15),
            
//            messageLabel.topAnchor.constraint(equalTo: channelImageView.bottomAnchor, constant: 10),
//            messageLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 5),
//            messageLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -5),
//            messageLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -15),
            
            customAccessoryView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            customAccessoryView.topAnchor.constraint(equalTo: title.topAnchor, constant: 0),
            customAccessoryView.bottomAnchor.constraint(equalTo: dateTitle.bottomAnchor, constant: 0),
            customAccessoryView.widthAnchor.constraint(equalToConstant: 50),
            
            subTitle.topAnchor.constraint(equalTo: dateTitle.bottomAnchor, constant: 7),
            subTitle.leadingAnchor.constraint(equalTo: dateTitle.leadingAnchor, constant: 0),
            
            
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func cleanUpCell(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let deletedChannelID = obj["channelID"] as? String,
              let channelID = channelId,
              deletedChannelID == channelID
        else { return }
        invalidateTimer()
//        channel = nil
    }
    
    deinit {
//        invalidateTimer()
//        channel = nil
    }
    
    @objc func invalidateTimer() {
//        timer?.invalidate()
//        timer = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        subTitle.text = nil
        eventStatus.text = nil
        badgeLabel.text = "0"
        badgeLabel.isHidden = true
        mainView.backgroundColor = .clear
        selectionColor = ThemeManager.currentTheme().cellSelectionColor
        title.textColor = ThemeManager.currentTheme().generalTitleColor
        subTitle.textColor = ThemeManager.currentTheme().generalSubtitleColor
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        contentView.backgroundColor = .clear
        imageView?.image = nil
        channelImageView.image = nil
        textLabel?.text = ""
        //messageLabel.text = ""
        title.text = ""
        subTitle.text = ""
//        channel = nil
        invalidateTimer()
    }
    
}

// MARK: - Timer methods

extension ChannelCell {
    
    func startTimer() {
      
    }
    
    @objc
    func onComplete() {

    }
    
    func updateBadge(_ count: Int) {
        if count > 0 {
            badgeLabel.text = "\(NSNumber(value: count))"
            badgeLabel.sizeToFit()
            
            let height = badgeLabel.frame.height + CGFloat(Int(0.4 * fontSize))
            let width = (count <= 9) ? height : badgeLabel.frame.width + CGFloat(Int(fontSize))
            
//            messageLabel.textColor = ThemeManager.currentTheme().tintColor
            
            badgeLabel.layer.cornerRadius = height / 2.0
            badgeLabel.clipsToBounds = true
            customAccessoryView.addSubview(badgeLabel)
            badgeLabel.isHidden = false
            NSLayoutConstraint.activate([
                badgeLabel.trailingAnchor.constraint(equalTo: customAccessoryView.trailingAnchor, constant: 0),
                badgeLabel.bottomAnchor.constraint(equalTo: customAccessoryView.bottomAnchor, constant: 0),
                badgeLabel.heightAnchor.constraint(equalToConstant: height),
                badgeLabel.widthAnchor.constraint(equalToConstant: width)
            ])
        } else {
            badgeLabel.text = "0"
            badgeLabel.isHidden = true
//            messageLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
        }
    }
}
