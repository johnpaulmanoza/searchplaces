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
        
        fpc.set(contentViewController: contentVC)

        // Track a scroll view(or the siblings) in the content view controller.
        fpc.track(scrollView: contentVC.tableView)

        // Add and show the views managed by the `FloatingPanelController` object to self.view.
        fpc.addPanel(toParent: self)
    }
    
    private func bind() {
        
    }
    
    private func observe() {
        
    }
}
