//
//  SearchPlacesTests.swift
//  SearchPlacesTests
//
//  Created by John Paul Manoza on 10/31/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import SearchPlaces

class SearchPlacesTests: XCTestCase {
    
    func test_can_loadLocations() {
        
        // given
        let vm = APIManager()
        let scheduler = MainScheduler.instance

        // when
        let items = vm
            .loadPlaces(query: "Restaurants")
            .subscribeOn(scheduler)
        
        // then
        do {
            
            guard let sut = try items.observeOn(scheduler).toBlocking().last() as? [Location] else {
                XCTFail("failed expection: should return an array of locations")
                return
            }
            
            XCTAssert(sut.count != 0)

        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_can_extract_ccordinatesFromLocationsArray() {
        
        // given
        let vm = APIManager()
        let scheduler = MainScheduler.instance

        // when
        let items = vm
            .loadPlaces(query: "Restaurants")
            .subscribeOn(scheduler)
        
        // then
        do {
            
            guard let items = try items.observeOn(scheduler).toBlocking().last() as? [Location] else {
                XCTFail("failed expection: should return an array of locations")
                return
            }
            
            guard let firstLocation = items.first else {
                XCTFail("failed expectation: should have at least no location item")
                return
            }
            
            guard let _ = firstLocation.locationLat, let _ = firstLocation.locationLng else {
                XCTFail("failed expection: latitude and longitude of a location cannot be nil")
                return
            }
            
            XCTAssert(true)

        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_can_remove_breakLinesFromLocationAddress() {
        
        
    }

    func test_can_displayLocations_in_list() {
        
    }
    
    func test_can_createMapPin() {
        
    }
    
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
    
    func test_map_canPinpointCurrentLocation() {
        
//        let map = MapViewController()
//        let mapView = map.map
//
//
//        XCTAssertEqual(mapView?.region, <#T##expression2: Equatable##Equatable#>)
    }
}
