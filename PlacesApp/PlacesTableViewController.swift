//
//  PlacesTableViewController.swift
//  PlacesApp
//
//  Created by Сашок on 25.02.2022.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)

        var configuration = cell.defaultContentConfiguration()
        configuration.text = restaurantNames[indexPath.row]
        configuration.image = UIImage(named: restaurantNames[indexPath.row])
        configuration.imageProperties.cornerRadius = cell.frame.size.height / 2
        
        cell.contentConfiguration = configuration
        
//        cell.textLabel?.text = restaurantNames[indexPath.row]
//        cell.imageView?.image = UIImage(named: restaurantNames[indexPath.row])
//        cell.imageView?.layer.cornerRadius = cell.frame.size.height / 2
//        cell.imageView?.clipsToBounds = true

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
