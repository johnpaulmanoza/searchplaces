//
//  SearchViewController.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = SearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
