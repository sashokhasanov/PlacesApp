//
//  PlaceModel.swift
//  PlacesApp
//
//  Created by Сашок on 28.02.2022.
//

import RealmSwift

class Place: Object {
    
    @Persisted var name = ""
    @Persisted var location: String?
    @Persisted var type: String?
    @Persisted var imageData: Data?
    @Persisted var date = Date()
    @Persisted var rating = 0.0
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
    
//    let restaurantNames = [
//        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
//        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
//        "Speak Easy", "Morris Pub", "Вкусные истории",
//        "Классик", "Love&Life", "Шок", "Бочка"
//    ]
//    
//    func getPlaces() {
//
//        for name in restaurantNames {
//            let newPlace = Place()
//            
//            newPlace.name = name
//            newPlace.location = "Moscow"
//            newPlace.type = "Restaurant"
//            
//            let image = UIImage(named: name)
//            if let imageData = image?.pngData() {
//                newPlace.imageData = imageData
//            }
//            
//            StorageManager.saveObject(newPlace)
//        }
//
//    }
}
