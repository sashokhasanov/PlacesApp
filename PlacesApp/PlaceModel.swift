//
//  PlaceModel.swift
//  PlacesApp
//
//  Created by Сашок on 28.02.2022.
//

import UIKit

struct PlaceModel {
    let name: String
    let location: String?
    let type: String?
    
    let image: UIImage?
    let predefinedImage: String?
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [PlaceModel] {
        var places = [PlaceModel]()
        
        for name in restaurantNames {
            places.append(PlaceModel(name: name, location: "Москва", type: "Ресторан", image: nil, predefinedImage: name))
        }
        
        return places
    }
}
