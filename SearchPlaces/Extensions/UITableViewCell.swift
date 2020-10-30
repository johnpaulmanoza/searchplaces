//
//  UITableViewCell.swift
//  SearchPlaces
//
//  Created by John Paul Manoza on 10/30/20.
//  Copyright © 2020 John Paul Manoza. All rights reserved.
//

import UIKit

extension UITableViewCell {
    /**
     To easily identify cells by their reuseIdentifier
    */
    public static var id: String {
        return String(describing: self)
    }
}
