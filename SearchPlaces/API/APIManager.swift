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
    
    func loadPlaces(query: String) -> Observable<Any> {
        var url = "https://places.demo.api.here.com/places/v1/discover/search"
        url.append("?q=\(query)")
        url.append("&Geolocation=geo:14.6091,121.0223")
        url.append("&app_code=AJKnXv84fjrb0KIHawS0Tg")
        url.append("&app_id=DemoAppId01082013GAL")
        url.append("&pretty=true")
        
        return Observable<Any>.create { observer in
            // request
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
