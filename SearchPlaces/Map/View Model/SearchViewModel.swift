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
import CoreLocation

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
    
    // Load a specific query for places
    public func searchRestaurants() {
        
        loadPlaces(query: "Restaurant")
    }
    
    // Load a specific query for places
    public func searchShopping() {
        
        loadPlaces(query: "Mall")
    }
    
    // Load a specific query for places
    public func searchEntertainment() {
        
        loadPlaces(query: "Entertainment")
    }
    
    // Load a specific query for places
    public func searchTravel() {
        
        loadPlaces(query: "Travel")
    }
    
    public func storeCurrentLocation(location: CLLocation) {
        
        UserDefaults.standard.set(location.coordinate.latitude, forKey: "current_latitude")
        UserDefaults.standard.set(location.coordinate.longitude, forKey: "current_longitude")
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
