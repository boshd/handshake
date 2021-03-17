//
//  MapController+MKLocalSearchCompleterDelegate.swift
//  space-ios
//
//  Created by Kareem Arab on 2020-12-29.
//  Copyright © 2020 Kareem Arab. All rights reserved.
//

import MapKit

extension MapController: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletionRequest(didComplete: completer.results)
    }
}
