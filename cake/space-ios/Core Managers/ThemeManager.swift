//
//  ThemeManager.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-11-07.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import SDWebImage
import MapKit

extension NSNotification.Name {
    static let themeUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".themeUpdated")
}

struct ThemeManager {
    
    static func applyTheme(theme: Theme) {
        userDefaults.updateObject(for: userDefaults.selectedTheme, with: theme.rawValue)
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.shadowImage = nil
        coloredAppearance.shadowColor = nil
        coloredAppearance.backgroundColor = ThemeManager.currentTheme().barBackgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: ThemeManager.currentTheme().generalTitleColor, .font: ThemeManager.currentTheme().secondaryFontBold(with: 15)]
//        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = ThemeManager.currentTheme().barBackgroundColor
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        
//        UITabBar.appearance().tintColor = theme.tabBarTintColor

//        let tabBarAppearance = UITabBarItem.appearance()
//        let attributes = [NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFontBold(with: 6)]
//        tabBarAppearance.setTitleTextAttributes(attributes, for: .normal)
        
        

        UITableViewCell.appearance().selectionColor = ThemeManager.currentTheme().cellSelectionColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes =  [
            NSAttributedString.Key.foregroundColor: theme.generalTitleColor,
            NSAttributedString.Key.font: ThemeManager.currentTheme().secondaryFont(with: 12)
        ]
        UIView.appearance(whenContainedInInstancesOf: [INSPhotosViewController.self]).tintColor = ThemeManager.currentTheme().tintColor
        UIView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = theme.barTintColor
        UITableViewCell.appearance().tintColor = ThemeManager.currentTheme().tintColor
        UITableView.appearance().separatorColor = ThemeManager.currentTheme().seperatorColor
        NotificationCenter.default.post(name: .themeUpdated, object: nil)
    }
    
    static func currentTheme() -> Theme {
        if UserDefaults.standard.object(forKey: userDefaults.selectedTheme) == nil {
            return .normal
        }
        if let storedTheme = userDefaults.currentIntObjectState(for: userDefaults.selectedTheme) {
            return Theme(rawValue: storedTheme)!
        } else {
            return .normal
        }
    }
    
    static func setNavigationBarAppearance(_ naviationBar: UINavigationBar) {
        if #available(iOS 13.0, *) {
            let coloredAppearance = UINavigationBarAppearance()
            coloredAppearance.shadowImage = nil
            coloredAppearance.shadowColor = nil
            coloredAppearance.backgroundColor = ThemeManager.currentTheme().barBackgroundColor
            coloredAppearance.titleTextAttributes = [.foregroundColor: ThemeManager.currentTheme().generalTitleColor, .font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 15)]
//            naviationBar.isTranslucent = false
            naviationBar.barTintColor = ThemeManager.currentTheme().barBackgroundColor
            naviationBar.standardAppearance = coloredAppearance
            naviationBar.scrollEdgeAppearance = coloredAppearance
            naviationBar.compactAppearance = coloredAppearance
        }
    }
    
    static func setSecondaryNavigationBarAppearance(_ naviationBar: UINavigationBar) {
        if #available(iOS 13.0, *) {
            let coloredAppearance = UINavigationBarAppearance()
            coloredAppearance.shadowImage = nil
            coloredAppearance.shadowColor = nil
            coloredAppearance.backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            coloredAppearance.titleTextAttributes = [.foregroundColor: ThemeManager.currentTheme().generalTitleColor, .font: ThemeManager.currentTheme().secondaryFontVeryBold(with: 15)]
//            naviationBar.isTranslucent = false
            naviationBar.barTintColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
            naviationBar.standardAppearance = coloredAppearance
            naviationBar.scrollEdgeAppearance = coloredAppearance
            naviationBar.compactAppearance = coloredAppearance
        }
    }
}

enum Theme: Int {
    case normal, dark
    
    func secondaryFont(with fontSize: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue", size: fontSize)!
        return UIFont.systemFont(ofSize: fontSize)
    }
    
