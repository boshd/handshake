//
//  LocationSearchController+SearchCompletion.swift
//  space-ios
//
//  Created by Kareem Arab on 2021-05-18.
//  Copyright © 2021 Kareem Arab. All rights reserved.
//

import MapKit

extension LocationSearchController: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletionRequest(didComplete: completer.results)
    }
}
