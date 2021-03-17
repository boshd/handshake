//
//  AutoSizingCollectionViewFlowLayout.swift
//  space-ios
//
//  Created by Kareem Arab on 2019-05-31.
//  Copyright © 2019 Kareem Arab. All rights reserved.
//

import UIKit

var isInsertingCellsToTop: Bool = false
var contentSizeWhenInsertingToTop: CGSize?

class AutoSizingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        sectionHeadersPinToVisibleBounds = true
        minimumLineSpacing = 5
        if isInsertingCellsToTop == true {
            if let collectionView = collectionView, let oldContentSize = contentSizeWhenInsertingToTop {
                let newContentSize = collectionViewContentSize
                let contentOffsetY = collectionView.contentOffset.y + (newContentSize.height - oldContentSize.height)
                let newOffset = CGPoint(x: collectionView.contentOffset.x, y: contentOffsetY)
                collectionView.setContentOffset(newOffset, animated: false)
            }
            contentSizeWhenInsertingToTop = nil
            isInsertingCellsToTop = false
        }
    }
}
