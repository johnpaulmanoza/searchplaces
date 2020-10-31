//
//  LocationCell.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    // display the received cell data
    var locationData: MapCellItem? {
        didSet {
            guard let location = locationData?.location else { return }
            // display cell data once a location is received
            titleLabel.text = location.locationName
            subTitleLabel.text = location.locationAddress
        }
    }
}
