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
    
    private var isMapCenteredToCurrentLocation = false
    
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
        
        // set map delegate
        map.delegate = self
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
                    
                    // look for the annotation in the map
                    guard let locationName = data.location?.locationName else { return }
                    guard let annotation = this?.map.annotations.filter({ $0.title == locationName }).first else { return }
                    
                    // select the annotation
                    this?.map.selectAnnotation(annotation, animated: true)
                    
                    // dismiss panel and dismiss the keyboard
                    UIView.animate(withDuration: 0.25) { [weak self] in
                        self?.searchView.searchBar.resignFirstResponder()
                        self?.fpc.move(to: .tip, animated: false)
                    }
                    
                    break
                }
            })
            .disposed(by: bag)
        
        // Create pins and plot them into the map
        _ = searchView.viewModel.pins.asObservable()
            .subscribe(onNext: { [weak this = self] (items) in
                guard let this = this else { return }
                
                // dismiss search field
                this.searchBarCancelButtonClicked(this.searchView.searchBar)
                
                // clear all previous pin first
                this.clearAllMapPins()
                
                // display map pins
                _ = items.map { (location) -> Void in
                    let lat = location.locationLat ?? 0
                    let lng = location.locationLng ?? 0
                    let name = location.locationName ?? ""
                    let add = location.locationAddress ?? ""
                    
                    let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    let pin = this.createPinUsingPlace(location: coordinates, title: name, subtitle: add)
                    this.map.addAnnotation(pin)
                }
                
                // center map on first result
                guard let firstLocation = items.first else { return }
                let lat = firstLocation.locationLat ?? 0
                let lng = firstLocation.locationLng ?? 0
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                this.centerMapToLocation(coordinates: center)
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
    
    private func createPinUsingPlace(location: CLLocationCoordinate2D, title: String, subtitle: String) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title
        annotation.subtitle = subtitle
        return annotation
    }
    
    /**
     
    Center the map using a coordinate
     
     - Parameters:
        - coordinates: coordinate to center with
     
     */
    private func centerMapToLocation(coordinates: CLLocationCoordinate2D) {
           
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 800, longitudinalMeters: 800)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    /**
     
    Clear all previous map pins
     
     */
    private func clearAllMapPins() {
        
        _ = map.annotations.map { map.removeAnnotation($0) }
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
extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        // center the mapView on the selected pin
        let coordinates = view.annotation!.coordinate
        centerMapToLocation(coordinates: coordinates)
    }
    
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
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            searchView.viewModel.storeCurrentLocation(lat: lat, lng: lng)
            
            // update map to show your current location region, once found stop updating location.
            guard isMapCenteredToCurrentLocation == false else { return }
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            centerMapToLocation(coordinates: center)
            isMapCenteredToCurrentLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        presentAlertWithTitle(title: "Location Error", message: error.localizedDescription, options: "OK") { (_) in }
    }
}
