//
//  ViewController.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel
import RxSwift
import RxDataSources

class MapViewController: UIViewController, FloatingPanelControllerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    private var fpc: FloatingPanelController!
    
    private var searchView: SearchViewController!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customize()
        
        bind()
        
        observe()
    }
    
    private func customize() {
        
        // Initialize a `FloatingPanelController` object.
        fpc = FloatingPanelController()

        // Assign self as the delegate of the controller.
        fpc.delegate = self // Optional

        // Set a content view controller.
        let board = UIStoryboard(name: "Main", bundle: nil)
        
        guard
            let contentVC = board.instantiateViewController(withIdentifier: SearchViewController.id) as? SearchViewController
        else
            { return }
        
        searchView = contentVC
        
        fpc.set(contentViewController: searchView)

        // Track a scroll view(or the siblings) in the content view controller.
        fpc.track(scrollView: searchView.tableView)

        // set the search bar delegate here
        searchView.searchBar.delegate = self
        
        // Add and show the views managed by the `FloatingPanelController` object to self.view.
        fpc.addPanel(toParent: self)
        
        fpc.setApearanceForPhone()
    }
    
    private func bind() {
        
    }
    
    private func observe() {
        
        // Observe row selections here
        _ = Observable.zip(
                searchView.tableView.rx.itemSelected,
                searchView.tableView.rx.modelSelected(MapListItem.Row.self)
            )
            .subscribe(onNext: { [weak this = self] (indexPath, model) in
                this?.searchView.tableView.deselectRow(at: indexPath, animated: true)
                switch model {
                case .locationItem(let data):
                    guard let location = data.location else { return }
                    
                    // extract location details from selected item
                    let address = location.locationAddress ?? ""
                    let name = location.locationName ?? ""
                    
                    // extract location coordinaets
                    guard let lat = location.locationLat, let lng = location.locationLng else { return }
                    let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    
                    // create a pin when user selected a location
                    this?.setPinUsingMKPlacemark(location: coordinates, title: name, subtitle: address)
                    
                    break
                }
            })
            .disposed(by: bag)
    }
    
    /**
     
    Create a Map Pin
     
        - Parameters:
            - location: coordinates of the pin
            - title: title of the pin
            - subtitle: subtitle of the pin
     */
    
    private func setPinUsingMKPlacemark(location: CLLocationCoordinate2D, title: String, subtitle: String) {
       let annotation = MKPointAnnotation()
       annotation.coordinate = location
       annotation.title = title
       annotation.subtitle = subtitle
       let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
       map.setRegion(coordinateRegion, animated: true)
       map.addAnnotation(annotation)
    }
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // minimum search term is at least 3 characters
        guard let query = searchBar.text, query.count > 3 else { return }
        // search now
        searchView.viewModel.loadPlaces(query: query)
    }
    
    // conditionally hide/show search bar header
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        searchView.hideHeader(animated: true)
        UIView.animate(withDuration: 0.25) {
            self.fpc.move(to: .half, animated: false)
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchView.showHeader(animated: true)
        searchView.tableView.alpha = 1.0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.fpc.move(to: .full, animated: false)
        }
    }
}
