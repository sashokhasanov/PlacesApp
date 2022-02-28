//
//  PlacesTableViewController.swift
//  PlacesApp
//
//  Created by Сашок on 25.02.2022.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    let places = Place.getPlaces()
    

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
            
            
            placeCell.nameLabel.text = places[indexPath.row].name
            placeCell.locationLabel.text = places[indexPath.row].location
            placeCell.typeLabel.text = places[indexPath.row].type
            placeCell.placeImage.image = UIImage(named: places[indexPath.row].image)
            
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
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {}

}
