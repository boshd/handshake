//
//  MapController+FloatingPanelControllerDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-29.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import FloatingPanel

extension MapController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return MyFloatingPanelLayout()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.state == .full {
            searchTableController.searchTableContainerView.searchBar.showsCancelButton = false
            searchTableController.searchTableContainerView.searchBar.resignFirstResponder()
        }
    }

    func floatingPanelWillEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        if targetState.pointee != .full {
            //searchTableController.searchTableContainerView.hideHeader(animated: true)
        }
    }
}
