//
//  MapItemSearchCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-27.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import UIKit
import MapKit

class MapItemSearchCell: InteractiveTableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        imageView?.image = UIImage(named: "Location")?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = UIImage(named: "Location")?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = .red
        backgroundColor = ThemeManager.currentTheme().generalModalControllerBackgroundColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 14)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
    }
    
    func viewSetup(withMapItem mapItem: MKMapItem, tintColor: UIColor? = nil) {
        textLabel?.text = mapItem.name
        detailTextLabel?.text = mapItem.placemark.title
        imageView?.tintColor = tintColor
        imageView?.backgroundColor = .clear
        
        if let textLabel = textLabel, let imageView = imageView {
            textLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10).isActive = true
        }
    }
}

