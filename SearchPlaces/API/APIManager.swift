//
//  APIManager.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import RxSwift

class APIManager {
    
    /**
     
    Load nearby places
     
     - Parameters:
        - query: Name of establishment or location
     
     - Returns:
        - An observable that emits the loaded objects
     */
    func loadPlaces(query: String) -> Observable<Any> {
        var url = "https://places.demo.api.here.com/places/v1/discover/search"
        
        // insert query as parameter
        if let q = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            url.append("?q=\(q)")
        }
        
        // insert current location as a parameter
        let defaults = UserDefaults.standard
        if let lat = defaults.object(forKey: "current_latitude") as? Double, let lng = defaults.object(forKey: "current_longitude") as? Double {
            print("using current loc", lat, lng)
            url.append("&Geolocation=geo:\(lat),\(lng)")
        } else {
            // if fails, use a default location - manila
            url.append("&Geolocation=geo:14.6091,121.0223")
        }
        
        url.append("&app_code=AJKnXv84fjrb0KIHawS0Tg")
        url.append("&app_id=DemoAppId01082013GAL")
        url.append("&pretty=true")
        
        return Observable<Any>.create { observer in
            // create a request now and return the response via observable
            Alamofire.request(url).responseObject(completionHandler: { (response: DataResponse<LocationData>) in
                switch response.result {
                case .success(let value):
                    observer.onNext(value.itemData); observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
}
