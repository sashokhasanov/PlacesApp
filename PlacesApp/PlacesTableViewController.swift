//
//  PlacesTableViewController.swift
//  PlacesApp
//
//  Created by Сашок on 25.02.2022.
//

import UIKit
import RealmSwift

class PlacesTableViewController: UITableViewController {

    // MARK: - Private properties
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    
    private var searchController = UISearchController()
    private var ascendingSorting = true
    
    private var isFiltering: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    var notificationToken: NotificationToken?
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        
        setupSearchController()
        observePlacesChanges()
    }
    
    //MARK: - IBActions
    @IBAction func reverseSortingDirection(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        sender.image = UIImage(systemName: ascendingSorting ? "arrow.up" : "arrow.down")
        sortPlaces()
    }
    
    // MARK: - Private methods
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Name or location"
        
        searchController.searchBar.scopeButtonTitles = ["Date", "Name"]
        searchController.searchBar.showsScopeBar = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    private func sortPlaces() {
        let sortingKeyPath =
            searchController.searchBar.selectedScopeButtonIndex == 0 ? "date" : "name"
        
        places = places.sorted(byKeyPath: sortingKeyPath, ascending: ascendingSorting)
        tableView.reloadData()
    }
    
    private func observePlacesChanges() {
        notificationToken = places.observe { changes in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates {
                    // ! Always apply updates in the following order: deletions, insertions, then modifications.
                    // Handling insertions before deletions may result in unexpected behavior.
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                }
                
            case .error(let error):
                print(error)
            }
        }
    }
}
    
// MARK: - Table view data source
extension PlacesTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredPlaces.count : places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.reuseId, for: indexPath)

        if let placeCell = cell as? PlaceCell {
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            placeCell.configure(with: place)
        }
        
        return cell
    }
}
    
// MARK: - Table view delegate
extension PlacesTableViewController {
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Navigation
extension PlacesTableViewController {
    
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
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
}

// MARK: - UISearchResultsUpdating
extension PlacesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard isFiltering else {
            return
        }

        let searchText = searchController.searchBar.text ?? ""
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText)
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension PlacesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        sortPlaces()
    }
}
