//
//  AutoSizingCollectionViewFlowLayout.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit
import Foundation

var isInsertingCellsToTop: Bool = false
var contentSizeWhenInsertingToTop: CGSize?

class AutoSizingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 2
        sectionHeadersPinToVisibleBounds = true
        
        if globalVariables.isInsertingCellsToTop == true {
            if let collectionView = collectionView, let oldContentSize = globalVariables.contentSizeWhenInsertingToTop {
                let newContentSize = collectionViewContentSize
                let contentOffsetY = collectionView.contentOffset.y + (newContentSize.height - oldContentSize.height)
                let newOffset = CGPoint(x: collectionView.contentOffset.x, y: contentOffsetY)
                UIView.performWithoutAnimation {
                    collectionView.setContentOffset(newOffset, animated: false)
                }
            }
            globalVariables.contentSizeWhenInsertingToTop = nil
            globalVariables.isInsertingCellsToTop = false
        }
    }
}
