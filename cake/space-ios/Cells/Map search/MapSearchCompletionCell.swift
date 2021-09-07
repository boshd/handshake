//
//  MapSearchCompletionCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-27.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class MapSearchCompletionCell: InteractiveTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
    }
    
    func viewSetup(withSearchCompletion searchCompletion: MKLocalSearchCompletion) {
        let attributedString = NSMutableAttributedString(string: searchCompletion.title)
//        for highlightRange in searchCompletion.titleHighlightRanges {
//            attributedString.addAttribute(
//                NSAttributedString.Key.font,
//                value: ThemeManager.currentTheme().secondaryFont(with: 14),
//                range: highlightRange.rangeValue)
//        }
        textLabel?.attributedText = attributedString
//
        let attributedStringDetail = NSMutableAttributedString(string: searchCompletion.subtitle)
//        for highlightRange in searchCompletion.subtitleHighlightRanges {
//            attributedStringDetail.addAttribute(
//                NSAttributedString.Key.font,
//                value: ThemeManager.currentTheme().secondaryFont(with: 13),
//                range: highlightRange.rangeValue)
//        }
        detailTextLabel?.attributedText = attributedStringDetail
        
        
        
    }
}
