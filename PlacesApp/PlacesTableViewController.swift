//
//  PlacesTableViewController.swift
//  PlacesApp
//
//  Created by Сашок on 25.02.2022.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    var places = PlaceModel.getPlaces()
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)

        if let placeCell = cell as? PlaceCell {
            
            let place = places[indexPath.row]
            
            placeCell.nameLabel.text = place.name
            placeCell.locationLabel.text = place.location
            placeCell.typeLabel.text = place.type
            placeCell.placeImage.image =
                place.predefinedImage == nil ? place.image : UIImage(named: place.predefinedImage!)
            
            placeCell.placeImage.layer.cornerRadius = placeCell.placeImage.frame.height / 2
            placeCell.placeImage.clipsToBounds = true
        }
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVicewController = segue.source as? NewPlaceViewController else {
            return
        }
        
        places.append(newPlaceVicewController.getNewPlace())
        
        tableView.reloadData()
    }

}
