//
//  ChannelLogController+Scroll.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-07-25.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import Foundation
import UIKit

extension ChannelLogController {
    
    // MARK: Scroll view
    func isScrollViewAtTheBottom() -> Bool {
        if collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.frame.size.height - 450) {
            return true
        }
        return false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isScrollViewAtTheBottom() {
            DispatchQueue.main.async {
                self.bottomScrollConainer.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.bottomScrollConainer.isHidden = false
            }
        }

        if scrollView.contentOffset.y <= 0 { //change 100 to whatever you want
            if collectionView.contentSize.height < UIScreen.main.bounds.height - 50 {
                canRefresh = false
            }

            if canRefresh && !refreshControl.isRefreshing {
                canRefresh = false
                refreshControl.beginRefreshing()
                performRefresh()
            }
        } else if scrollView.contentOffset.y >= 0 {
            canRefresh = true
        }
    }
    
}
