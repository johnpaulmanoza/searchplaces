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
    
    private let api = APIManager()
    private let bag = DisposeBag()
    
    init() {
        loadPlaces()
    }
    
    public func loadPlaces() {
        _ = api.loadPlaces(query: "Restaurant").asObservable()
            .subscribe(onNext: { [weak this = self] (items) in
                guard let locations = items as? [Location] else { return }
                print("using locations", locations)
            })
            .disposed(by: bag)
    }
}
