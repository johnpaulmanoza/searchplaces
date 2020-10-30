//
//  Location.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import ObjectMapper

// This class is used to map the api response
class LocationData: Mappable {
    public var itemData: [Location] = []

    public required init?(map: Map) {

    }

    public func mapping(map: Map) {
        itemData <- map["results.items"]
    }
}

// This class is used to map the api response
class Location: Mappable {
    
    var locationName:       String?
    var locationAddress:    String?
    
    var locations:          [Double] = []
    
    var locationLat:        Double?
    var locationLng:        Double?
    
    required init?(map: Map){

    }
    
    func mapping(map: Map) {
        
        locationName        <- map["title"]
        locationAddress     <- map["address.text"]
        locations           <- map["position"]
        
        // remove new line
        locationAddress = locationAddress?.replacingOccurrences(of: "<br/>", with: ", ")
        
        // extract coordinates first item is lat and the last is long
        guard locations.count == 2 else { return }
        locationLat = locations.first
        locationLng = locations.last
    }
}
