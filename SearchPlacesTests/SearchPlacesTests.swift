//
//  SearchPlacesTests.swift
//  SearchPlacesTests
//
//  Created by John Paul Manoza on 10/31/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import XCTest
@testable import SearchPlaces

class SearchPlacesTests: XCTestCase {

    func test_can_storeLocation() {
        
        // give
        let vm = SearchViewModel()
        let lat = 0.0; let lng = 0.0
        
        // when
        vm.storeCurrentLocation(lat: lat, lng: lng)
        
        let sut1 = UserDefaults.standard.value(forKey: "current_latitude") as? Double
        let sut2 = UserDefaults.standard.value(forKey: "current_longitude") as? Double
        
        // then
        XCTAssertEqual(sut1, 0.0)
        XCTAssertEqual(sut2, 0.0)
    }
}
