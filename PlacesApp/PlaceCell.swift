//
//  PlaceCell.swift
//  PlacesApp
//
//  Created by Сашок on 28.02.2022.
//

import UIKit
import Cosmos

class PlaceCell: UITableViewCell {
    
    // MARK: - reuse identifier
    static let reuseId = "PlaceCell"
    
    // MARK: - IBOutlets
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    // MARK: - Cell configuration
    func configure(with place: Place) {
        nameLabel.text = place.name
        locationLabel.text = place.location
        typeLabel.text = place.type
        ratingView.rating = place.rating
        
        if let imageData = place.imageData {
            placeImage.image = UIImage(data: imageData)
        }
        placeImage.layer.cornerRadius = placeImage.frame.height / 2
        placeImage.clipsToBounds = true
    }
}
