//
//  UserCell.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-07-03.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = ThemeManager.currentTheme().secondaryFont(with: 9)
        label.textColor = ThemeManager.currentTheme().generalSubtitleColor
        
        return label
    }()
    
    let seperator: UIView = {
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = ThemeManager.currentTheme().seperatorColor
        
        return seperator
    }()
    
    override func layoutSubviews() {
            super.layoutSubviews()

            if(self.imageView?.image != nil){

                let cellFrame = self.frame
                let textLabelFrame = self.textLabel?.frame
                let detailTextLabelFrame = self.detailTextLabel?.frame
                let imageViewFrame = self.imageView?.frame

                self.imageView?.contentMode = .scaleAspectFill
                self.imageView?.clipsToBounds = true
                self.imageView?.frame = CGRect(x: (imageViewFrame?.origin.x)!,y: (imageViewFrame?.origin.y)! + 1,width: 40,height: 40)
                self.textLabel!.frame = CGRect(x: 50 + (imageViewFrame?.origin.x)! , y: (textLabelFrame?.origin.y)!, width: cellFrame.width-(70 + (imageViewFrame?.origin.x)!), height: textLabelFrame!.height)
                self.detailTextLabel!.frame = CGRect(x: 50 + (imageViewFrame?.origin.x)!, y: (detailTextLabelFrame?.origin.y)!, width: cellFrame.width-(70 + (imageViewFrame?.origin.x)!), height: detailTextLabelFrame!.height)
            }
        }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
        
        addSubview(rightLabel)
        addSubview(seperator)
        
        NSLayoutConstraint.activate([
            rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            seperator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            seperator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            seperator.leadingAnchor.constraint(equalTo: imageView?.trailingAnchor ?? leadingAnchor, constant: 0),
            seperator.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        if let textLabel = textLabel {
//            seperator.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: 0).isActive = true
            rightLabel.topAnchor.constraint(equalTo: textLabel.topAnchor, constant: 0).isActive = true
        }
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        imageView?.contentMode = .scaleAspectFill
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
////        imageView?.image = nil
//        let itemSize = CGSize.init(width: 40, height: 40)
//        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
//        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
//        imageView?.image!.draw(in: imageRect)
//        imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        imageView?.layer.cornerRadius = (itemSize.width) / 2
//        imageView?.contentMode = .scaleAspectFit
//        imageView?.clipsToBounds = true
        
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        textLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.font = ThemeManager.currentTheme().secondaryFont(with: 12)
        detailTextLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
        textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
//        imageView?.contentMode = .scaleAspectFill
    }
}

class HandshakeSeperator: UIView {
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.backgroundColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {}
    
}
