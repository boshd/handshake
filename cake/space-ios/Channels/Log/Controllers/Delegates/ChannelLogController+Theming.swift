//
//  ChannelLogController+Theming.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-22.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension ChannelLogController {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
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
    
    @objc
    public func handleThemeChange() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        if let navigationBar = navigationController?.navigationBar {
            ThemeManager.setNavigationBarAppearance(navigationBar)
        }
        channelLogContainerView.channelLogHeaderView.setColors()
//        channelLogContainerView.inputViewContainer.blurEffectView = UIVisualEffectView(effect: ThemeManager.currentTheme().tabBarBlurEffect)
//        channelLogContainerView.inputViewContainer.backgroundColor = ThemeManager.currentTheme().inputBarContainerViewBackgroundColor
        inputContainerView.inputTextView.changeTheme()
        inputContainerView.setColors()
        refreshControl.tintColor = ThemeManager.currentTheme().generalTitleColor
        collectionView.updateColors()

        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        
        func updateTypingIndicatorIfNeeded() {
            if collectionView.numberOfSections == groupedMessages.count + 1 {
                guard let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? TypingIndicatorCell else { return }
                cell.restart()
            }
        }
        updateTypingIndicatorIfNeeded()

        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}
