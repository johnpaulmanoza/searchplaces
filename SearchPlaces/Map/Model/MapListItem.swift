//
//  MapListItem.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation

import RxDataSources

enum MapListItem: SectionModelType {

    typealias Item = Row

    // Declare different tableview sections here
    case listSection(header: String, items: [Row])

    enum Row {
        // Declare different cell layout here
        case locationItem(item: MapCellItem)
    }

    // conformance to SectionModelType
    var items: [Row] {
        switch self {
        case .listSection(_, let items):
            return items
        }
    }

    public init(original: MapListItem, items: [Row]) {
        switch original {
        case .listSection(let header, _):
            self = .listSection(header: header, items: items)
        }
    }
}

// Create a UI model class, to differentiate data per UI class

class MapCellItem {

    var location: Location?

    init(location: Location) {
        self.location = location
    }
}

