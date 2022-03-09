//
//  PlaceCell.swift
//  PlacesApp
//
//  Created by Сашок on 28.02.2022.
//

import UIKit
import Cosmos

class PlaceCell: UITableViewCell {
    @IBOutlet weak var placeImage: UIImageView! {
        didSet {
            placeImage.layer.cornerRadius = placeImage.frame.height / 2
            placeImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
}
