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
    
    var channel: Channel?
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
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        
        return label
    }()
    
    let dateTitle: DynamicLabel = {
        let label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        label.cornerRadius = 3
        
        return label
    }()
    
    let statusIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = 2.5
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
        imageView.borderColor = .handshakeLightPurple
        imageView.borderWidth = 3.5
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
        mainView.addSubview(badgeLabel)
        mainView.addSubview(customAccessoryView)
        mainView.addSubview(statusIndicator)
        
        customAccessoryView.addSubview(dateTitle)
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            statusIndicator.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 5),
            statusIndicator.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 5),
            statusIndicator.heightAnchor.constraint(equalToConstant: 5),
            statusIndicator.widthAnchor.constraint(equalToConstant: 5),
            
            channelImageView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor, constant: 0),
            channelImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            channelImageView.heightAnchor.constraint(equalToConstant: 70),
            channelImageView.widthAnchor.constraint(equalToConstant: 70),
            
            title.topAnchor.constraint(equalTo: channelImageView.topAnchor, constant: 0),
            title.leadingAnchor.constraint(equalTo: channelImageView.trailingAnchor, constant: 15),
            
            subTitle.centerYAnchor.constraint(equalTo: channelImageView.centerYAnchor, constant: 0),
            subTitle.leadingAnchor.constraint(equalTo: title.leadingAnchor, constant: 0),
            subTitle.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: 0),
            
            customAccessoryView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            customAccessoryView.topAnchor.constraint(equalTo: title.topAnchor, constant: 0),
            customAccessoryView.bottomAnchor.constraint(equalTo: subTitle.bottomAnchor, constant: 0),
            customAccessoryView.widthAnchor.constraint(equalToConstant: 50),
            
            dateTitle.topAnchor.constraint(equalTo: customAccessoryView.topAnchor, constant: 0),
            dateTitle.trailingAnchor.constraint(equalTo: customAccessoryView.trailingAnchor, constant: 0),
            
            
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
        channel = nil
    }
    
    deinit {
        invalidateTimer()
        channel = nil
    }
    
    @objc func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        subTitle.text = nil
        eventStatus.text = nil
        badgeLabel.text = "0"
        badgeLabel.isHidden = true
        mainView.backgroundColor = .clear
        title.textColor = ThemeManager.currentTheme().generalTitleColor
        subTitle.textColor = ThemeManager.currentTheme().generalSubtitleColor
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        contentView.backgroundColor = .clear
        imageView?.image = nil
        channel = nil
        invalidateTimer()
    }
    
}

// MARK: - Timer methods

extension ChannelCell {
    
    func startTimer() {
        
        // check if this is reasonable
//        var timeInterval = 1.0
//        let startDate = Date(timeIntervalSince1970: TimeInterval(channel?.startTime.value ?? 0))
//
//        if startDate.isInToday {
//            timeInterval = 1.0
//        } else {
//            timeInterval = 30.0
//        }
        
//        if #available(iOS 10.0, *) {
//            timer = Timer(timeInterval: timeInterval,
//                          repeats: true,
//                          block: { [weak self] _ in
//                            guard let strongSelf = self else { return }
//                            strongSelf.onComplete()
//            })
//        } else {
//            timer = Timer(timeInterval: timeInterval,
//                          target: self,
//                          selector: #selector(onComplete),
//                          userInfo: nil,
//                          repeats: true)
//        }
//        RunLoop.current.add(timer!, forMode: .common)
    }
    
    @objc
    func onComplete() {
//        let prevStatus = channel?.status
//        guard let channelStatus = channel?.updateAndReturnStatus() else { return }
//
//        if channelStatus != prevStatus {
//            let obj: [String: Any] = ["channelID": channel?.id ?? ""]
//            NotificationCenter.default.post(name: .channlStatusUpdated, object: obj)
//            print("posted")
//        }
//
//        switch channelStatus {
//            case .upcoming:
//
//                let startDate = Date(timeIntervalSince1970: Double(integerLiteral: (channel?.startTime.value ?? 0)))
//                let calendar = Calendar.current
//                let date1 = calendar.startOfDay(for: Date())
//                let date2 = calendar.startOfDay(for: startDate)
//                let components = calendar.dateComponents([.day], from: date1, to: date2)
//                if let days = components.day {
//                    if days == 1 {
//                        eventStatus.text = "Tomorrow"
//                    } else if days == 0 {
//                        eventStatus.text = "Today"
//                    } else {
//                        eventStatus.text = "In \(days) days"
//                    }
//                }
//
////                eventStatus.textColor = .priorityGreen()
////                eventStatus.backgroundColor = .greenEventStatusBackground()
//            case .inProgress:
//                eventStatus.text = "In progress"
////                eventStatus.textColor = .priorityGreen()
////                eventStatus.backgroundColor = .greenEventStatusBackground()
//            case .expired:
//                eventStatus.text = "Expired"
////                eventStatus.textColor = .priorityRed()
////                eventStatus.backgroundColor = .redEventStatusBackground()
//                invalidateTimer()
//            case .cancelled:
//                eventStatus.text = "Cancelled"
////                eventStatus.textColor = .priorityRed()
////                eventStatus.backgroundColor = .redEventStatusBackground()
//                invalidateTimer()
//        }
    }
    
    func updateBadge(_ count: Int) {
        if count > 0 {
            badgeLabel.text = "\(NSNumber(value: count))"
            badgeLabel.sizeToFit()
            
            let height = badgeLabel.frame.height + CGFloat(Int(0.4 * fontSize))
            let width = (count <= 9) ? height : badgeLabel.frame.width + CGFloat(Int(fontSize))
            
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
        }
    }
}
