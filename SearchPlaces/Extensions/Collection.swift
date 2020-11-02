//
//  Collection.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 11/2/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