    func secondaryFontMedium(with fontSize: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue-Medium", size: fontSize)!
        return UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    
    func secondaryFontBold(with fontSize: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue-Bold", size: fontSize)!
        return UIFont.boldSystemFont(ofSize: fontSize)
    }
    
    func secondaryFontVeryBold(with fontSize: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue-Bold", size: fontSize)!
        return UIFont.systemFont(ofSize: fontSize, weight: .heavy)
    }
    
    func secondaryFontItalic(with fontSize: CGFloat) -> UIFont {
//        return UIFont(name: "HelveticaNeue-Italic", size: fontSize)!
        return UIFont.italicSystemFont(ofSize: fontSize)
    }
    
    func secondaryFontBoldItalic(with fontSize: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-BoldItalic", size: fontSize)!
    }
    
    func primaryFont(with fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PlayfairDisplay-Regular", size: fontSize)!
    }
    
    func primaryFontBold(with fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PlayfairDisplay-Bold", size: fontSize)!
    }
    
    func primaryFontItalic(with fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PlayfairDisplay-BoldItalic", size: fontSize)!
    }
    
    var generalOverrideUserInterfaceStyle: UIUserInterfaceStyle {
        switch self {
            case .normal:
                return .light
            case .dark:
                return .dark
        }
    }
    
    var tintColor: UIColor {
        switch self {
            case .normal:
                return .handshakeBlue
            case .dark:
                return .handshakeBlue
        }
    }
    
    var windowBackground: UIColor {
        switch self {
            case .normal:
                return .black
            case .dark:
                return .black
        }
    }
    
    var generalBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .black
        }
    }
    
    var generalModalControllerBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    var barTintColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return tintColor
        }
    }
    
    var secondaryButtonBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .handshakeLightGray
            case .dark:
                return .offBlack()
        }
    }
    
    var secondaryButtonTintColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return tintColor
        }
    }
    
    var secondaryButtonTitleColor: UIColor {
        switch self {
            case .normal:
                return .black
            case .dark:
                return .white
        }
    }
    
    var buttonColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return tintColor
        }
    }
    
    var chatLogSendButtonColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return .white
        }
    }
    
    var buttonIconColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .white
        }
    }
    
    var buttonTextColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .white
        }
    }
    
    var tabBarTintColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return tintColor
        }
    }
    
    var unselectedButtonTintColor: UIColor {
        switch self {
            case .normal:
                return .handshakeMediumGray
            case .dark:
                return .handshakeDarkGray
        }
    }
    
    var selectedButtonTintColor: UIColor {
        switch self {
            case .normal:
                return .black
            case .dark:
                return tintColor
        }
    }
    
    var alertControllerBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    var customAlertControllerTranslucentBackground: UIColor {
        switch self {
            case .normal:
                return UIColor.black.withAlphaComponent(0.4)
            case .dark:
                return UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    var alertControllerSeperatorColor: UIColor {
        switch self {
            case .normal:
                return .lighterGray()
            case .dark:
                return .darkGray
        }
    }
    
    var countryCodeBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .lighterGray()
            case .dark:
                return .gray
        }
    }
    
    var imageViewBackground: UIColor {
        switch self {
            case .normal:
                return .handshakeMediumGray
            case .dark:
                return .handshakeDarkGray
        }
    }
    
    var channelCellBackgroundColor: UIColor {
        switch self {
            case .normal:
                //            return .extraLight()
                return UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.00)
            case .dark:
                return .clear
        }
    }
    
    var groupedInsetCellBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .handshakeLightGray
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    
    var barBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .black
        }
    }
    
    var seperatorColor: UIColor {
        switch self {
            case .normal:
                return .lightGray
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    var chatLogHeaderBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .handshakeLightPurple
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    var chatLogHeaderTextColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return .white
        }
    }
    
    var blurViewBackground: UIBlurEffect.Style {
        switch self {
            case .normal:
                return .systemUltraThinMaterialLight
            case .dark:
                return .systemUltraThinMaterialDark
        }
    }
    
    var mapViewStyle: UIUserInterfaceStyle {
        switch self {
            case .normal:
                return .light
            case .dark:
                return .dark
        }
    }
    
    var barTextColor: UIColor {
        switch self {
            case .normal:
                return generalTitleColor
            case .dark:
                return generalTitleColor
        }
    }
    
    var controlButtonTintColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return tintColor
        }
    }
    
    var generalTitleColor: UIColor {
        switch self {
            case .normal:
                return UIColor.black
            case .dark:
                return UIColor.white
        }
    }
    
    var supplementaryViewBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .black
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    
    var supplementaryViewTextColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .lightGray
        }
    }
    
    var chatLogTitleColor: UIColor {
        switch self {
            case .normal:
                return .black
            case .dark:
                return .white
        }
    }
    
    var calendarViewColor: UIColor {
        switch self {
            case .normal:
                return .greenEventStatusBackground()
            case .dark:
                return .clear
        }
    }
    
    var generalSubtitleColor: UIColor {
        switch self {
            case .normal:
                return .handshakeDarkGray
            case .dark:
                return .handshakeDarkGray
                //return .defaultLightGray()
        }
    }
    
    var placeholderTextColor: UIColor {
        switch self {
            case .normal:
                return .lightGray
            case .dark:
                return UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.00)
                //return .defaultLightGray()
        }
    }
    
    var mapViewBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .extraLight()
            case .dark:
                return .defaultMediumDarkGray()
                //return .defaultLightGray()
        }
    }
    
    var cellSelectionColor: UIColor {
        switch self {
            case .normal:
                return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) //F1F1F1
            case .dark:
                return UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0) //191919
        }
    }
    
    var informationMessageTextColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return generalSubtitleColor
        }
    }
    
    var informationMessageBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .handshakeLightPurple
            case .dark:
                return .handshakeLightPurple
        }
    }
    
    var generalBackgroundSecondaryColor: UIColor {
        switch self {
            case .normal:
                // return .extraLight()
                return UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.00)
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    var incomingTimestampTextColor: UIColor {
        switch self {
            case .normal:
                return .defaultMediumDarkGray()
            case .dark:
                return .white
        }
    }
    
    var outgoingTimestampTextColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .white
        }
    }
    
    var inputTextViewColor: UIColor {
        switch self {
            case .normal:
                return .defaultLightGray()
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    var inputBarContainerViewBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .black
        }
    }
    
    var sdWebImageActivityIndicator: SDWebImageActivityIndicator {
        switch self {
            case .normal:
                return SDWebImageActivityIndicator.gray
            case .dark:
                return SDWebImageActivityIndicator.white
        }
    }
    
    var controlButtonColor: UIColor {
        switch self {
            case .normal:
                return .lighterGray()
            case .dark:
                return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
        }
    }
    
    var controlButtonHighlightingColor: UIColor {
        switch self {
            case .normal:
                return UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) //F1F1F1
            case .dark:
                return UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0) //191919
        }
    }
    
    var searchBarColor: UIColor {
        switch self {
            case .normal:
                return UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 0.5)
            case .dark:
                return UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 0.8)
        }
    }
    
    var scrollDownImage: UIImage {
        switch self {
            case .normal:
                return UIImage(named: "arrowDownBlack")!
            case .dark:
                return UIImage(named: "arrowDownWhite")!
        }
    }
    
    
    var incomingMessageCellTextColor: UIColor {
        switch self {
            case .normal:
                return .black
            case .dark:
                return .white
        }
    }
    
    var outgoingMessageCellTextColor: UIColor {
        switch self {
            case .normal:
                return .white
            case .dark:
                return .white
        }
    }
    
    var outgoingMessageBackgroundColor: UIColor {
        switch self {
            case .normal:
                return tintColor
            case .dark:
                return tintColor
        }
    }
    
    var selectedOutgoingBubbleTintColor: UIColor {
        switch self {
            case .normal:
                return .defaultMediumDarkGray()
            case .dark:
                return .defaultMediumDarkGray()
        }
    }
    
    var selectedIncomingBubbleTintColor: UIColor {
        switch self {
            case .normal:
                return .gray
            case .dark:
                return .gray
        }
    }
    
    var incomingMessageBackgroundColor: UIColor {
        switch self {
            case .normal:
                return .defaultLightGray()
            case .dark:
                return .incomingBubbleDarkGray()
        }
    }
    
    var authorNameTextColor: UIColor {
        switch self {
            case .normal:
                return .black
            case .dark:
                return UIColor(red: 0.55, green: 0.77, blue: 1.0, alpha: 1.0)
        }
    }
    
    var keyboardAppearance: UIKeyboardAppearance {
        switch self {
            case .normal:
                return .light
            case .dark:
                return .dark
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
            case .normal:
                return .default
            case .dark:
                return .black
        }
    }
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
            case .normal:
                return .darkContent
            case .dark:
                return .lightContent
        }
    }
    
    var scrollBarStyle: UIScrollView.IndicatorStyle {
        switch self {
            case .normal:
                return .default
            case .dark:
                return .white
        }
    }
    
}

struct TintPalette {
    static let blue = UIColor(red: 0.00, green: 0.55, blue: 1.00, alpha: 1.0)
    static let lightBlue = UIColor(red: 0.13, green: 0.61, blue: 1.00, alpha: 1.0)
    static let grey = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    static let red = UIColor.red
    static let livingCoral = UIColor(red: 0.98, green: 0.45, blue: 0.41, alpha: 1.0)
    static let livingCoralLight = UIColor(red: 0.99, green: 0.69, blue: 0.67, alpha: 1.0)
    static let livingCoralExtraLight = UIColor(red: 0.99, green: 0.81, blue: 0.80, alpha: 1.0)
}
