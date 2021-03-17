//
//  SelfSizingTableView.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-01-03.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

class SelfSizingTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
  
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
  
    override var intrinsicContentSize: CGSize {
        setNeedsLayout()
        layoutIfNeeded()
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}
