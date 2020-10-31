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
        let api = APIManager()
        let scheduler = MainScheduler.instance

        // when
        let items = api
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
        let api = APIManager()
        let scheduler = MainScheduler.instance

        // when
        let items = api
            .loadPlaces(query: "Restaurants")
            .subscribeOn(scheduler)
        
        // then
        do {
            
            guard let items = try items.observeOn(scheduler).toBlocking().last() as? [Location] else {
                XCTFail("failed expection: should return an array of locations")
                return
            }
            
            guard let firstLocation = items.first else {
                XCTFail("failed expectation: should have at least one location item")
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
        
        // given
        let api = APIManager()
        let scheduler = MainScheduler.instance

        // when
        let items = api
            .loadPlaces(query: "Restaurants")
            .subscribeOn(scheduler)
        
        // then
        do {
            
            guard let items = try items.observeOn(scheduler).toBlocking().last() as? [Location] else {
                XCTFail("failed expection: should return an array of locations")
                return
            }
            
            guard let firstItem = items.first else {
                XCTFail("failed expectation: should have at least one location item")
                return
            }
            
            guard let sut = firstItem.locationAddress else {
                XCTFail("failed expectation: should have an address description")
                return
            }
            
            // address shouldn't contain break lines
            XCTAssert(sut.contains("<br/>") == false)

        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_can_storeLocation() {
        
        // give
        let vm = SearchViewModel()
        let lat = 0.0; let lng = 0.0
        
        // when
        vm.storeCurrentLocation(lat: lat, lng: lng)
        
        guard
            let sut1 = UserDefaults.standard.value(forKey: "current_latitude") as? Double,
            let sut2 = UserDefaults.standard.value(forKey: "current_longitude") as? Double
        else {
            XCTFail("failed expectation: should have saved values by now")
            return
        }
        
        // then
        XCTAssertEqual(sut1, 0.0)
        XCTAssertEqual(sut2, 0.0)
    }
    
    func test_can_displayLocations_in_list() {
        
        // given
        let vc = SearchViewController()
        let table = UITableView()
        let searchbar = UISearchBar()
        
        // given: set required outlets
        vc.tableView = table
        vc.searchBar = searchbar
        vc.loadViewIfNeeded()
        
        // then
        let expect = expectation(description: "expect")
        let result = XCTWaiter.wait(for: [expect], timeout: 3.0)
        guard result == XCTWaiter.Result.timedOut else {
            XCTFail("failed expection: delay interrupted")
            return
        }
        
        XCTAssertEqual(table.numberOfSections, 1)
    }
    
    func test_can_createMapPin() {
        
    }
}
