//
//  ChannelCollectionView.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-09-14.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Foundation
import Firebase
import Photos

class ChannelCollectionView: UICollectionView {
    
    let incomingMessageCellID = "incomingMessageCellID"
    let outgoingMessageCellID = "outgoingMessageCellID"
    let typingIndicatorCellID = "typingIndicatorCellID"
    let informationMessageCellID = "informationMessageCellID"


    required public init() {
        super.init(frame: .zero, collectionViewLayout: AutoSizingCollectionViewFlowLayout())
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // top, bottom 20
        delaysContentTouches = false
        isPrefetchingEnabled = true
        keyboardDismissMode = .interactive
        
        updateColors()
        registerCells()
    }
    
    fileprivate func registerCells() {
        register(IncomingMessageCell.self, forCellWithReuseIdentifier: incomingMessageCellID)
        register(OutgoingMessageCell.self, forCellWithReuseIdentifier: outgoingMessageCellID)
        register(TypingIndicatorCell.self, forCellWithReuseIdentifier: typingIndicatorCellID)
        register(InformationMessageCell.self, forCellWithReuseIdentifier: informationMessageCellID)
        register(ChannelLogViewControllerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "lol")
        registerNib(UINib(nibName: "TimestampView", bundle: nil), forRevealableViewReuseIdentifier: "timestamp")
    }
    
    func updateColors() {
        backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func scrollToBottom(animated: Bool) {
        guard contentSize.height > bounds.size.height else { return }
        setContentOffset(CGPoint(x: 0, y: (contentSize.height - bounds.size.height) + (contentInset.bottom)),
                   animated: animated)
    }
    
    public func setupCellHeight(isOutgoingMessage: Bool, frame: RealmCGRect?, indexPath: IndexPath) -> CGFloat {
        guard let frame = frame, let height = frame.height.value else { return 0 }

        if !isOutgoingMessage {
            return CGFloat(height) + BaseMessageCell.textMessageInsets
        } else {
            return CGFloat(height) + BaseMessageCell.defaultTextMessageInsets
        }
    }
    
    public func setupCellWidth(isOutgoingMessage: Bool, frame: RealmCGRect?, indexPath: IndexPath) -> CGFloat {
        guard let frame = frame, let width = frame.width.value else { return 0 }

        if !isOutgoingMessage {
            return CGFloat(width) + BaseMessageCell.incomingMessageHorisontalInsets
        } else {
            return CGFloat(width)
        }
    }
}

