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
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        customize()
        
        bind()
        
        observe()
    }
    
    private func customize() {
        
    }
    
    private func bind() {
        
    }
    
    private func observe() {
        
    }
}

extension SearchViewController {
    
    func showHeader(animated: Bool) {
        changeHeader(height: 116.0, aniamted: animated)
    }

    func hideHeader(animated: Bool) {
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
