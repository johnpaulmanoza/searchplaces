//
//  ViewController.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit
import FloatingPanel

class MapViewController: UIViewController, FloatingPanelControllerDelegate {
    
    var fpc: FloatingPanelController!
    
    private var searchView: SearchViewController!
    
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

        searchView.searchBar.delegate = self
        
        // Add and show the views managed by the `FloatingPanelController` object to self.view.
        fpc.addPanel(toParent: self)
        
        fpc.setApearanceForPhone()
    }
    
    private func bind() {
        
    }
    
    private func observe() {
        
    }
}

extension MapViewController: UISearchBarDelegate {
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
