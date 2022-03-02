//
//  PlacesTableViewController.swift
//  PlacesApp
//
//  Created by Сашок on 25.02.2022.
//

import UIKit
import RealmSwift

class PlacesTableViewController: UITableViewController {

    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    
    private var searchController = UISearchController()
    
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
        searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        setupSearchController()
    }
    
    
    private func setupSearchController() {
        
        
        searchController.searchResultsUpdater = self
        
        
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        
        searchController.searchBar.scopeButtonTitles = ["Date", "Name"]
        searchController.searchBar.showsScopeBar = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        
    }
    
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        } else {
            return places.count
            
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)

        if let placeCell = cell as? PlaceCell {
            
            
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
            placeCell.nameLabel.text = place.name
            placeCell.locationLabel.text = place.location
            placeCell.typeLabel.text = place.type
            
            placeCell.placeImage.image = UIImage(data: place.imageData!)
            placeCell.placeImage.layer.cornerRadius = placeCell.placeImage.frame.height / 2
            placeCell.placeImage.clipsToBounds = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            
            guard let targetVieController = segue.destination as? NewPlaceViewController else {
                return
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
            targetVieController.currentPlace = place
            
        }
    }

    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVicewController = segue.source as? NewPlaceViewController else {
            return
        }
        
        newPlaceVicewController.savePlace()

        tableView.reloadData()
    }
    
    private func sorting() {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
        
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func reverseSortingDirection(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            sender.image = UIImage(systemName: "arrow.up")
        } else {
            sender.image = UIImage(systemName: "arrow.down")
        }
        
        sorting()
        
        
        
    }

}

extension PlacesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        filterCOntentForSearchText(searchController.searchBar.text ?? "")
        
    }
    
    private func filterCOntentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS %@", searchText)
        
        tableView.reloadData()
    }
}

extension PlacesTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        sorting()
    }
    
}
