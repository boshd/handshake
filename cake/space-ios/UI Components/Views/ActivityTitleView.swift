//
//  ActivityTitleView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-10-15.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit

class ActivityTitleView: UIView {
//    fileprivate let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
//    let titleLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .red
//        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
//
//        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
//        activityIndicatorView.color = ThemeManager.currentTheme().generalTitleColor//color
//        activityIndicatorView.startAnimating()
//
//        titleLabel.text = text.rawValue
//        titleLabel.font = UIFont.systemFont(ofSize: 14)
//        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor//color
//
//        let fittingSize = titleLabel.sizeThatFits(CGSize(width: 200.0, height: activityIndicatorView.frame.size.height))
//
//        titleLabel.frame = CGRect(x: activityIndicatorView.frame.origin.x + activityIndicatorView.frame.size.width + 8,
//                                                            y: activityIndicatorView.frame.origin.y,
//                                                            width: fittingSize.width,
//                                                            height: fittingSize.height)
//
//        let viewFrame = CGRect(x: (activityIndicatorView.frame.size.width + 8 + titleLabel.frame.size.width) / 2,
//                                                     y: activityIndicatorView.frame.size.height / 2,
//                                                     width: activityIndicatorView.frame.size.width + 8 + titleLabel.frame.size.width,
//                                                     height: activityIndicatorView.frame.size.height)
//        self.frame = viewFrame
//        addSubview(activityIndicatorView)
//        addSubview(titleLabel)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    @objc fileprivate func changeTheme() {
//        activityIndicatorView.color = ThemeManager.currentTheme().generalTitleColor
//        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
//    }
    var activityIndicatorView: UIActivityIndicatorView = {
        var view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        view.color = ThemeManager.currentTheme().generalTitleColor

        return view
    }()
    var titleLabel: DynamicLabel = {
        var label = DynamicLabel(withInsets: 0, 0, 0, 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ThemeManager.currentTheme().generalTitleColor
        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 25)
//        label.numberOfLines = 2
//        
//        label.font = ThemeManager.currentTheme().secondaryFontBold(with: 12)
//        label.textColor = .gray

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        addSubview(titleLabel)

        activityIndicatorView.startAnimating()
        
        backgroundColor = .red

        NSLayoutConstraint.activate([
            activityIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            activityIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//            activityIndicatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//            activityIndicatorView.widthAnchor.constraint(equalToConstant: 40),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: activityIndicatorView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc fileprivate func changeTheme() {
        activityIndicatorView.color = ThemeManager.currentTheme().generalTitleColor
        titleLabel.textColor = ThemeManager.currentTheme().generalTitleColor
    }
}
