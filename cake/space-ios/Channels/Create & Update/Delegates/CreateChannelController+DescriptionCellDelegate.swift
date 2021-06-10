//
//  CreateChannelController+DescriptionCellDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-19.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import UIKit

extension CreateChannelController: DescriptionCellDelegate {
    
    func updateHeightOfRow(_ cell: UITableViewCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            if let thisIndexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
}
