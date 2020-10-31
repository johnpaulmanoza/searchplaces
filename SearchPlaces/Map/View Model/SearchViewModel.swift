//
//  SearchViewModel.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class SearchViewModel {
    
    var sections: PublishSubject<[MapListItem]> = PublishSubject()
    
    private let api = APIManager()
    private let bag = DisposeBag()
    private var items: [Location] = []
    
    init() {
        
    }
    
    /**
     
    Load Places API
     
     - Parameters:
        - query: Name of establishment or location
     */
    public func loadPlaces(query: String = "Restaurant") {
        _ = api.loadPlaces(query: query).asObservable()
            .subscribe(onNext: { [weak this = self] (items) in
                guard let locations = items as? [Location] else { return }
                this?.items = locations
                this?.showItems()
            })
            .disposed(by: bag)
    }
    
    /**
    Load a specific query for places related to restaurants
    */
    public func searchRestaurants() {
        
        loadPlaces(query: "Restaurant")
    }
    
    /**
    Load a specific query for places related to shopping
    */
    public func searchShopping() {
        
        loadPlaces(query: "Mall")
    }
    
    /**
    Load a specific query for places related to entertainment
    */
    public func searchEntertainment() {
        
        loadPlaces(query: "Entertainment")
    }
    
    /**
     Load a specific query for places related to travel
     */
    public func searchTravel() {
        
        loadPlaces(query: "Travel")
    }
    
    
    /**
    
        Store current location to user defaults
     
     - Parameters:
        - lat: current location latitude
        - lng: current location longitude
     */
    public func storeCurrentLocation(lat: Double, lng: Double) {
        
        UserDefaults.standard.set(lat, forKey: "current_latitude")
        UserDefaults.standard.set(lng, forKey: "current_longitude")
        UserDefaults.standard.synchronize()
    }
    
    /**
    Display list items by iterating the location results and converting them to UI Model Classes
     */
    private func showItems() {
        
        let listItems = items
            .map { MapCellItem(location: $0) }
            .map { MapListItem.Row.locationItem(item: $0) }
        
        sections.onNext([
            MapListItem.listSection(header: "", items: listItems)
        ])
    }
}
