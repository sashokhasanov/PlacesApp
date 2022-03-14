//
//  PlacesTableViewController.swift
//  PlacesApp
//
//  Created by Сашок on 25.02.2022.
//

import UIKit
import RealmSwift

class PlacesTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var sortButtonItem: UIBarButtonItem!

    // MARK: - Private properties
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    
    private var searchController = UISearchController()
    private var orderBy = OrderBy.name
    
    private var isFiltering: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    private var notificationTokens: [NotificationToken] = []
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        places = StorageManager.shared.realm.objects(Place.self)
        
        setupSearchController()
        setupOrderItem()
        
        setupDbChangesObserver()
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
            StorageManager.shared.deleteObject(place)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Navigation
extension PlacesTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "showDetails" else {
            return
        }
        
        guard let targetVieController = segue.destination as? NewPlaceViewController else {
            return
        }
        
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }

        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        targetVieController.editedPlace = place
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
}

// MARK: - UISearchResultsUpdating
extension PlacesTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {

        let searchText = searchController.searchBar.text ?? ""
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}


// MARK: - Search
extension PlacesTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        orderPlaces()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Enter place name or location"

        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: - Ordering
extension PlacesTableViewController {
    
    private func setupOrderItem() {
        
        let byDate = UIAction(title: "By date", identifier: UIAction.Identifier(OrderBy.date.rawValue), state: .on) { _ in
            self.orderBy = .date
            self.updateState(for: self.sortButtonItem.menu)
            self.orderPlaces()
        }
        
        let byName = UIAction(title: "By name", identifier: UIAction.Identifier(OrderBy.name.rawValue), state: .off) { _ in
            self.orderBy = .name
            self.updateState(for: self.sortButtonItem.menu)
            self.orderPlaces()
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [byDate, byName])
        sortButtonItem.menu = menu
        sortButtonItem.primaryAction = nil
    }
    
    private func updateState(for menu: UIMenu?) {
        guard let menu = menu else {
            return
        }
        
        menu.children.forEach { action in
            guard let action = action as? UIAction else {
                return
            }
            
            if action.identifier == UIAction.Identifier(self.orderBy.rawValue) {
                action.state = .on
            } else {
                action.state = .off
            }
        }
    }
    
    private func orderPlaces() {
        places = places.sorted(byKeyPath: orderBy.rawValue)
        tableView.reloadData()
    }
    
    private enum OrderBy: String {
        case date
        case name
    }
}

// MARK: - Observing DB changes
extension PlacesTableViewController {

    private func setupDbChangesObserver() {
        let notificationTokenPlaces = places.observe { changes in

            guard !self.isFiltering else {
                return
            }

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
        notificationTokens.append(notificationTokenPlaces)
    }
}
