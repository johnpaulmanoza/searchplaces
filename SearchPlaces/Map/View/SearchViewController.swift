//
//  SearchViewController.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    let viewModel = SearchViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customize()
        
        bind()
        
        observe()
    }
    
    private func customize() {
     
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
    }
    
    private func bind() {
        
        // load initial places
        viewModel.loadPlaces()
        
        // Observe changes from the viewmodel sections
        // and update the list accordingly
        _ = viewModel.sections.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
    }
    
    private func observe() {
        
    }
    
    @IBAction func queryCategory1(_ sender: Any) {
        
        viewModel.searchRestaurants()
    }
    
    @IBAction func queryCategory2(_ sender: Any) {
        
        viewModel.searchShopping()
    }
    
    @IBAction func queryCategory3(_ sender: Any) {
        
        viewModel.searchEntertainment()
    }
    
    @IBAction func queryCategory4(_ sender: Any) {
        
        viewModel.searchTravel()
    }
}

extension SearchViewController {

    // Provide Datasource for the tableview
    public var dataSource: RxTableViewSectionedReloadDataSource<MapListItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<MapListItem>(configureCell: { (source, tableView, indexPath, _) in

            switch source[indexPath] {
            case .locationItem(let data):
                let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.id, for: indexPath)
                // set cell model data
                (cell as! LocationCell).locationData = data
                return cell
            }
        })

        return dataSource
    }
}

extension SearchViewController {
    
    // Functions to manipulate visibility of frame of header
    
    func showHeader(animated: Bool) {
        tableView.tableHeaderView?.isHidden = false
        changeHeader(height: 116.0, aniamted: animated)
    }

    func hideHeader(animated: Bool) {
        tableView.tableHeaderView?.isHidden = true
        changeHeader(height: 0.0, aniamted: animated)
    }
    
    private func changeHeader(height: CGFloat, aniamted: Bool) {
        guard let headerView = tableView.tableHeaderView, headerView.bounds.height != height else { return }
        if aniamted == false {
            updateHeader(height: height)
            return
        }
        tableView.beginUpdates()
        UIView.animate(withDuration: 0.25) {
            self.updateHeader(height: height)
        }
        tableView.endUpdates()
    }
    
    private func updateHeader(height: CGFloat) {
        guard let headerView = tableView.tableHeaderView else { return }
        var frame = headerView.frame
        frame.size.height = height
        self.tableView.tableHeaderView?.frame = frame
    }
}
