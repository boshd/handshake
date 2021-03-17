//
//  FloatingPanelLayout.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-27.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import Foundation
import FloatingPanel

class MyFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.45, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 80.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
