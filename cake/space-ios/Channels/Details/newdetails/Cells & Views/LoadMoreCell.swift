//
//  LoadMoreCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-06-09.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class LoadMoreCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
//        imageView?.image = UIImage(named: "Arrow - Down Circle")
//        imageView?.tintColor = ThemeManager.currentTheme().tintColor
//        textLabel?.text = "See 10 more"
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        textLabel?.textColor = ThemeManager.currentTheme().tintColor
        
//        textLabel?.backgroundColor = .handshakeLightPurple
//        textLabel?.cornerRadius = textLabel?.frame.height ?? 0.0
        
        
//        let itemSize = CGSize.init(width: 40, height: 40)
//        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
//        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
//        imageView?.image!.draw(in: imageRect)
//        imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        imageView?.layer.cornerRadius = (itemSize.width) / 2
//        imageView?.contentMode = .scaleAspectFit
//        imageView?.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
