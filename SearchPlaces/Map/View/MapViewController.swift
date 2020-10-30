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
import CoreLocation

class MapViewController: UIViewController, FloatingPanelControllerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    private var fpc: FloatingPanelController!
    
    private var searchView: SearchViewController!
    
    private var locationManager = CLLocationManager()
    
    private let bag = DisposeBag()
    
    private var hasSelection = false
    
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
        
        // ask for location permission
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
                    
                    // indicate has selection
                    this?.hasSelection = true
                    
                    // extract location details from selected item
                    let address = location.locationAddress ?? ""
                    let name = location.locationName ?? ""
                    
                    // extract location coordinaets
                    guard let lat = location.locationLat, let lng = location.locationLng else { return }
                    let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    
                    // create a pin when user selected a location
                    this?.setPinUsingMKPlacemark(location: coordinates, title: name, subtitle: address)
                    
                    // dismiss panel and dismiss the keyboard
                    UIView.animate(withDuration: 0.25) { [weak self] in
                        self?.searchView.searchBar.resignFirstResponder()
                        self?.fpc.move(to: .tip, animated: false)
                    }
                    
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

// conform to UISearchBarDelegate
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

    // conditionally hide/show search bar header
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchView.showHeader(animated: true)
        searchView.tableView.alpha = 1.0
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.fpc.move(to: .full, animated: false)
        }
    }
}

// conform to CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // store current location
            searchView.viewModel.storeCurrentLocation(location: location)
            
            // update map to show your current location region
            guard hasSelection == false else { return }
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.map.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        presentAlertWithTitle(title: "Location Error", message: error.localizedDescription, options: "") { (_) in }
    }
}
